library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

ENTITY instruction_decode IS
	PORT(

    instruction : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	pc_in : IN std_logic_vector(15 downto 0);
	
	clk : IN STD_LOGIC; -- clock.

	-- register file write pins exported
	write_reg1 : IN std_logic_vector(3 downto 0);
	write_reg2 : IN std_logic_vector(3 downto 0);

    reg_write1 : IN std_logic;
	reg_write2 : IN std_logic;
	
	write_data1 : IN std_logic_vector(15 downto 0);
	write_data2 : IN std_logic_vector(15 downto 0);

	-- outputs
	rs : out std_logic_vector(15 downto 0);
	rd : out std_logic_vector(15 downto 0);
	rd_address : out std_logic_vector(3 downto 0);
	pc_out : out std_logic_vector(15 downto 0);
	
	extended_immediate : out std_logic_vector(15 downto 0);

	write_back : out std_logic;
	mem_write : out std_logic;
	is_addm : out std_logic;
	status_write : out std_logic;
	alu_src : out std_logic;
	alu_op : out std_logic_vector(1 downto 0);
	is_lw : out std_logic
);

END instruction_decode;

ARCHITECTURE gate_level OF instruction_decode IS

COMPONENT controller IS
	PORT(

	op : IN STD_LOGIC_VECTOR(3 downto 0);

	write_back : OUT STD_LOGIC;
	mem_write : OUT STD_LOGIC;
	is_addm : out std_logic;
	status_write : OUT std_logic;
	alu_op : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	alu_src : OUt std_logic
);

END COMPONENT;


component register_file IS
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

END component;

SIGNAL op : STD_LOGIC_VECTOR(3 DOWNTO 0);		   
SIGNAL rs_address : std_logic_vector(3 downto 0);
SIGNAL rd_address_in : std_logic_vector(3 downto 0);
SIGNAL stall : integer := 0;

SIGNAL immediate : std_logic_vector(7 downto 0);
  
SIGNAL wb_control : std_logic;
SIGNAL mw_control : std_logic;
SIGNAL sw_control : std_logic;

SIGNAL hazard_detected : std_logic;	
SIGNAL new_cycle : std_logic;
SIGNAL rd_register_file : std_logic_vector(15 downto 0);

BEGIN
	
	op <= instruction(15 downto 12);
	
	-- if r format (rd is for i format to)
	rd_address_in <= instruction(11 downto 8);
	rs_address <= instruction(7 downto 4);
	
	is_lw <= not op(3) and op(2) and op(1) and op(0);

	
	r : register_file
	port map(
	
	read_reg1 => rd_address_in,   
	read_reg2 => rs_address, 
	
	write_reg1 => write_reg1,
	write_reg2 => write_reg2,

    reg_write1 => reg_write1,
	reg_write2 => reg_write2,
	
	write_data1 => write_data1,
	write_data2 => write_data2,

	clk => clk,
	
    data_out1 => rd_register_file,
	data_out2 => rs
	);
	rd <= rd_register_file;
	rd_address <= rd_address_in;
	
	c : controller
	port map(
	op => op,
	write_back => wb_control,
	mem_write => mw_control,
	is_addm => is_addm,
	status_write => sw_control,
	alu_op => alu_op,
	alu_src => alu_src
	);
	
	write_back <= wb_control and not hazard_detected;
	mem_write <= mw_control and not hazard_detected;
	status_write <= sw_control and not hazard_detected;
	
	-- pc_out <= std_logic_vector(unsigned(pc_in) + 4);
	-- hazard detection
	
	process(clk)
	begin
		if rising_edge(clk) then
			if stall > 0 then 
				hazard_detected <= '1';
				stall <= stall - 1;
				pc_out <= pc_in;
			else
				new_cycle <= '1';
				hazard_detected <= '0';
			end if;
		end if;
		
		-- dont know if it cause a data race for rd_register_file or not
		if op = "1111" then 
			pc_out <= instruction(11 downto 0) & "0000";
			stall <= 1;
			hazard_detected <= '1';
		elsif op = "1110" and rd_register_file(0) = '0' then
			pc_out <= std_logic_vector(unsigned(pc_in) + 2 + unsigned(immediate&'0'));
			stall <= 1;
			hazard_detected <= '1';
		else
			pc_out <= std_logic_vector(unsigned(pc_in) + 1);
		end if;	
	
		
	end process;
	
	
	


END gate_level;