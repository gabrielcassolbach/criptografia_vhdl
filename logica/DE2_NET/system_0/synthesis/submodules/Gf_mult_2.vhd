-- ==============================================
-- PROJETO FINAL
-- Lógica Reconfigurável - CSW42 - S71 - 2023/1
-- Jhonny Kristyan Vaz-Tostes de Assis - 2126672
-- João Vitor Dotto Rissardi - 2126699
-- Baseado em: https://github.com/hadipourh/AES-VHDL/blob/ee6c114ac4ce1ccefcb4f44099a88ca31714fd1f/AES-ENC/RTL/gfmult_by2.vhd
-- ==============================================

library ieee;
use ieee.std_logic_1164.all;

--------------------------------------------------------------------------------------

entity Gf_mult_2 is
	port (
		input_byte : in std_logic_vector(7 downto 0);
		output_byte : out std_logic_vector(7 downto 0)
	);
end entity;

--------------------------------------------------------------------------------------

architecture a_Gf_mult_2 of Gf_mult_2 is

--------------------------------------------------------------------------------------

	signal shifted_byte : std_logic_vector(7 downto 0);
	signal conditional_xor : std_logic_vector(7 downto 0);
	
--------------------------------------------------------------------------------------
	
begin

	shifted_byte <= input_byte(6 downto 0) & "0";
	conditional_xor <= "000" & input_byte(7) & input_byte(7) & "0" & input_byte(7) & input_byte(7);
	output_byte <= shifted_byte xor conditional_xor;
	
end architecture a_Gf_mult_2;
