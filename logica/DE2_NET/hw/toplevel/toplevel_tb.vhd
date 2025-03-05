library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fixed_pkg.all;
use ieee.float_pkg.all;
use work.utils_pkg.all;

entity toplevel_tb is
end entity;

architecture rtl of toplevel_tb is


    component toplevel is
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
    end component;
    
    signal clk: std_logic := '0';
    signal rst: std_logic := '0';
    signal data_in: std_logic_vector(31 downto 0) := (others => '0');
    signal data_out: std_logic_vector(31 downto 0);
    signal wr_en: std_logic := '0';
    signal rd_en: std_logic := '0';
    signal cs: std_logic := '0';
    signal addr: std_logic_vector(2 downto 0) := (others => '0');

    constant CLK_PERIOD : time := 10 ns;

        -- -- Inputs -- --
        -- 0.0             -0.032258       0.064516        -0.096774
        -- 0.129032        -0.16129        0.193548        -0.225806
        -- 0.258065        -0.290323       0.322581        -0.354839
        -- 0.387097        -0.419355       0.451613        -0.483871
        -- 0.516129        -0.548387       0.580645        -0.612903
        -- 0.645161        -0.677419       0.709677        -0.741935
        -- 0.774194        -0.806452       0.83871         -0.870968
        -- 0.903226        -0.935484       0.967742        -1.0
        -- -- Expected outputs -- --
        -- -0.516128+0.0j          -0.516129-0.050834j     -0.51613-0.102665j      -0.516129-0.156566j
        -- -0.516128-0.213787j     -0.516129-0.275877j     -0.51613-0.344867j      -0.516129-0.423576j
        -- -0.516128-0.516128j     -0.516129-0.628905j     -0.51613-0.772443j      -0.516129-0.965609j
        -- -0.516128-1.246043j     -0.516129-1.701449j     -0.51613-2.594761j      -0.516129-5.240346j
        -- 16.0+0.0j               -0.516129+5.240346j     -0.51613+2.594761j      -0.516129+1.701449j
        -- -0.516128+1.246043j     -0.516129+0.965609j     -0.51613+0.772443j      -0.516129+0.628905j
        -- -0.516128+0.516128j     -0.516129+0.423576j     -0.51613+0.344867j      -0.516129+0.275877j
        -- -0.516128+0.213787j     -0.516129+0.156566j     -0.51613+0.102665j      -0.516129+0.050834j

        constant INPUTS : stdlv32_array(31 downto 0) := (
            std_logic_vector(to_signed(0, 16)) & std_logic_vector(to_sfixed(0.0, 6, -9)),
            std_logic_vector(to_signed(0, 16)) & std_logic_vector(to_sfixed(-0.032258, 6, -9)),
            std_logic_vector(to_signed(0, 16)) & std_logic_vector(to_sfixed(0.064516, 6, -9)),
            std_logic_vector(to_signed(0, 16)) & std_logic_vector(to_sfixed(-0.096774, 6, -9)),
            std_logic_vector(to_signed(0, 16)) & std_logic_vector(to_sfixed(0.129032, 6, -9)),
            std_logic_vector(to_signed(0, 16)) & std_logic_vector(to_sfixed(-0.16129, 6, -9)),
            std_logic_vector(to_signed(0, 16)) & std_logic_vector(to_sfixed(0.193548, 6, -9)),
            std_logic_vector(to_signed(0, 16)) & std_logic_vector(to_sfixed(-0.225806, 6, -9)),
            std_logic_vector(to_signed(0, 16)) & std_logic_vector(to_sfixed(0.258065, 6, -9)),
            std_logic_vector(to_signed(0, 16)) & std_logic_vector(to_sfixed(-0.290323, 6, -9)),
            std_logic_vector(to_signed(0, 16)) & std_logic_vector(to_sfixed(0.322581, 6, -9)),
            std_logic_vector(to_signed(0, 16)) & std_logic_vector(to_sfixed(-0.354839, 6, -9)),
            std_logic_vector(to_signed(0, 16)) & std_logic_vector(to_sfixed(0.387097, 6, -9)),
            std_logic_vector(to_signed(0, 16)) & std_logic_vector(to_sfixed(-0.419355, 6, -9)),
            std_logic_vector(to_signed(0, 16)) & std_logic_vector(to_sfixed(0.451613, 6, -9)),
            std_logic_vector(to_signed(0, 16)) & std_logic_vector(to_sfixed(-0.483871, 6, -9)),
            std_logic_vector(to_signed(0, 16)) & std_logic_vector(to_sfixed(0.516129, 6, -9)),
            std_logic_vector(to_signed(0, 16)) & std_logic_vector(to_sfixed(-0.548387, 6, -9)),
            std_logic_vector(to_signed(0, 16)) & std_logic_vector(to_sfixed(0.580645, 6, -9)),
            std_logic_vector(to_signed(0, 16)) & std_logic_vector(to_sfixed(-0.612903, 6, -9)),
            std_logic_vector(to_signed(0, 16)) & std_logic_vector(to_sfixed(0.645161, 6, -9)),
            std_logic_vector(to_signed(0, 16)) & std_logic_vector(to_sfixed(-0.677419, 6, -9)),
            std_logic_vector(to_signed(0, 16)) & std_logic_vector(to_sfixed(0.709677, 6, -9)),
            std_logic_vector(to_signed(0, 16)) & std_logic_vector(to_sfixed(-0.741935, 6, -9)),
            std_logic_vector(to_signed(0, 16)) & std_logic_vector(to_sfixed(0.774194, 6, -9)),
            std_logic_vector(to_signed(0, 16)) & std_logic_vector(to_sfixed(-0.806452, 6, -9)),
            std_logic_vector(to_signed(0, 16)) & std_logic_vector(to_sfixed(0.83871, 6, -9)),
            std_logic_vector(to_signed(0, 16)) & std_logic_vector(to_sfixed(-0.870968, 6, -9)),
            std_logic_vector(to_signed(0, 16)) & std_logic_vector(to_sfixed(0.903226, 6, -9)),
            std_logic_vector(to_signed(0, 16)) & std_logic_vector(to_sfixed(-0.935484, 6, -9)),
            std_logic_vector(to_signed(0, 16)) & std_logic_vector(to_sfixed(0.967742, 6, -9)),
            std_logic_vector(to_signed(0, 16)) & std_logic_vector(to_sfixed(-1.0, 6, -9))
        );

    constant OUTPUTS : stdlv32_array(31 downto 0) := (
            std_logic_vector(to_sfixed(0.0, 6, -9)) & std_logic_vector(to_sfixed(-0.516128, 6, -9)),
            std_logic_vector(to_sfixed(-0.050834, 6, -9)) & std_logic_vector(to_sfixed(-0.516129, 6, -9)),
            std_logic_vector(to_sfixed(-0.102665, 6, -9)) & std_logic_vector(to_sfixed(-0.51613, 6, -9)),
            std_logic_vector(to_sfixed(-0.156566, 6, -9)) & std_logic_vector(to_sfixed(-0.516129, 6, -9)),
            std_logic_vector(to_sfixed(-0.213787, 6, -9)) & std_logic_vector(to_sfixed(-0.516128, 6, -9)),
            std_logic_vector(to_sfixed(-0.275877, 6, -9)) & std_logic_vector(to_sfixed(-0.516129, 6, -9)),
            std_logic_vector(to_sfixed(-0.344867, 6, -9)) & std_logic_vector(to_sfixed(-0.51613, 6, -9)),
            std_logic_vector(to_sfixed(-0.423576, 6, -9)) & std_logic_vector(to_sfixed(-0.516129, 6, -9)),
            std_logic_vector(to_sfixed(-0.516128, 6, -9)) & std_logic_vector(to_sfixed(-0.516128, 6, -9)),
            std_logic_vector(to_sfixed(-0.628905, 6, -9)) & std_logic_vector(to_sfixed(-0.516129, 6, -9)),
            std_logic_vector(to_sfixed(-0.772443, 6, -9)) & std_logic_vector(to_sfixed(-0.51613, 6, -9)),
            std_logic_vector(to_sfixed(-0.965609, 6, -9)) & std_logic_vector(to_sfixed(-0.516129, 6, -9)),
            std_logic_vector(to_sfixed(-1.246043, 6, -9)) & std_logic_vector(to_sfixed(-0.516128, 6, -9)),
            std_logic_vector(to_sfixed(-1.701449, 6, -9)) & std_logic_vector(to_sfixed(-0.516129, 6, -9)),
            std_logic_vector(to_sfixed(-2.594761, 6, -9)) & std_logic_vector(to_sfixed(-0.51613, 6, -9)),
            std_logic_vector(to_sfixed(-5.240346, 6, -9)) & std_logic_vector(to_sfixed(-0.516129, 6, -9)),
            std_logic_vector(to_sfixed(0.0, 6, -9)) & std_logic_vector(to_sfixed(16.0, 6, -9)),
            std_logic_vector(to_sfixed(5.240346, 6, -9)) & std_logic_vector(to_sfixed(-0.516129, 6, -9)),
            std_logic_vector(to_sfixed(2.594761, 6, -9)) & std_logic_vector(to_sfixed(-0.51613, 6, -9)),
            std_logic_vector(to_sfixed(1.701449, 6, -9)) & std_logic_vector(to_sfixed(-0.516129, 6, -9)),
            std_logic_vector(to_sfixed(1.246043, 6, -9)) & std_logic_vector(to_sfixed(-0.516128, 6, -9)),
            std_logic_vector(to_sfixed(0.965609, 6, -9)) & std_logic_vector(to_sfixed(-0.516129, 6, -9)),
            std_logic_vector(to_sfixed(0.772443, 6, -9)) & std_logic_vector(to_sfixed(-0.51613, 6, -9)),
            std_logic_vector(to_sfixed(0.628905, 6, -9)) & std_logic_vector(to_sfixed(-0.516129, 6, -9)),
            std_logic_vector(to_sfixed(0.516128, 6, -9)) & std_logic_vector(to_sfixed(-0.516128, 6, -9)),
            std_logic_vector(to_sfixed(0.423576, 6, -9)) & std_logic_vector(to_sfixed(-0.516129, 6, -9)),
            std_logic_vector(to_sfixed(0.344867, 6, -9)) & std_logic_vector(to_sfixed(-0.51613, 6, -9)),
            std_logic_vector(to_sfixed(0.275877, 6, -9)) & std_logic_vector(to_sfixed(-0.516129, 6, -9)),
            std_logic_vector(to_sfixed(0.213787, 6, -9)) & std_logic_vector(to_sfixed(-0.516128, 6, -9)),
            std_logic_vector(to_sfixed(0.156566, 6, -9)) & std_logic_vector(to_sfixed(-0.516129, 6, -9)),
            std_logic_vector(to_sfixed(0.102665, 6, -9)) & std_logic_vector(to_sfixed(-0.51613, 6, -9)),
            std_logic_vector(to_sfixed(0.050834, 6, -9)) & std_logic_vector(to_sfixed(-0.516129, 6, -9))
        );

    signal output_s : std_logic_vector(31 downto 0);

    signal curr_out : complex_t;
    signal curr_real_out : complex_t;

