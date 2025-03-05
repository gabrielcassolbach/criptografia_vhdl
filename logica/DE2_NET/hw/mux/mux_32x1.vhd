library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;

entity mux_32x1 is
    port(
        i : in stdlv32_array(31 downto 0);
        s : in std_logic_vector(4 downto 0);
        o : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of mux_32x1 is
    signal osig : std_logic_vector(31 downto 0);
begin
    osig <= i(0) when s = "00000" else
            i(1) when s = "00001" else
            i(2) when s = "00010" else
            i(3) when s = "00011" else
            i(4) when s = "00100" else
            i(5) when s = "00101" else
            i(6) when s = "00110" else
            i(7) when s = "00111" else
            i(8) when s = "01000" else
            i(9) when s = "01001" else
            i(10) when s = "01010" else
            i(11) when s = "01011" else
            i(12) when s = "01100" else
            i(13) when s = "01101" else
            i(14) when s = "01110" else
            i(15) when s = "01111" else
            i(16) when s = "10000" else
            i(17) when s = "10001" else
            i(18) when s = "10010" else
            i(19) when s = "10011" else
            i(20) when s = "10100" else
            i(21) when s = "10101" else
            i(22) when s = "10110" else
            i(23) when s = "10111" else
            i(24) when s = "11000" else
            i(25) when s = "11001" else
            i(26) when s = "11010" else
            i(27) when s = "11011" else
            i(28) when s = "11100" else
            i(29) when s = "11101" else
            i(30) when s = "11110" else
            i(31) when s = "11111" else
            (others => 'X');
    
    o <= osig;

end architecture;
