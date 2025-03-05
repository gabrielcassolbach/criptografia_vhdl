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

entity inv_Controller is
   port(
		clock : in std_logic;
		reset : in std_logic;
		round_constant : out std_logic_vector(7 downto 0);
		first_round: out std_logic;
		finished: out std_logic
	); 
end entity;

--------------------------------------------------------------------------------------

architecture a_inv_Controller of inv_Controller is

--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------

constant rcon_table : std_logic_vector(87 downto 0) := x"0001020408102040801B36";
signal current_round_constant: std_logic_vector(7 downto 0);

--------------------------------------------------------------------------------------

begin

process(clock)
variable i : integer range 0 to 10 := 0;
begin
	if rising_edge(clock) then
		if(reset = '1') then
			i := 0;
		else
			i := (i + 1) mod 11;
		end if;
	end if;
	current_round_constant <= rcon_table(8*(i+1)-1 downto 8*i);
end process;

round_constant <= current_round_constant;
first_round <= '1' when current_round_constant = x"36" else '0';
finished <= '1' when current_round_constant = x"00" else '0';

end architecture a_inv_Controller;