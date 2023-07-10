						library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

ENTITY instruction_memory IS
	PORT(
	read_address   : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
	write_address   : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
	write_data : IN std_logic_vector(15 downto 0);

    reg_write : IN std_logic;
    clk : IN STD_LOGIC; -- clock.
		 
    data_out : OUT STD_LOGIC_VECTOR(15 downto 0)
);

END instruction_memory;

ARCHITECTURE gate_level OF instruction_memory IS

SIGNAL data : STD_logic_vector(4095 downto 0);
SIGNAL bit_address_write: integer;
SIGNAL bit_address_read: integer;

BEGIN
												 	
	process(clk)
	begin 
		if rising_edge(clk) then
			
			if reg_write = '1' then
				bit_address_write <= to_integer(unsigned(write_address & "111"));
				data(bit_address_write downto bit_address_write - 7) <= write_data;
			end if;
			
			bit_address_read <= to_integer(unsigned(read_address & "111"));
			data_out <= data(bit_address_read downto bit_address_read - 7);
			
		end if;
	end process;
    
END gate_level;