library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

ENTITY instruction_decode IS
	PORT(

    instruction : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
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
	extened_immediate : out std_logic_vector(15 downto 0);
	address : out std_logic_vector(11 downto 0);
	
	write_back : out std_logic;
	mem_write : out std_logic;
	alu_op : out std_logic_vector(1 downto 0)			  
);

END instruction_decode;

ARCHITECTURE gate_level OF instruction_decode IS

COMPONENT controller IS
	PORT(

	op : IN STD_LOGIC_VECTOR(3 downto 0);

	write_back : OUT STD_LOGIC;
	mem_write : OUT STD_LOGIC;
	alu_op : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
	
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
SIGNAL rd_address : std_logic_vector(3 downto 0);
SIGNAL rs_address : std_logic_vector(3 downto 0);
SIGNAL immediate : std_logic_vector(7 downto 0);

BEGIN
	
	op <= instruction(15 downto 12);
	
	-- if r format (rd is for i format to)
	rd_address <= instruction(11 downto 8);
	rs_address <= instruction(7 downto 4);
	
	c : controller
	port map(
	op => op,
	write_back => write_back,
	mem_write => mem_write,
	alu_op => alu_op
	);
	
	r : register_file
	port map(
	
	read_reg1 => rd_address,   
	read_reg2 => rs_address, 
	
	write_reg1 => write_reg1,
	write_reg2 => write_reg2,

    reg_write1 => reg_write1,
	reg_write2 => reg_write2,
	
	write_data1 => write_data1,
	write_data2 => write_data2,

	clk => clk,
	
    data_out1 => rd,
	data_out2 => rs
	);
	
	


END gate_level;