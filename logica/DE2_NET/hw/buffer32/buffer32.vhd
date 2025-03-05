library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.utils_pkg.all;

entity buffer32 is
    port (
        clk        : in std_logic;
        rst        : in std_logic;
        wren       : in std_logic_vector(31 downto 0);
        buffer_in  : in stdlv32_array(31 downto 0);
        buffer_out : out stdlv32_array(31 downto 0)
    );
end buffer32;

architecture rtl of buffer32 is
    
    component reg32 is
        port (
            clk     : in  std_logic;
            rst     : in  std_logic;
            wren    : in  std_logic;
            data_in : in  std_logic_vector(31 downto 0);
            q       : out std_logic_vector(31 downto 0)
        );
    end component reg32;

begin

    reg_gen: for i in 0 to 31 generate
        reg_inst: reg32 port map (
            clk     => clk,
            rst     => rst,
            wren    => wren(i),
            data_in => buffer_in(i),
            q       => buffer_out(i)
        );
    end generate reg_gen;

end architecture rtl;
