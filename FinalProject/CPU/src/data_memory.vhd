Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;



entity data_memory is
	port (
		address : in std_logic_vector(15 downto 0);
		clk : in std_logic;						   
		mem_write : in std_logic;
		write_data : in std_logic_vector(15 downto 0);
		data_out : out std_logic_vector(15 downto 0)
		);
end data_memory;				





architecture dm_struc of data_memory is	
type data_array is array (0 to 1535) of std_logic_vector(15 downto 0);	   
signal data : data_array;
begin

process (clk)
variable index : integer;						  
begin  	 
if falling_edge(clk) then
	index := to_integer(unsigned(address));
	if mem_write = '1' then	  
		data(index) <= write_data;
	end if;
	data_out <= data(index);


end if;		  
end process;		   

	
end dm_struc;