library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

ENTITY controller IS
	PORT(

	op : IN STD_LOGIC_VECTOR(3downto 0);

	write_back : OUT STD_LOGIC;
	mem_write : OUT STD_LOGIC;
	is_addm : OUT std_logic;
	status_write : OUT std_logic;
	alu_op : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
);

END controller;

ARCHITECTURE gate_level OF controller IS

SIGNAL is_add : std_logic;
SIGNAL is_sub : std_logic;
SIGNAL is_and : std_logic;
SIGNAL is_sll : std_logic;

BEGIN								
	
	write_back <= not op(3) or (not op(2) and op(1) and op(0)) or (op(2) and not op(1) and not op(2));
	mem_write <= op(3) and not op(2) and not op(1) and op(0);
	
	is_add <= (not op(2) and not op(1)) or (not op(1) and not op(0)) or (not op(3) and op(1) and op(0));
	is_sll <= not op(3) and op(2) and op(1) and not op(0);
	is_and <= op(0) and not op(1) and op(2) and not op(3);
	is_sub <= (op(3) and op(2) and op(0)) or (op(3) and op(1) and op(0)) or (not op(2) and op(1) and not op(0));
	
	--with is_add select 
--	internal_res <= dm_data_out when "1",
--	exec_res when others;
	

	
END gate_level;
