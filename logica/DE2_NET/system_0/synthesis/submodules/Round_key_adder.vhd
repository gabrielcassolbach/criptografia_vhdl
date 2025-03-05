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

entity Round_key_adder is
   port(
		input_block  : in  std_logic_vector (127 downto 0);
		round_key    : in  std_logic_vector	(127 downto 0);
		output_block : out std_logic_vector (127 downto 0)
	); 
end entity;

--------------------------------------------------------------------------------------

architecture a_Round_key_adder of Round_key_adder is

--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------

begin
		
	output_block <= input_block xor round_key;

end architecture a_Round_key_adder;