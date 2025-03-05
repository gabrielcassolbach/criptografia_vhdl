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

entity AES_decypher_avalon_tb is
end entity;

--------------------------------------------------------------------------------------

architecture a_AES_decypher_avalon_tb of AES_decypher_avalon_tb is

--------------------------------------------------------------------------------------

component AES_decypher_avalon is
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
end component;

--------------------------------------------------------------------------------------

signal clock, reset_n: std_logic;
signal readdata 		: std_logic_vector (31 downto 0);
signal writedata		: std_logic_vector (31 downto 0);
signal add 				: std_logic_vector (5 downto 0);
signal cs   			: std_logic;
signal wr_en			: std_logic;
signal rd_en			: std_logic;

signal output_text   : std_logic_vector(127 downto 0); 

constant clk_period : time := 40 ns;

--------------------------------------------------------------------------------------

begin

DUT: AES_decypher_avalon
	port map(
	   CLK => clock,       
		RST_N => reset_n,    
		READDATA  => readdata,
		WRITEDATA => writedata,
		ADD => add,
		CS => cs,
		WR_EN => wr_en,
		RD_EN => rd_en
	);

--------------------------------------------------------------------------------------

process
	begin
	
		--input_text <= x"340737e0 a2983131 8d305a88 a8f64332";
		
		--key <= x"3c4fcf09 8815f7ab a6d2ae28 16157e2b";

		
		reset_n <= '0';
		
		wait for clk_period*10;
		
		reset_n <= '1';
		
		cs <= '1';
		
		----------------------------------------------------------------
		
		writedata <= x"5bccdfa0";
		
		add <= "000000";
		
		wait for clk_period;
		
		wr_en <= '1';
		
		wait for clk_period;
		
		wr_en <= '0';
		
		wait for clk_period;
		
		----------------------------------------------------------------
		
		writedata <= x"21f88c59";
		
		add <= "000100";
		
		wait for clk_period;
		
		wr_en <= '1';
		
		wait for clk_period;
		
		wr_en <= '0';
		
		wait for clk_period;
		
		----------------------------------------------------------------
		
		writedata <= x"4c24d041";
		
		add <= "001000";
		
		wait for clk_period;
		
		wr_en <= '1';
		
		wait for clk_period;
		
		wr_en <= '0';
		
		wait for clk_period;
		
		----------------------------------------------------------------
		
		writedata <= x"05e7ace2";
		
		add <= "001100";
		
		wait for clk_period;
		
		wr_en <= '1';
		
		wait for clk_period;
		
		wr_en <= '0';
		
		wait for clk_period;
		
		----------------------------------------------------------------
		
		writedata <= x"6D6E6F70";
		
		add <= "010000";
		
		wait for clk_period;
		
		wr_en <= '1';
		
		wait for clk_period;
		
		wr_en <= '0';
		
		wait for clk_period;
		
		----------------------------------------------------------------
		
		writedata <= x"696A6B6C";
		
		add <= "010100";
		
		wait for clk_period;
		
		wr_en <= '1';
		
		wait for clk_period;
		
		wr_en <= '0';
		
		wait for clk_period;
		
		----------------------------------------------------------------
		
		writedata <= x"65666768";
		
		add <= "011000";
		
		wait for clk_period;
		
		wr_en <= '1';
		
		wait for clk_period;
		
		wr_en <= '0';
		
		wait for clk_period;
		
		----------------------------------------------------------------
		
		writedata <= x"61626364";
		
		add <= "011100";
		
		wait for clk_period;
		
		wr_en <= '1';
		
		wait for clk_period;
		
		wr_en <= '0';
		
		wait for clk_period;
		
		----------------------------------------------------------------
		
		writedata <= x"3c4fcf09";
		
		add <= "111100";
		
		wait for clk_period;
		
		wr_en <= '1';
		
		wait for clk_period;
		
		wr_en <= '0';
		
		wait for clk_period*40;
		
		----------------------------------------------------------------
		
		add <= "100000";
		
		wait for clk_period;
		
		rd_en <= '1';
		
		wait for clk_period;
		
		output_text(31 downto 0) <= readdata;
		
		wait for clk_period;
		
		rd_en <= '0';
		
		wait for clk_period;
		
		----------------------------------------------------------------
		
		add <= "100100";
		
		wait for clk_period;
		
		rd_en <= '1';
		
		wait for clk_period;
		
		output_text(63 downto 32) <= readdata;
		
		wait for clk_period;
		
		rd_en <= '0';
		
		wait for clk_period;
		
		----------------------------------------------------------------
		
		add <= "101000";
		
		wait for clk_period;
		
		rd_en <= '1';
		
		wait for clk_period;
		
		output_text(95 downto 64) <= readdata;
		
		wait for clk_period;
		
		rd_en <= '0';
		
		wait for clk_period;

		----------------------------------------------------------------
		
		add <= "101100";
		
		wait for clk_period;
		
		rd_en <= '1';
		
		wait for clk_period;
		
		output_text(127 downto 96) <= readdata;
		
		wait for clk_period;
		
		rd_en <= '0';
		
		wait for clk_period;
		
		if (output_text = x"340737e0a29831318d305a88a8f64332") then
			report "---------- Passed ----------";
		else
			report "---------- Failed ----------";
		end if;
		
		report "---------- Output must be: -------";
		
		report "340737e0a29831318d305a88a8f64332";
		
		----------------------------------------------------------------
		
		wait for clk_period*10;
		
		writedata <= x"d44be966";
		
		add <= "000000";
		
		wait for clk_period;
		
		wr_en <= '1';
		
		wait for clk_period;
		
		wr_en <= '0';
		
		wait for clk_period;
		
		----------------------------------------------------------------
		
		writedata <= x"3b2c8aef";
		
		add <= "000100";
		
		wait for clk_period;
		
		wr_en <= '1';
		
		wait for clk_period;
		
		wr_en <= '0';
		
		wait for clk_period;
		
		----------------------------------------------------------------
		
		writedata <= x"59fa4c88";
		
		add <= "001000";
		
		wait for clk_period;
		
		wr_en <= '1';
		
		wait for clk_period;
		
		wr_en <= '0';
		
		wait for clk_period;
		
		----------------------------------------------------------------
		
		writedata <= x"2e2b34ca";
		
		add <= "001100";
		
		wait for clk_period;
		
		wr_en <= '1';
		
		wait for clk_period;
		
		wr_en <= '0';
		
		wait for clk_period;
		
		----------------------------------------------------------------
		
		writedata <= x"cb5befb4";
		
		add <= "010000";
		
		wait for clk_period;
		
		wr_en <= '1';
		
		wait for clk_period;
		
		wr_en <= '0';
		
		wait for clk_period;
		
		----------------------------------------------------------------
		
		writedata <= x"11e2923e";
		
		add <= "010100";
		
		wait for clk_period;
		
		wr_en <= '1';
		
		wait for clk_period;
		
		wr_en <= '0';
		
		wait for clk_period;
		
		----------------------------------------------------------------
		
		writedata <= x"cf51e923";
		
		add <= "011000";
		
		wait for clk_period;
		
		wr_en <= '1';
		
		wait for clk_period;
		
		wr_en <= '0';
		
		wait for clk_period;
		
		----------------------------------------------------------------
		
		writedata <= x"8e188f6f";
		
		add <= "011100";
		
		wait for clk_period;
		
		wr_en <= '1';
		
		wait for clk_period;
		
		wr_en <= '0';
		
		wait for clk_period;
		
		----------------------------------------------------------------
		
		writedata <= x"00000000";
		
		add <= "111100";
		
		wait for clk_period;
		
		wr_en <= '1';
		
		wait for clk_period;
		
		wr_en <= '0';
		
		wait for clk_period*40;
		
		----------------------------------------------------------------
		
		add <= "100000";
		
		wait for clk_period;
		
		rd_en <= '1';
		
		wait for clk_period;
		
		output_text(31 downto 0) <= readdata;
		
		wait for clk_period;
		
		rd_en <= '0';
		
		wait for clk_period;
		
		----------------------------------------------------------------
		
		add <= "100100";
		
		wait for clk_period;
		
		rd_en <= '1';
		
		wait for clk_period;
		
		output_text(63 downto 32) <= readdata;
		
		wait for clk_period;
		
		rd_en <= '0';
		
		wait for clk_period;
		
		----------------------------------------------------------------
		
		add <= "101000";
		
		wait for clk_period;
		
		rd_en <= '1';
		
		wait for clk_period;
		
		output_text(95 downto 64) <= readdata;
		
		wait for clk_period;
		
		rd_en <= '0';
		
		wait for clk_period;

		----------------------------------------------------------------
		
		add <= "101100";
		
		wait for clk_period;
		
		rd_en <= '1';
		
		wait for clk_period;
		
		output_text(127 downto 96) <= readdata;
		
		wait for clk_period;
		
		rd_en <= '0';
		
		wait for clk_period;
		
		if (output_text = x"00000000000000000000000000000000") then
			report "---------- Passed ----------";
		else
			report "---------- Failed ----------";
		end if;
		
		report "---------- Output must be: -------";
		
		report "00000000000000000000000000000000";
		
		wait;
end process;

clk_gen: process
begin 
	clock <= '0';
	wait for clk_period/2;
	clock <= '1';
	wait for clk_period/2;
end process;

end architecture a_AES_decypher_avalon_tb;