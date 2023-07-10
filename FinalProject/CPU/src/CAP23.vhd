library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

ENTITY cap23 IS
	PORT(
	
	clk : IN std_logic;
	reset : IN std_logic;
	
	set_pc : IN std_logic;
	set_pc_value : IN std_logic_vector(15 downto 0);
	
	-- instruction memory
	im_write_address   : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
	im_write_data : IN std_logic_vector(15 downto 0);

    im_reg_write : IN std_logic	 
);

END cap23;

ARCHITECTURE gate_level OF cap23 IS

component mid_reg IS
	GENERIC(
	size : integer := 15	
	);
	
	
	PORT(
	input : IN std_logic_vector(size - 1 downto 0);							  
	reset : IN STD_LOGIC; -- async. clear.
	
    clk : IN STD_LOGIC; -- clock.
	
    output   : OUT STD_LOGIC_VECTOR(size - 1 DOWNTO 0)
);
END component;

component instruction_fetch IS
	PORT(

    address   : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    clk : IN STD_LOGIC; -- clock.
	
	-- register file write data:
    data : OUT STD_LOGIC_VECTOR(15 downto 0);
	
	
	-- write ports of instruction memory
	write_address   : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
	write_data : IN std_logic_vector(15 downto 0);

    reg_write : IN std_logic
);

END component;

component instruction_decode IS
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
	rd_address : out std_logic_vector(3 downto 0);
	extended_immediate : out std_logic_vector(15 downto 0);

	write_back : out std_logic;
	mem_write : out std_logic;
	is_addm : out std_logic;
	status_write : out std_logic;
	alu_src : out std_logic;
	alu_op : out std_logic_vector(1 downto 0)			  
);

END component;

component exec_stage is
	port (	
	D1 : in std_logic_vector(15 downto 0);
	D2 : in std_logic_vector(15 downto 0);
	Immed : in std_logic_vector(15 downto 0);
	AluSrc : in std_logic;
	AluOP : in std_logic_vector(1 downto 0);
	result : out std_logic_vector(15 downto 0);
	status : out std_logic_vector(3 downto 0)
		);
end component;

SIGNAL pc_set : std_logic_vector(15 downto 0);
SIGNAL pc_get : std_logic_vector(15 downto 0);


SIGNAL instruction_get : std_logic_vector(15 downto 0);
SIGNAL instruction_set : std_logic_vector(15 downto 0);

-- rd addresss,	rs,	rd,	immediate,	wb,	mw,	aluop,	alusrc,	is_addm,	status write
-- 4			16,	16,	16,			1,	1,	2,		1,		1,			1
SIGNAL id_to_exec_get: std_logic_vector(58 downto 0);
SIGNAL id_to_exec_set: std_logic_vector(58 downto 0);

-- rd address,	write back,	mem write, is addm,	status write,	alu result,	status
-- 4,			1,			1,			1,		1,				16,			4
SIGNAL exec_to_mem_get: std_logic_vector(27 downto 0);
SIGNAL exec_to_mem_set: std_logic_vector(27 downto 0);


BEGIN
	-- defining registers
	-- pc
	pc : mid_reg
	generic map(
	size =>	16
	)
	port map(
	input => pc_set,
	reset => reset,
	clk => clk,
	output => pc_get
	);
	-- instruction (IF/ID)
	instruction : mid_reg
	generic map(
	size =>	16
	)
	port map(
	input => instruction_set,
	reset => reset,
	clk => clk,
	output => instruction_get
	);
	-- id to exec (ID/EXEC)
	id_to_exec : mid_reg
	generic map(
	size =>	59
	)
	port map(
	input => id_to_exec_set,
	reset => reset,
	clk => clk,
	output => id_to_exec_get
	); 
	-- EXE/MEM
	exec_to_mem : mid_reg
	generic map(
	size =>	28
	)
	port map(
	input => exec_to_mem_set,
	reset => reset,
	clk => clk,
	output => exec_to_mem_get
	); 
	
	
	
	-- if
	if_stage : instruction_fetch
	port map(
	address => pc_get,
	clk => clk,
	data => instruction_set,
	
	write_address => im_write_address,
	write_data => im_write_data,
	reg_write => im_reg_write
	);
	
	-- id
	id_stage : instruction_decode
	port map(
	instruction	=> instruction_get,
	clk => clk,
	
	write_reg1 => (others => '0'),
	write_reg2 => (others => '0'),
	
	reg_write1 => '0',
	reg_write2 => '0',
	
	write_data1 => (others => '0'),
	write_data2 => (others => '0'),
	
	rd_address => id_to_exec_set(58 downto 55),
	rs => id_to_exec_set(54 downto 39),
	rd => id_to_exec_set(38 downto 23),
	extended_immediate => id_to_exec_set(22 downto 7),
	write_back => id_to_exec_set(6),
	mem_write => id_to_exec_set(5),
	
	alu_op => id_to_exec_set(4 downto 3),
	alu_src => id_to_exec_set(2),
	
	is_addm => id_to_exec_set(1),
	status_write => id_to_exec_set(0)
	
	);
	
	
	-- exec
	exec_stage_comp : exec_stage
	port map(
	D1 => id_to_exec_get(54 downto 39),
	D2 => id_to_exec_get(38 downto 23),
	Immed => id_to_exec_get(22 downto 7),
	AluOP => id_to_exec_get(6 downto 5),
	AluSrc => id_to_exec_get(4),
	result => exec_to_mem_set(19 downto 4),
	status => exec_to_mem_set(3 downto 0)
	);
	
	exec_to_mem_set(27 downto 24) <= id_to_exec_get( 58 downto 55);
	exec_to_mem_set(23) <= id_to_exec_get(6);
	exec_to_mem_set(22) <= id_to_exec_get(5);
	exec_to_mem_set(21) <= id_to_exec_get(1);
	exec_to_mem_set(20) <= id_to_exec_get(0);
	
	
	
	
	
	
	
END gate_level;
