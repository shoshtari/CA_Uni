library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

ENTITY mid_reg IS
	GENERIC(
	size : integer := 18	
	);
	
	
	PORT(
	input : IN std_logic_vector(size - 1 downto 0);							  
	reset : IN STD_LOGIC; -- async. clear.
	
    clk : IN STD_LOGIC; -- clock.
	
    output   : OUT STD_LOGIC_VECTOR(size - 1 DOWNTO 0)
);
END mid_reg;

ARCHITECTURE gate_level OF mid_reg IS

SIGNAL master : std_logic_vector(size - 1 downto 0) := (others => '0');
BEGIN
	
    process(clk, reset)
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