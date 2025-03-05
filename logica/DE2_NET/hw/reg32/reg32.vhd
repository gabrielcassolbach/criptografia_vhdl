library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg32 is
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        wren    : in  std_logic;
        data_in : in  std_logic_vector(31 downto 0);
        q       : out std_logic_vector(31 downto 0)
    );
end entity reg32;

architecture rtl of reg32 is
begin
    process(clk, rst)
    begin
        if rst = '1' then
            q <= (others => '0');
        elsif rising_edge(clk) then
            if wren = '1' then
                q <= data_in;
            end if;
        end if;
    end process;
end rtl;