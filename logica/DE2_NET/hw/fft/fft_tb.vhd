library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;

entity fft_tb is
end entity;

architecture rtl of fft_tb is
    component fft is
        port (
            stage : in std_logic_vector(2 downto 0);
            data_in : in complex_array(0 to 31);
            data_out : out complex_array(0 to 31)
        );
    end component;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal data_in : complex_array(0 to 31);
    signal data_out : complex_array(0 to 31);

    constant data : complex_array(0 to 31) := (
        cmplx(0.0, 0.0),       cmplx(-0.032258, 0.0),  cmplx(0.064516, 0.0),  cmplx(-0.096774, 0.0),
        cmplx(0.129032, 0.0),  cmplx(-0.16129, 0.0),   cmplx(0.193548, 0.0),  cmplx(-0.225806, 0.0),
        cmplx(0.258065, 0.0),  cmplx(-0.290323, 0.0),  cmplx(0.322581, 0.0),  cmplx(-0.354839, 0.0),
        cmplx(0.387097, 0.0),  cmplx(-0.419355, 0.0),  cmplx(0.451613, 0.0),  cmplx(-0.483871, 0.0),
        cmplx(0.516129, 0.0),  cmplx(-0.548387, 0.0),  cmplx(0.580645, 0.0),  cmplx(-0.612903, 0.0),
        cmplx(0.645161, 0.0),  cmplx(-0.677419, 0.0),  cmplx(0.709677, 0.0),  cmplx(-0.741935, 0.0),
        cmplx(0.774194, 0.0),  cmplx(-0.806452, 0.0),  cmplx(0.83871, 0.0),   cmplx(-0.870968, 0.0),
        cmplx(0.903226, 0.0),  cmplx(-0.935484, 0.0),  cmplx(0.967742, 0.0),  cmplx(-1.0, 0.0)
    );

    signal data_out_s1 : complex_array(0 to 31);
    signal data_out_s2 : complex_array(0 to 31);
    signal data_out_s3 : complex_array(0 to 31);
    signal data_out_s4 : complex_array(0 to 31);
    signal data_out_s5 : complex_array(0 to 31);

    signal stage : std_logic_vector(2 downto 0) := "000";

    constant clk_period : time := 10 ns;

begin
    uut : fft
        port map (
            stage => stage,
            data_in => data_in,
            data_out => data_out
        );

    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    rst_process : process
    begin
        rst <= '1';
        wait for 2 * clk_period;
        rst <= '0';
        wait;
    end process;

    process
    begin
        wait for 3 * clk_period;

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

        stage <= "000";
        data_in <= data;
        wait for 3 * clk_period;

        stage <= "001";
        data_in <= data;
        wait for clk_period;
        data_out_s1 <= data_out;

        wait for 2 * clk_period;

        stage <= "010";
        data_in <= data_out_s1;
        wait for clk_period;
        data_out_s2 <= data_out;

        wait for 2 * clk_period;

        stage <= "011";
        data_in <= data_out_s2;
        wait for clk_period;
        data_out_s3 <= data_out;

        wait for 2 * clk_period;

        stage <= "100";
        data_in <= data_out_s3;
        wait for clk_period;
        data_out_s4 <= data_out;

        wait for 2 * clk_period;

        stage <= "101";
        data_in <= data_out_s4;
        wait for clk_period;
        data_out_s5 <= data_out;

        wait for 2 * clk_period;

        stage <= "000";
        wait for clk_period;
        
        wait;
    end process;
        
end architecture rtl;