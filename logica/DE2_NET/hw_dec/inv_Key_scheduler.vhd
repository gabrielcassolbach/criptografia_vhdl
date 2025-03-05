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

entity inv_Key_scheduler is
   port(
		clock          : in  std_logic;
		reset          : in  std_logic;
		round_constant : in  std_logic_vector(7 downto 0);
		input_key      : in  std_logic_vector (127 downto 0);
		output_key     : out std_logic_vector (127 downto 0)
	); 
end entity;

--------------------------------------------------------------------------------------

architecture a_inv_Key_scheduler of inv_Key_scheduler is

--------------------------------------------------------------------------------------

component Reg is
    generic (
        size: positive
    );
    port (
        clock: in std_logic;
		  enable: in std_logic;
        input: in std_logic_vector(size - 1 downto 0);
        output: out std_logic_vector(size - 1 downto 0)
    );
end component;

component inv_Round_key_calculator is
   port(
		input_key      : in  std_logic_vector (127 downto 0);
		round_constant : in std_logic_vector(7 downto 0);
		output_key     : out std_logic_vector (127 downto 0)
	); 
end component;

--------------------------------------------------------------------------------------

signal reg_input : std_logic_vector (127 downto 0);
signal reg_output: std_logic_vector (127 downto 0);
signal round_key : std_logic_vector (127 downto 0);

signal permanent_enable : std_logic;
--------------------------------------------------------------------------------------

begin

permanent_enable <= '1';

reg_input <= input_key when reset = '1' else round_key;
	
reg_inst : reg
generic map(
	size => 128
)
port map(
	clock  => clock,
	enable => permanent_enable,
	input  => reg_input,
	output => reg_output
);	

inv_round_key_calculator_inst : inv_round_key_calculator
port map(
	input_key  => reg_output,
	round_constant  => round_constant,
	output_key => round_key
);	

output_key <= reg_output;
	

end architecture a_inv_Key_scheduler;