library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

ENTITY instruction_fetch IS
	PORT(

    read_address   : IN unsigned(15 DOWNTO 0);
    clk : IN STD_LOGIC; -- clock.
	
	-- register file write data:
    data : OUT STD_LOGIC_VECTOR(15 downto 0);
	
	
	-- write ports of instruction memory
	write_address   : IN unsigned(15 DOWNTO 0);
	write_data : IN std_logic_vector(15 downto 0);

    reg_write : IN std_logic
);

END instruction_fetch;

ARCHITECTURE gate_level OF instruction_fetch IS

component instruction_memory IS
	PORT(
	read_address   : IN unsigned(9 DOWNTO 0);
	write_address   : IN unsigned(9 DOWNTO 0);
	write_data : IN std_logic_vector(15 downto 0);

    reg_write : IN std_logic;
    clk : IN STD_LOGIC; -- clock.

    data_out : OUT STD_LOGIC_VECTOR(15 downto 0)
);

END component;

SIGNAL fetched_instruction : std_logic_vector(15 downto 0);
SIGNAL op : std_logic_vector(3 downto 0);

BEGIN
	
	instruction_file : instruction_memory
	port map(
	read_address => read_address(9 downto 0),
	reg_write => reg_write,
	write_address => write_address(9 downto 0),
	write_data => write_data,
	clk => clk,
	data_out => fetched_instruction
	);							   
	
	data <= fetched_instruction;
--	process(fetched_instruction)
--	begin
--		if fetched_instruction(15 downto 12) = "1110" then
--			fetched_instruction(11 downto 8) <= "1001";
--		end if;
--	end process;
--	data <= fetched_instruction;
    
END gate_level;