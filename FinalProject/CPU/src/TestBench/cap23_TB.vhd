library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;   


-- Add your library and packages declaration here ...
use std.textio.all;
use ieee.std_logic_textio.all;

entity cap23_tb is
end cap23_tb;

architecture TB_ARCHITECTURE of cap23_tb is
	-- Component declaration of the tested unit
	component cap23
	port(
		clk : in STD_LOGIC;
		reset : in STD_LOGIC;
		set_pc : in STD_LOGIC;
		set_pc_value : in STD_LOGIC_VECTOR(15 downto 0);
		im_write_address : in STD_LOGIC_VECTOR(9 downto 0);
		im_write_data : in STD_LOGIC_VECTOR(15 downto 0);
		im_reg_write : in STD_LOGIC );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk : STD_LOGIC;
	signal reset : STD_LOGIC;
	signal set_pc : STD_LOGIC;
	signal set_pc_value : STD_LOGIC_VECTOR(15 downto 0);
	signal im_write_address : STD_LOGIC_VECTOR(9 downto 0);
	signal im_write_data : STD_LOGIC_VECTOR(15 downto 0);
	signal im_reg_write : STD_LOGIC;
	-- Observed signals - signals mapped to the output ports of tested entity

	-- Add your code here ...  
	file file_handler     : text open read_mode is "..\..\..\Assembler\program.exe";
	signal instruction : std_logic_vector(15 downto 0);

begin

	-- Unit Under Test port map
	UUT : cap23
		port map (
			clk => clk,
			reset => reset,
			set_pc => set_pc,
			set_pc_value => set_pc_value,
			im_write_address => im_write_address,
			im_write_data => im_write_data,
			im_reg_write => im_reg_write
		);					
		
process
	Variable row          : line;
	Variable instruction  : std_logic_vector(15 downto 0);  
begin  	  
--	if not endfile(file_handler) then
--	
--		readline(file_handler, row);
--		-- Read value from line
--		read(row, instruction);
--		report integer'image(to_integer(unsigned(instruction)));
--	
--	end if;	  
	reset <= '1'; 
	wait for 100ns;
	clk <= '0'; 
	im_reg_write <= '1'; 
	set_pc <= '0';
--	im_write_address <= "0000000010";
--	for i in 0 to 100000 loop
--    	exit when endfile(file_handler);
--		readline(file_handler, row);
--		-- Read value from line
--		read(row, instruction);
--		im_write_data <= instruction;
		clk <= '1';
		wait for 100ns;
		clk <= '0';	
		wait for 100ns;
--		
--  end loop;
	
end process;	

	-- Add your stimulus here ...	   


end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_cap23 of cap23_tb is
	for TB_ARCHITECTURE
		for UUT : cap23
			use entity work.cap23(gate_level);
		end for;
	end for;
end TESTBENCH_FOR_cap23;

