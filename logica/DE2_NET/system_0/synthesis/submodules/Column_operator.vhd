-- ==============================================
-- PROJETO FINAL
-- Lógica Reconfigurável - CSW42 - S71 - 2023/1
-- Jhonny Kristyan Vaz-Tostes de Assis - 2126672
-- João Vitor Dotto Rissardi - 2126699
-- Baseado em: https://github.com/hadipourh/AES-VHDL/blob/ee6c114ac4ce1ccefcb4f44099a88ca31714fd1f/AES-ENC/RTL/column_calculator.vhd
-- ==============================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------------------------------------------------------

entity Column_operator is
	port (
		input_column : in std_logic_vector(31 downto 0);
		output_column: out std_logic_vector(31 downto 0)
	);
end entity;

--------------------------------------------------------------------------------------

architecture a_Column_operator of Column_operator is

--------------------------------------------------------------------------------------

component Gf_mult_2 is
	port (
		input_byte : in std_logic_vector(7 downto 0);
		output_byte : out std_logic_vector(7 downto 0)
	);
end component;

--------------------------------------------------------------------------------------

	signal temp : std_logic_vector(7 downto 0);
	signal temp0 : std_logic_vector(7 downto 0);
	signal temp1 : std_logic_vector(7 downto 0);
	signal temp2 : std_logic_vector(7 downto 0);
	signal temp3 : std_logic_vector(7 downto 0);
	signal temp0x2 : std_logic_vector(7 downto 0);
	signal temp1x2 : std_logic_vector(7 downto 0);
	signal temp2x2 : std_logic_vector(7 downto 0);
	signal temp3x2 : std_logic_vector(7 downto 0);	
	
--------------------------------------------------------------------------------------
	
begin

	temp <= input_column(31 downto 24) xor input_column(23 downto 16) xor input_column(15 downto 8) xor input_column(7 downto 0);
	temp0 <= input_column(7 downto 0) xor input_column(15 downto 8);
	temp1 <= input_column(15 downto 8) xor input_column(23 downto 16);
	temp2 <= input_column(23 downto 16) xor input_column(31 downto 24);
	temp3 <= input_column(31 downto 24) xor input_column(7 downto 0);
	
	Gf_mult_2_inst0 : Gf_mult_2
		port map(
			input_byte  => temp0,
			output_byte => temp0x2
		);
	Gf_mult_2_inst1 : Gf_mult_2
		port map(
			input_byte  => temp1,
			output_byte => temp1x2
		);
	Gf_mult_2_inst2 : Gf_mult_2
		port map(
			input_byte  => temp2,
			output_byte => temp2x2
		);
	Gf_mult_2_inst3 : Gf_mult_2
		port map(
			input_byte  => temp3,
			output_byte => temp3x2
		);
		
	output_column(7 downto 0) <= input_column(7 downto 0) xor temp0x2 xor temp;
	output_column(15 downto 8) <= input_column(15 downto 8) xor temp1x2 xor temp;
	output_column(23 downto 16) <= input_column(23 downto 16) xor temp2x2 xor temp;
	output_column(31 downto 24) <= input_column(31 downto 24) xor temp3x2 xor temp; 	
	
end architecture a_Column_operator;