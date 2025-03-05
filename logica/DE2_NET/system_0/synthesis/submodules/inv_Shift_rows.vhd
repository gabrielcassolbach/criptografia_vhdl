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

entity inv_Shift_rows is
   port(
		input_block  : in  std_logic_vector (127 downto 0);
		output_block : out std_logic_vector (127 downto 0)
	); 
end entity;

--------------------------------------------------------------------------------------

architecture a_inv_Shift_rows of inv_Shift_rows is

--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------

begin
	
	output_block(8*16 - 1 downto 8*15) <= input_block(8*4 - 1 downto 8*3);
	output_block(8*15 - 1 downto 8*14) <= input_block(8*7 - 1 downto 8*6);
	output_block(8*14 - 1 downto 8*13) <= input_block(8*10 - 1 downto 8*9);
	output_block(8*13 - 1 downto 8*12) <= input_block(8*13 - 1 downto 8*12);
	output_block(8*12 - 1 downto 8*11) <= input_block(8*16 - 1 downto 8*15);
	output_block(8*11 - 1 downto 8*10) <= input_block(8*3 - 1 downto 8*2);
	output_block(8*10 - 1 downto 8*9)  <= input_block(8*6 - 1 downto 8*5);
	output_block(8*9 - 1 downto 8*8)   <= input_block(8*9 - 1 downto 8*8);
	output_block(8*8 - 1 downto 8*7)   <= input_block(8*12 - 1 downto 8*11);
	output_block(8*7 - 1 downto 8*6)   <= input_block(8*15 - 1 downto 8*14);
	output_block(8*6 - 1 downto 8*5)   <= input_block(8*2 - 1 downto 8*1);
	output_block(8*5 - 1 downto 8*4)   <= input_block(8*5 - 1 downto 8*4);
	output_block(8*4 - 1 downto 8*3)   <= input_block(8*8 - 1 downto 8*7);
	output_block(8*3 - 1 downto 8*2)   <= input_block(8*11 - 1 downto 8*10);
	output_block(8*2 - 1 downto 8*1)   <= input_block(8*14 - 1 downto 8*13);
	output_block(8*1 - 1 downto 8*0)   <= input_block(8*1 - 1 downto 8*0);

end architecture a_inv_Shift_rows;