begin

    uut: toplevel
    port map (
        clk         => clk,
        rst         => rst,
        data_in     => data_in,
        data_out    => data_out,
        wr_en       => wr_en,
        rd_en       => rd_en,
        cs          => cs,
        addr        => addr
    );

    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    rst_process: process
    begin
        rst <= '1';
        wait for CLK_PERIOD*2;
        rst <= '0';
        wait;
    end process;

    main_process: process
    begin
        wait for CLK_PERIOD*4;
        
        -- WRITING
        for i in 0 to 31 loop
            -- Data in
            cs <= '1';
            wr_en <= '1';
            data_in <= INPUTS(i);
            addr <= std_logic_vector(to_unsigned(0, 3));
            wait for CLK_PERIOD * 2;

            cs <= '0';
            wr_en <= '0';
            wait for CLK_PERIOD * 2;

            -- Address
            cs <= '1';
            wr_en <= '1';
            data_in <= std_logic_vector(to_unsigned(i, 32));
            addr <= std_logic_vector(to_unsigned(2, 3));
            wait for CLK_PERIOD * 2;

            cs <= '0';
            wr_en <= '0';
            wait for CLK_PERIOD * 2;

            -- Commit
            cs <= '1';
            wr_en <= '1';
            data_in <= std_logic_vector(to_unsigned(1, 32));
            addr <= std_logic_vector(to_unsigned(3, 3));
            wait for CLK_PERIOD * 2;

            cs <= '0';
            wr_en <= '0';
            wait for CLK_PERIOD * 2;

            wait for CLK_PERIOD * 3;
        end loop;

        wait for CLK_PERIOD * 5;

        -- READING
        for i in 0 to 31 loop
            -- Address
            cs <= '1';
            wr_en <= '1';
            data_in <= std_logic_vector(to_unsigned(i, 32));
            addr <= std_logic_vector(to_unsigned(2, 3));
            wait for CLK_PERIOD * 2;

            cs <= '0';
            wr_en <= '0';
            wait for CLK_PERIOD * 2;

            -- Data out
            cs <= '1';
            rd_en <= '1';
            addr <= std_logic_vector(to_unsigned(1, 3));
            output_s <= OUTPUTS(i);
            wait for CLK_PERIOD * 2;

            cs <= '0';
            rd_en <= '0';
            wait for CLK_PERIOD * 2;

            wait for CLK_PERIOD * 3;
        end loop;

        wait for CLK_PERIOD * 5;

        -- TRIGGER FFT
        for i in 1 to 5 loop
            cs <= '1';
            wr_en <= '1';
            data_in <= std_logic_vector(to_unsigned(i, 32));
            addr <= std_logic_vector(to_unsigned(4, 3));
            wait for CLK_PERIOD * 2;

            cs <= '0';
            wr_en <= '0';
            wait for CLK_PERIOD * 3;
            
            cs <= '1';
            wr_en <= '1';
            data_in <= std_logic_vector(to_unsigned(6, 32));
            addr <= std_logic_vector(to_unsigned(4, 3));
            wait for CLK_PERIOD * 2;

            cs <= '0';
            wr_en <= '0';
            wait for CLK_PERIOD * 3;

            wait for CLK_PERIOD * 3;
        end loop;

        cs <= '0';
        wr_en <= '0';
        wait for CLK_PERIOD * 2;

        wait for CLK_PERIOD * 5;

        -- READING
        for i in 0 to 31 loop
            -- Address
            cs <= '1';
            wr_en <= '1';
            data_in <= std_logic_vector(to_unsigned(i, 32));
            addr <= std_logic_vector(to_unsigned(2, 3));
            wait for CLK_PERIOD * 2;

            cs <= '0';
            wr_en <= '0';
            wait for CLK_PERIOD * 2;

            -- Data out
            cs <= '1';
            rd_en <= '1';
            addr <= std_logic_vector(to_unsigned(1, 3));
            output_s <= OUTPUTS(i);
            curr_out <= cmplx(to_sfixed(data_out(15 downto 0), 6, -9), to_sfixed(data_out(31 downto 16), 6, -9));
            curr_real_out <= cmplx(to_sfixed(output_s(15 downto 0), 6, -9), to_sfixed(output_s(31 downto 16), 6, -9));
            wait for CLK_PERIOD * 2;

            cs <= '0';
            rd_en <= '0';
            wait for CLK_PERIOD * 2;

            wait for CLK_PERIOD * 3;
        end loop;
        wait for CLK_PERIOD * 5;

        wait;
    end process;

end architecture rtl;
