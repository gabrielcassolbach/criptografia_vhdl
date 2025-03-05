-- ==============================================
-- PROJETO FINAL
-- LÃ³gica ReconfigurÃ¡vel - CSW42 - S71 - 2023/1
-- Jhonny Kristyan Vaz-Tostes de Assis - 2126672
-- JoÃ£o Vitor Dotto Rissardi - 2126699
-- ==============================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------------------------------------------------------

entity AES_decypher is
   port(
		clock       : in std_logic;
		reset       : in std_logic;
		key         : in std_logic_vector (127 downto 0);
		input_text  : in std_logic_vector (127 downto 0);
		output_text : out std_logic_vector (127 downto 0);
		finished    : out std_logic
	); 
end entity;

--------------------------------------------------------------------------------------

architecture a_AES_decypher of AES_decypher is

--------------------------------------------------------------------------------------

component Reg is
    generic (
        size: positive
    );
    port (
        clock: in std_logic;
		  enable : in std_logic;
        input: in std_logic_vector(size - 1 downto 0);
        output: out std_logic_vector(size - 1 downto 0)
    );
end component;

component Round_key_adder is
   port(
		input_block  : in  std_logic_vector (127 downto 0);
		round_key    : in  std_logic_vector	(127 downto 0);
		output_block : out std_logic_vector (127 downto 0)
	); 
end component;


component inv_Sub_bytes is
   port(
		input_block  : in  std_logic_vector (127 downto 0);
		output_block : out std_logic_vector (127 downto 0)
	); 
end component;

component inv_Shift_rows is
   port(
		input_block  : in  std_logic_vector (127 downto 0);
		output_block : out std_logic_vector (127 downto 0)
	); 
end component;

component inv_Mix_columns is
   port(
		input_block  : in  std_logic_vector (127 downto 0);
		output_block : out std_logic_vector (127 downto 0)
	); 
end component;

component inv_Key_scheduler is
   port(
		clock          : in  std_logic;
		reset          : in  std_logic;
		round_constant : in  std_logic_vector(7 downto 0);
		input_key      : in  std_logic_vector (127 downto 0);
		output_key     : out std_logic_vector (127 downto 0)
	); 
end component;

component inv_Controller is
   port(
		clock 			: in std_logic;
		reset 			: in std_logic;
		round_constant : out std_logic_vector(7 downto 0);
		first_round		: out std_logic;
		finished			: out std_logic
	); 
end component;

--------------------------------------------------------------------------------------	

signal Reg_input				   : std_logic_vector (127 downto 0);
signal Reg_output					: std_logic_vector (127 downto 0);
signal Round_key_adder_output : std_logic_vector (127 downto 0);
signal shift_rows_input		   : std_logic_vector (127 downto 0);
signal shift_rows_output		: std_logic_vector (127 downto 0);
signal mix_columns_output		: std_logic_vector (127 downto 0);
signal round_key              : std_logic_vector (127 downto 0);
signal round_constant         : std_logic_vector (7   downto 0);
signal final_round_text			: std_logic_vector (127 downto 0);
signal first_round				: std_logic;

signal permanent_enable 		: std_logic;
--------------------------------------------------------------------------------------	
	
begin

permanent_enable <= '1';

Reg_input <= input_text when reset = '1' else final_round_text;

Reg_inst : Reg
	generic map (
		size => 128
	)
	port map (
		clock  => clock,
		enable => permanent_enable,
		input  => Reg_input,
		output => Reg_output
	);

Round_key_adder_inst : Round_key_adder
	port map (
		input_block  => Reg_output,
		round_key    => round_key,
		output_block => Round_key_adder_output
	);
	
mix_columns_inst : inv_mix_columns
	port map (
		input_block  => Round_key_adder_output,
		output_block => mix_columns_output
	);

shift_rows_input <= Round_key_adder_output when first_round = '1' else mix_columns_output;	
		
shift_rows_inst : inv_shift_rows
	port map (
		input_block  => shift_rows_input,
		output_block => shift_rows_output
	);		
	
sub_bytes_inst : inv_sub_bytes
	port map (
		input_block  => shift_rows_output,
		output_block => final_round_text
	);
	
inv_Key_scheduler_inst : inv_Key_scheduler
	port map (
		clock  => clock,
		reset => reset,
		round_constant => round_constant,
		input_key => key,
		output_key => round_key
	);	

inv_Controller_inst : inv_Controller
	port map (
		clock  => clock,
		reset => reset,
		round_constant => round_constant,
		first_round => first_round,
		finished => finished
	);	
	
output_text <= Round_key_adder_output;

	
end architecture a_AES_decypher;