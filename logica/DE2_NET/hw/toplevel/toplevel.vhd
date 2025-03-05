library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;

entity toplevel is
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        data_in     : in  std_logic_vector(31 downto 0);
        data_out    : out std_logic_vector(31 downto 0);
        wr_en       : in  std_logic;
        rd_en       : in  std_logic;
        cs          : in  std_logic;
        addr        : in  std_logic_vector(2 downto 0)
    );
end entity toplevel;

architecture rtl of toplevel is

    ------ USERHW ------

    component userhw is
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
    end component userhw;

    -- Avalon slave interface
    signal clk_hw, rst_hw, wr_en_hw, rd_en_hw, cs_hw : std_logic;
    signal addr_hw : std_logic_vector(2 downto 0);
    signal data_in_hw, data_out_hw : std_logic_vector(31 downto 0);
    -- Signals for the circuit
    -- Buffer (32 32-bit registers)
    signal buffer_in_hw : stdlv32_array(31 downto 0);
    signal buffer_wren_hw : std_logic_vector(31 downto 0);
    signal buffer_out_hw : stdlv32_array(31 downto 0);
    -- FFT
    signal fft_in_hw : complex_array(31 downto 0);
    signal fft_out_hw : complex_array(31 downto 0);
    signal fft_st_hw : std_logic_vector(2 downto 0);

    ------ BUFFER ------

    component buffer32 is
        port (
            clk        : in std_logic;
            rst        : in std_logic;
            wren       : in std_logic_vector(31 downto 0);
            buffer_in  : in stdlv32_array(31 downto 0);
            buffer_out : out stdlv32_array(31 downto 0)
        );
    end component buffer32;

    signal clk_buff, rst_buff : std_logic;
    signal wren_buff : std_logic_vector(31 downto 0);
    signal buffer_in_buff, buffer_out_buff : stdlv32_array(31 downto 0);

    ------ FFT ------

    component fft is
        port (
            clk : in std_logic;
            rst : in std_logic;
            stage : in std_logic_vector(2 downto 0);
            data_in : in complex_array(0 to 31);
            data_out : out complex_array(0 to 31)
        );
    end component fft;

    signal clk_fft, rst_fft : std_logic;
    signal stage_fft : std_logic_vector(2 downto 0);
    signal data_in_fft : complex_array(0 to 31);
    signal data_out_fft : complex_array(0 to 31);

begin
    
    user_hw_inst : userhw
        port map (
            clk => clk_hw,
            rst => rst_hw,
            data_in => data_in_hw,
            data_out => data_out_hw,
            wr_en => wr_en_hw,
            rd_en => rd_en_hw,
            cs => cs_hw,
            addr => addr_hw,
            buffer_in => buffer_in_hw,
            buffer_wren => buffer_wren_hw,
            buffer_out => buffer_out_hw,
            fft_in => fft_in_hw,
            fft_out => fft_out_hw,
            fft_st => fft_st_hw
    );
        
    buffer_inst : buffer32
        port map (
            clk => clk_buff,
            rst => rst_buff,
            wren => wren_buff,
            buffer_in => buffer_in_buff,
            buffer_out => buffer_out_buff
    );

    fft_inst : fft
        port map (
            clk => clk_fft,
            rst => rst_fft,
            stage => stage_fft,
            data_in => data_in_fft,
            data_out => data_out_fft
    );

    -- Clock and reset
    clk_hw <= clk;
    rst_hw <= rst;
    clk_fft <= clk;
    rst_fft <= rst;
    clk_buff <= clk;
    rst_buff <= rst;

    -- UserHW Avalon slave interface
    addr_hw <= addr;
    data_in_hw <= data_in;
    data_out <= data_out_hw;
    wr_en_hw <= wr_en;
    rd_en_hw <= rd_en;
    cs_hw <= cs;

    -- UserHW <-> Buffer
    buffer_in_buff <= buffer_in_hw;
    buffer_out_hw <= buffer_out_buff;
    wren_buff <= buffer_wren_hw;

    -- UserHW <-> FFT
    data_in_fft <= fft_in_hw;
    fft_out_hw <= data_out_fft;
    stage_fft <= fft_st_hw;
    
end architecture rtl;
