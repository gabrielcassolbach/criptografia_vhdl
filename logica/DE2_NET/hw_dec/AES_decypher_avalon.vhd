
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

entity AES_decypher_avalon is
   port(
		  CLK : IN std_logic;
		  RST_N : IN std_logic;
		  READDATA : OUT std_logic_vector(31 downto 0);
		  WRITEDATA: IN std_logic_vector(31 downto 0); 
		  ADD : IN std_logic_vector(5 downto 0);
		  CS : IN std_logic; 
		  WR_EN : IN std_logic; 
		  RD_EN : IN std_logic 
	); 
end entity;

--------------------------------------------------------------------------------------

architecture a_AES_decypher_avalon of AES_decypher_avalon is

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

--------------------------------------------------------------------------------------	

signal decypher_input_text_regs_input	 : std_logic_vector(127 downto 0);
signal decypher_input_text_regs_output  : std_logic_vector(127 downto 0);

signal decypher_key_regs_input			 : std_logic_vector(127 downto 0);
signal decypher_key_regs_output 			 : std_logic_vector(127 downto 0);

signal decypher_output_text_regs_input	 : std_logic_vector(127 downto 0);
signal decypher_output_text_regs_output : std_logic_vector(127 downto 0);

signal decypher_finished					 : std_logic;
signal decypher_finished_reg_input	    : std_logic_vector(31 downto 0);
signal decypher_finished_reg_output	    : std_logic_vector(31 downto 0);
signal decypher_finished_reg_enable     : std_logic;

signal decypher_start_reg_input	    	 : std_logic_vector(0 downto 0);
signal decypher_start_reg_output	    	 : std_logic_vector(0 downto 0);

signal permanent_enable	: std_logic;	

signal reset : std_logic ;
--------------------------------------------------------------------------------------	
	
begin

decypher_finished_reg_enable <= '1' when (decypher_finished = '1' or decypher_start_reg_input = "1") else '0';
decypher_finished_reg_input <= "0000000000000000000000000000000" & decypher_finished;
permanent_enable <= '1';

Aes_decypher_inst: AES_decypher
port map(
	clock => CLK,
	reset => reset,
	key => decypher_key_regs_output,
	input_text => decypher_input_text_regs_output,
	output_text => decypher_output_text_regs_input,
	finished => decypher_finished
);

generate_input_text_regs:
    for i in 0 to 4 - 1 generate
        reg_input_x: Reg
			generic map (
				size => 32
			)
			port map(	
				clock  => CLK, 
				enable => permanent_enable,
				input  => decypher_input_text_regs_input(32*(i+1)-1 downto 32*i), 
				output => decypher_input_text_regs_output(32*(i+1)-1 downto 32*i)
			);
end generate generate_input_text_regs;

generate_key_regs:
    for i in 0 to 4 - 1 generate
        reg_key_x: Reg
			generic map (
				size => 32
			)
			port map(	
				clock  => CLK, 
				enable => permanent_enable,
				input  => decypher_key_regs_input(32*(i+1)-1 downto 32*i), 
				output => decypher_key_regs_output(32*(i+1)-1 downto 32*i)
			);
end generate generate_key_regs;

generate_output_text_regs:
    for i in 0 to 4 - 1 generate
        reg_output_x: Reg
			generic map (
				size => 32
			)
			port map(	
				clock  => CLK,
				enable => decypher_finished,
				input  => decypher_output_text_regs_input(32*(i+1)-1 downto 32*i), 
				output => decypher_output_text_regs_output(32*(i+1)-1 downto 32*i)
			);
end generate generate_output_text_regs;

reg_finished : reg
	generic map (
		size => 32
	)
	port map (
		clock  => CLK,
		enable => decypher_finished_reg_enable,
		input  => decypher_finished_reg_input,
		output => decypher_finished_reg_output
	);
	
reg_start : reg
	generic map (
		size => 1
	)
	port map (
		clock  => CLK,
		enable => permanent_enable,
		input  => decypher_start_reg_input,
		output => decypher_start_reg_output
	);

process(CLK)
begin
	if rising_edge(CLK) then
		-- Want to do a write operation
		if WR_EN = '1' and CS = '1' then
			READDATA <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
			if RST_N = '0' then
			elsif ADD = "000000" then -- decypher_input_text_regs_input 0
				decypher_input_text_regs_input(31 downto 0) <= WRITEDATA;
			elsif ADD = "000100" then -- decypher_input_text_regs_input 1
				decypher_input_text_regs_input(63 downto 32) <= WRITEDATA;
			elsif ADD = "001000" then -- decypher_input_text_regs_input 2
				decypher_input_text_regs_input(95 downto 64) <= WRITEDATA;
			elsif ADD = "001100" then -- decypher_input_text_regs_input 3
				decypher_input_text_regs_input(127 downto 96) <= WRITEDATA;
			elsif ADD = "010000" then -- decypher_key_regs_input 0
				decypher_key_regs_input(31 downto 0) <= WRITEDATA;
			elsif ADD = "010100" then -- decypher_key_regs_input 1
				decypher_key_regs_input(63 downto 32) <= WRITEDATA;
			elsif ADD = "011000" then -- decypher_key_regs_input 2
				decypher_key_regs_input(95 downto 64) <= WRITEDATA;
			elsif ADD = "011100" then -- decypher_key_regs_input 3
				decypher_key_regs_input(127 downto 96) <= WRITEDATA;
			elsif ADD = "111100" then
				decypher_start_reg_input <= "1";
			end if;
		-- Want to do a read operation
		elsif RD_EN = '1' and CS = '1' then
			if RST_N = '0' then
				READDATA <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
			elsif ADD = "100000" then -- decypher_output_text_regs_output 0
				READDATA <= decypher_output_text_regs_output(31 downto 0);
			elsif ADD = "100100" then -- decypher_output_text_regs_output 1
				READDATA <= decypher_output_text_regs_output(63 downto 32);
			elsif ADD = "101000" then -- decypher_output_text_regs_output 2
				READDATA <= decypher_output_text_regs_output(95 downto 64);
			elsif ADD = "101100" then -- decypher_output_text_regs_output 3
				READDATA <= decypher_output_text_regs_output(127 downto 96);
			elsif ADD = "110000" then -- decypher_finished_reg_output 
				READDATA <= decypher_finished_reg_output;
			end if;
		-- Finished operation		
		elsif decypher_finished = '1' then
			READDATA <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
			decypher_start_reg_input <= "0";
		else
			READDATA <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
		end if;
	end if;
end process;	
--------------------------------------------------------------------------------------

reset <= '0' when decypher_start_reg_output = "1" else '1';

end architecture a_AES_decypher_avalon;
