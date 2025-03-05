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

entity inv_Round_key_calculator is
   port(
		input_key      : in  std_logic_vector (127 downto 0);
		round_constant : in std_logic_vector(7 downto 0);
		output_key     : out std_logic_vector (127 downto 0)
	); 
end entity;

--------------------------------------------------------------------------------------

architecture a_inv_Round_key_calculator of inv_Round_key_calculator is

--------------------------------------------------------------------------------------

component Sbox is
   port(
		input_byte  : in  std_logic_vector (7 downto 0);
		output_byte : out std_logic_vector (7 downto 0)
	); 
end component;

--------------------------------------------------------------------------------------

signal sub_word_key: std_logic_vector (31 downto 0);
signal rot_word_key: std_logic_vector(31 downto 0);
signal w3, w2, w1, w0 : std_logic_vector(31 downto 0);

--------------------------------------------------------------------------------------

begin

	w3 <= input_key(127 downto 96) xor input_key(95 downto 64);
	w2 <= input_key(95 downto 64) xor input_key(63 downto 32);
	w1 <= input_key(63 downto 32) xor input_key(31 downto 0);
	
	rot_word_key <= w3(7 downto 0) & w3(31 downto 8);
	
	generate_sboxes:
    for i in 0 to 4 - 1 generate
        sbox_x: Sbox
        port map(input_byte => rot_word_key((8*(i+1))-1 downto 8*i), output_byte => sub_word_key((8*(i+1))-1 downto 8*i));
    end generate generate_sboxes;
	
	w0(31 downto 8) <= input_key(31 downto 8) xor sub_word_key(31 downto 8);
	w0(7 downto 0)  <= input_key(7 downto 0) xor round_constant xor sub_word_key(7 downto 0);

	output_key <= w3 & w2 & w1 & w0;
	
end architecture a_inv_Round_key_calculator;