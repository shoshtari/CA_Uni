library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


ENTITY master_slave_unsigned IS
	PORT(
	input : IN unsigned(15 downto 0);							  
	reset : IN STD_LOGIC; -- async clear.
	
    clk : IN STD_LOGIC; 
	
    output   : OUT unsigned(15 downto 0)
);
END master_slave_unsigned;

ARCHITECTURE gate_level OF master_slave_unsigned IS

SIGNAL master : unsigned(15 downto 0) := (others => '0');
BEGIN
	
    process(clk, reset, input)
    begin
		if reset = '1' then
			output <= (others => '0');
			master <= (others => '0');
		
		else 
			if clk = '0' then
				master <= input;
			else
				output <= master;
			end if;
		end if;	
    end process;	   
END gate_level;