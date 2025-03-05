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

entity AES_decypher_tb is
end entity;

--------------------------------------------------------------------------------------

architecture a_AES_decypher_tb of AES_decypher_tb is

--------------------------------------------------------------------------------------

component AES_decypher is
   port(
		clock       : in std_logic;
		reset       : in std_logic;
		key         : in std_logic_vector (127 downto 0);
		input_text  : in std_logic_vector (127 downto 0);
		output_text : out std_logic_vector (127 downto 0);
		finished    : out std_logic
	); 
end component;

--------------------------------------------------------------------------------------

signal clock, reset	: std_logic;
signal key 				: std_logic_vector (127 downto 0);
signal input_text		: std_logic_vector (127 downto 0);
signal output_text 	: std_logic_vector (127 downto 0);
signal finished   	: std_logic;

constant clk_period : time := 40 ns;


--------------------------------------------------------------------------------------

begin

DUT: AES_decypher
	port map(
	   clock       => clock,
		reset       => reset,
		key         => key,
		input_text  => input_text,
		output_text => output_text,
		finished    => finished
	);

--------------------------------------------------------------------------------------

process
	begin
		input_text <= x"320b6a19978511dcfb09dc021d842539";
		
		key <= x"a60c63b6c80c3fe18925eec9a8f914d0";
		
		reset <= '1';
		
		wait for clk_period;
		
		reset <= '0';
		
		wait until finished = '1';
		
		wait for clk_period/2;
		
		if (output_text = x"340737e0a29831318d305a88a8f64332") then
			report "---------- Passed ----------";
		else
			report "---------- Failed ----------";
		end if;
		
		report "---------- Output must be: -------";
		
		report "340737e0a29831318d305a88a8f64332"	;
		
		input_text <= x"2e2b34ca59fa4c883b2c8aefd44be966";
		
		key <= x"8e188f6fcf51e92311e2923ecb5befb4";
		
		reset <= '1';
		
		wait for clk_period * 1;
		
		reset <= '0';
		
		wait until finished = '1';
		
		wait for clk_period/2;
		
		if (output_text =  x"00000000000000000000000000000000") then
			report "---------- Passed ----------";
		else
			report "---------- Failed ----------";
		end if;
		
		report "---------- Output must be: -------";
		
		report  "00000000000000000000000000000000";
		
		wait;
end process;

clk_gen: process
begin 
	clock <= '0';
	wait for clk_period/2;
	clock <= '1';
	wait for clk_period/2;
end process;

end architecture a_AES_decypher_tb;