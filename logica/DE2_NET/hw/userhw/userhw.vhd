library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;

entity userhw is
    port (
        -- Avalon slave interface
        clk         : in  std_logic;
        rst         : in  std_logic;
        data_in     : in  std_logic_vector(31 downto 0);
        data_out    : out std_logic_vector(31 downto 0);
        wr_en       : in  std_logic;
        rd_en       : in  std_logic;
        cs          : in  std_logic;
        addr        : in  std_logic_vector(2 downto 0);
        -- Signals for the circuit
        -- Buffer (32 32-bit registers)
        buffer_in   : out stdlv32_array(31 downto 0);
        buffer_wren : out std_logic_vector(31 downto 0);
        buffer_out  : in  stdlv32_array(31 downto 0);
        -- FFT
        fft_in      : out complex_array(31 downto 0);
        fft_out     : in  complex_array(31 downto 0);
        fft_st      : out std_logic_vector(2 downto 0)
    );
end entity userhw;

architecture rtl of userhw is

    component reg32 is
        port (
            clk     : in  std_logic;
            rst     : in  std_logic;
            wren    : in  std_logic;
            data_in : in  std_logic_vector(31 downto 0);
            q       : out std_logic_vector(31 downto 0)
        );
    end component reg32;

    signal clk0,clk1,clk2,clk3,clk4 : std_logic;
    signal rst0,rst1,rst2,rst3,rst4 : std_logic;
    signal wren0,wren1,wren2,wren3,wren4 : std_logic;
    signal data_in0,data_in1,data_in2,data_in3,data_in4 : std_logic_vector(31 downto 0);
    signal q0,q1,q2,q3,q4 : std_logic_vector(31 downto 0);

    signal reg3_clr,reg4_clr : std_logic;

    component mux_32x1 is
        port(
            i : in stdlv32_array(31 downto 0);
            s : in std_logic_vector(4 downto 0);
            o : out std_logic_vector(31 downto 0)
        );
    end component mux_32x1;

    signal output_mux_i : stdlv32_array(31 downto 0);
    signal output_mux_s : std_logic_vector(4 downto 0);
    signal output_mux_o : std_logic_vector(31 downto 0);


    signal data_out_s : std_logic_vector(31 downto 0);

    signal buffer_in_s : stdlv32_array(31 downto 0);
    signal buffer_wren_s : std_logic_vector(31 downto 0);

    signal fft_in_s : complex_array(31 downto 0);
    signal fft_stage : integer range 0 to 6 := 0;

begin

    -- REG0 - Data input for the buffer
    reg0 : reg32 port map (
        clk     => clk0,
        rst     => rst0,
        wren    => wren0,
        data_in => data_in0,
        q       => q0
    );

    -- REG1 - Data output from the buffer
    reg1 : reg32 port map (
        clk     => clk1,
        rst     => rst1,
        wren    => wren1,
        data_in => data_in1,
        q       => q1
    );

    -- REG2 - Address for the buffer I/O
    reg2 : reg32 port map (
        clk     => clk2,
        rst     => rst2,
        wren    => wren2,
        data_in => data_in2,
        q       => q2
    );

    -- REG3 - Write enable for the buffer's selected address
    reg3 : reg32 port map (
        clk     => clk3,
        rst     => rst3,
        wren    => wren3,
        data_in => data_in3,
        q       => q3
    );

    -- REG4 - FFT stage selection
    reg4 : reg32 port map (
        clk     => clk4,
        rst     => rst4,
        wren    => wren4,
        data_in => data_in4,
        q       => q4
    );

    -- MUX - Output mux
    output_mux : mux_32x1 port map (
        i => output_mux_i,
        s => output_mux_s,
        o => output_mux_o
    );

    -- Clock and reset signals
    clk0 <= clk;
    clk1 <= clk;
    clk2 <= clk;
    clk3 <= clk;
    clk4 <= clk;

    rst0 <= rst;
    rst1 <= rst;
    rst2 <= rst;
    rst3 <= '1' when reg3_clr = '1' else rst;   -- Self clearing
    rst4 <= '1' when reg4_clr = '1' else rst;   -- Self clearing

    -- Write enable signals
    wren0 <= '1' when wr_en = '1' and cs = '1' and addr = "000" else '0';
    wren1 <= '1';
    wren2 <= '1' when wr_en = '1' and cs = '1' and addr = "010" else '0';
    wren3 <= '1' when wr_en = '1' and cs = '1' and addr = "011" else '0';
    wren4 <= '1' when wr_en = '1' and cs = '1' and addr = "100" else '0';

    -- Data input signals
    data_in0 <= data_in;
    data_in2 <= data_in;
    data_in3 <= data_in;
    data_in4 <= data_in;

    -- FFT stage selection
    fft_stage <= to_integer(unsigned(q4));
    fft_st <= std_logic_vector(to_unsigned(fft_stage,3));

    -- Buffer inputs
    buffer_input_gen : for i in 0 to 31 generate
        -- Each input i is connected to a mux:
        -- -- If fft_stage is not 0, the input is connected to the output i of the FFT
        -- -- If fft_stage is 0, the input is connected to the data input register
        buffer_in_s(i) <= cmplx_split(fft_out(i)) when (fft_stage = 6) else q0;
    end generate buffer_input_gen;
    buffer_in <= buffer_in_s;

    -- Buffer write enables
    buffer_wren_gen : for i in 0 to 31 generate
        -- Each write enable i is enabled by either:
        -- -- fft_stage is not 0
        -- -- wren from reg3 is 1 and the address from q2 is i
        buffer_wren_s(i) <= '1' when (fft_stage = 6) or ((q3(0) = '1') and (q2(4 downto 0) = std_logic_vector(to_unsigned(i,5)))) else '0';
    end generate buffer_wren_gen;
    buffer_wren <= buffer_wren_s;

    -- Buffer outputs routing
    -- The buffer goes two ways:
    -- -- It casts to complex and feeds the FFT input
    fft_in_s <= stdlv32arr_to_cmplxarr(buffer_out);
    fft_in <= fft_in_s;
    -- -- Each output i goes into a mux that goes into the data output register reg1
    -- -- -- The select is the address from reg2
    output_mux_i <= buffer_out;
    output_mux_s <= q2(4 downto 0);
    data_in1 <= output_mux_o;
    -- -- From the register reg1, the data is an input for a mux:
    -- -- -- If rd_en and cs are 1 and the address is 1, the output is the data from reg1
    -- -- -- Other registers can be read for debugging purposes
    -- -- -- Otherwise, the output is high impedance
    data_out_s <= q1 when (rd_en = '1' and cs = '1' and addr = "001") else
                  q0 when (rd_en = '1' and cs = '1' and addr = "000") else
                  q2 when (rd_en = '1' and cs = '1' and addr = "010") else
                  q3 when (rd_en = '1' and cs = '1' and addr = "011") else
                  q4 when (rd_en = '1' and cs = '1' and addr = "100") else
                  (others => 'Z');
    data_out <= data_out_s;


    self_clear_proc: process(clk)
    begin
        if rising_edge(clk) then
            if not (q3 = std_logic_vector(to_unsigned(0,32))) then
                reg3_clr <= '1';
            else
                reg3_clr <= '0';
            end if;
            if not (q4 = std_logic_vector(to_unsigned(0,32))) then
                reg4_clr <= '1';
            else
                reg4_clr <= '0';
            end if;
        end if;
    end process self_clear_proc;

end architecture rtl;