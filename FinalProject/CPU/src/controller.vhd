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
	alu_op : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	alu_src : OUt std_logic
);

END controller;

ARCHITECTURE gate_level OF controller IS

SIGNAL is_add : std_logic;
SIGNAL is_sub : std_logic;
SIGNAL is_and : std_logic;
SIGNAL is_sll : std_logic;

SIGNAL selector : std_logic_vector(3 downto 0);

BEGIN								
	
	write_back <= not op(3) or (not op(2) and op(1) and op(0)) or (op(2) and not op(1) and not op(2));
	mem_write <= op(3) and not op(2) and not op(1) and op(0);
	is_addm <= not op(3) and not op(2) and not op(1) and op(0);
	status_write <= (not op(3) and not op(2)) or (op(3) and op(2) and not op(1) and op(0));
	
	selector(3) <= (not op(2) and not op(1)) or (not op(1) and not op(0)) or (not op(3) and op(1) and op(0)); -- add
	selector(2) <= not op(3) and op(2) and op(1) and not op(0); -- sll
	selector(1) <= op(0) and not op(1) and op(2) and not op(3); -- and
	selector(0) <= (op(3) and op(2) and op(0)) or (op(3) and op(1) and op(0)) or (not op(2) and op(1) and not op(0)); --sub
	
	with selector select 
	alu_op <= "01" when "0001",
			  "10" when "0010",
			  "11" when "0100",
			  "00" when "1000",
	 		  "10" when others; -- actually it must not happen, i set it to and because it is rarer and we can debug it easily
	
	-- addi, addm, lw, sw, clr, mov
	-- 0011, 0001, 0111, 1001, 1011, 1100
	with op select
	alu_src <= '1' when "0011" | "0001" | "0111" | "1001" | "1011" | "1100",
			   '0' when others;
	
END gate_level;
