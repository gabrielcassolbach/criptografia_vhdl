-- ==============================================
-- PROJETO FINAL
-- Lógica Reconfigurável - CSW42 - S71 - 2023/1
-- Jhonny Kristyan Vaz-Tostes de Assis - 2126672
-- João Vitor Dotto Rissardi - 2126699
-- ==============================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------------------------------------------------------

entity inv_Sub_bytes is
   port(
		input_block  : in  std_logic_vector (127 downto 0);
		output_block : out std_logic_vector (127 downto 0)
	); 
end entity;

--------------------------------------------------------------------------------------

architecture a_inv_Sub_bytes of inv_Sub_bytes is

--------------------------------------------------------------------------------------

component inv_Sbox is
   port(
		input_byte  : in  std_logic_vector (7 downto 0);
		output_byte : out std_logic_vector (7 downto 0)
	); 
end component;

--------------------------------------------------------------------------------------

begin

generate_sboxes:
    for i in 0 to 16 - 1 generate
        sbox_x: inv_Sbox
        port map(input_byte => input_block((8*(i+1))-1 downto 8*i), output_byte => output_block((8*(i+1))-1 downto 8*i));
    end generate generate_sboxes;

end architecture a_inv_Sub_bytes;