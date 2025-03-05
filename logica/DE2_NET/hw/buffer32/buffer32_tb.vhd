library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.utils_pkg.all;

entity buffer32_tb is
end buffer32_tb;

architecture tb_arch of buffer32_tb is
    component buffer32 is
        port (
            clk        : in std_logic;
            rst        : in std_logic;
            wren       : in std_logic_vector(31 downto 0);
            buffer_in  : in stdlv32_array(31 downto 0);
            buffer_out : out stdlv32_array(31 downto 0)
        );
    end component;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal wren : std_logic_vector(31 downto 0);
    signal data_in : stdlv32_array(31 downto 0);
    signal data_out : stdlv32_array(31 downto 0);

    constant clk_period : time := 10 ns;

begin
    uut: buffer32
    port map (
        clk => clk,
        rst => rst,
        wren => wren,
        buffer_in => data_in,
        buffer_out => data_out
    );

    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    rst_process: process
    begin
        rst <= '1';
        wait for 2*clk_period;
        rst <= '0';
        wait;
    end process;

    -- Stimulus process
    stimulus_process: process
    begin
        -- Reset
        wait for 2*clk_period;

        -- Write data
        for i in 0 to 31 loop
            wren <= std_logic_vector(to_unsigned(2**i, 32));
            data_in(i) <= std_logic_vector(to_unsigned(i, 32));
            wait for clk_period;
            wren <= std_logic_vector(to_unsigned(0, 32));
            wait for clk_period;
        end loop;

        -- Write at the same time
        wren <= (others => '1');
        data_in <= (others => (others => '1'));
        wait for clk_period;
        wren <= (others => '0');
        wait for clk_period;

        wait;
    end process;

end tb_arch;