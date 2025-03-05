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

entity Reg is
    generic (
        size: positive
    );
    port (
        clock: in std_logic;
		  enable : in std_logic;
        input: in std_logic_vector(size - 1 downto 0);
        output: out std_logic_vector(size - 1 downto 0)
    );
end entity;

--------------------------------------------------------------------------------------

architecture a_Reg of Reg is

--------------------------------------------------------------------------------------

signal content: std_logic_vector(size - 1 downto 0);

--------------------------------------------------------------------------------------

begin
	 
	 process(clock)
    begin
		if rising_edge(clock) then
			if enable = '1' then
				content <= input;
			end if;
      end if;
    end process;
    
    output <= content;

end architecture a_Reg;