library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

ENTITY register_file IS
	PORT(
	read_reg1   : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	read_reg2   : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	
	write_reg1 : IN std_logic_vector(3 downto 0);
	write_reg2 : IN std_logic_vector(3 downto 0);

    reg_write1 : IN std_logic;
	reg_write2 : IN std_logic;
	
	write_data1 : IN std_logic_vector(15 downto 0);
	write_data2 : IN std_logic_vector(15 downto 0);

	clk : IN std_logic;
	
    data_out1 : OUT STD_LOGIC_VECTOR(15 downto 0);
	data_out2 : OUT STD_LOGIC_VECTOR(15 downto 0)
);

END register_file;

ARCHITECTURE gate_level OF register_file IS

SIGNAL data : STD_logic_vector(222 downto 0); -- 14 register * 16 bit 

SIGNAL bit_address_write1: integer;
SIGNAL bit_address_read1: integer;
SIGNAL bit_address_write2: integer;
SIGNAL bit_address_read2: integer;

BEGIN
	
	data(222 downto 219) <= (others => '0');
	
	process(clk)
	begin	   
		if rising_edge(clk) then
			if reg_write1 = '1' then
				bit_address_write1 <= to_integer(unsigned(write_reg1 & "1111")); 
				
				data(bit_address_write1 downto bit_address_write1 - 15) <= write_data1;
			end if;
			
			if reg_write2 = '1' then
				bit_address_write2 <= to_integer(unsigned(write_reg2 & "1111")); 
				
				data(bit_address_write2 downto bit_address_write2 - 15) <= write_data2;
			end if;
			
			-- read data...
			
			bit_address_read1 <= to_integer(unsigned(read_reg1 & "1111"));
			data_out1 <= data(bit_address_read1 downto bit_address_read1 - 15);
			
			bit_address_read2 <= to_integer(unsigned(read_reg2 & "1111"));
			data_out2 <= data(bit_address_read2 downto bit_address_read2 - 15);
		end if;
	end process;
    
END gate_level;