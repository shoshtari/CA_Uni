library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

ENTITY instruction_memory IS
	PORT(
	read_address   : IN unsigned(9 DOWNTO 0);
	write_address   : IN unsigned(9 DOWNTO 0);
	write_data : IN std_logic_vector(15 downto 0);

    reg_write : IN std_logic;
    clk : IN STD_LOGIC; -- clock.
		 
    data_out : OUT STD_LOGIC_VECTOR(15 downto 0)
);

END instruction_memory;

ARCHITECTURE gate_level OF instruction_memory IS

type data_array is array (0 to 511) of std_logic_vector(15 downto 0);	   
signal data : data_array;

BEGIN
												 
process (clk)
variable index : integer;						  
begin  	 
	if falling_edge(clk) then
		index := to_integer(write_address);
		if reg_write = '1' then	  
			data(index) <= write_data;
		end if;


		index := to_integer(read_address);
		data_out <= data(index);
	end if;
	  
end process;
    
END gate_level;