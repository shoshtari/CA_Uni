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
		im_write_address : in unsigned(15 downto 0);
		im_write_data : in STD_LOGIC_VECTOR(15 downto 0);
		
		im_reg_write : in STD_LOGIC;
		
		pc_output : OUT unsigned(15 downto 0);
		instruction_output: OUT std_logic_vector(15 downto 0);
		id_to_exe_output : OUT std_logic_vector(59 downto 0);
		exec_to_mem_output : OUT std_logic_vector(44 downto 0);
		mem_to_wb_output : OUT std_logic_vector(25 downto 0)
		
		);
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk : STD_LOGIC;
	signal reset : STD_LOGIC;
	signal im_write_address : unsigned(15 downto 0);
	signal im_write_data : STD_LOGIC_VECTOR(15 downto 0);
	signal im_reg_write : STD_LOGIC;
	
	signal pc_output : unsigned(15 downto 0);
	signal instruction_output: std_logic_vector(15 downto 0);
	signal id_to_exe_output : std_logic_vector(59 downto 0);
	signal exec_to_mem_output : std_logic_vector(44 downto 0);
	signal mem_to_wb_output :  std_logic_vector(25 downto 0);
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

			im_write_address => im_write_address,
			im_write_data => im_write_data,
			im_reg_write => im_reg_write,
			pc_output => pc_output,
			instruction_output => instruction_output,
			id_to_exe_output => id_to_exe_output,
			exec_to_mem_output => exec_to_mem_output,
			mem_to_wb_output => mem_to_wb_output
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
	clk <= '1'; 
	im_reg_write <= '1'; 
	im_write_address <= "0000000000000000";
	
	wait for 100ns;
	for i in 0 to 100000 loop
    	exit when endfile(file_handler);
		readline(file_handler, row);
		-- Read value from line
		read(row, instruction);
		im_write_data <= instruction;
		clk <= '1';
		wait for 100ns;
		clk <= '0';	
		wait for 100ns;	
		im_write_address <= im_write_address + 1;
  	end loop;
	  
	reset <= '0';
	im_reg_write <= '0';
	clk <='1';
	
	wait for 100ns;
	clk <='0';
	wait for 100ns;
	clk <='1';
	wait for 100ns;	
	clk <='0';
	wait for 100ns;
	clk <='1';
	wait for 100ns;
	clk <='0';
	wait for 100ns;
	clk <='1';
	wait for 100ns;
	clk <='0';
	wait for 100ns;
	clk <='1';
	wait for 100ns;	
	clk <='0';
	wait for 100ns;
	clk <='1';
	wait for 100ns;
	clk <='0';
	wait for 100ns;
	clk <='1';
	wait for 100ns;
	
	
	wait;
  	
	
	
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

