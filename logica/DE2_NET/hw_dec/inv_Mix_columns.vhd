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

entity inv_Mix_columns is
   port(
		input_block  : in  std_logic_vector (127 downto 0);
		output_block : out std_logic_vector (127 downto 0)
	); 
end entity;

--------------------------------------------------------------------------------------

architecture a_inv_Mix_columns of inv_Mix_columns is

--------------------------------------------------------------------------------------

component inv_Column_operator is
	port (
		input_column : in std_logic_vector(31 downto 0);
		output_column: out std_logic_vector(31 downto 0)
	);
end component;

--------------------------------------------------------------------------------------

begin

generate_column_operators:
    for i in 0 to 4 - 1 generate
        inv_column_operator_x: inv_Column_operator
        port map(input_column => input_block((32*(i+1))-1 downto 32*i), output_column => output_block((32*(i+1))-1 downto 32*i));
    end generate generate_column_operators;

end architecture a_inv_Mix_columns;