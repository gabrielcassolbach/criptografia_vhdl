library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decryptor is
    port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        address     : in  std_logic_vector(2 downto 0);  
        read_enable : in  std_logic;
		  wr_enable	  : in std_logic;
		  chip_select : in std_logic;
		  data_in	  : in std_logic_vector(31 downto 0);
        data_out    : out std_logic_vector(31 downto 0)  
    );
end entity decryptor;

architecture rtl of decryptor is
begin
   
end architecture rtl;
