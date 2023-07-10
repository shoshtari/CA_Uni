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
	pc_in : IN std_logic_vector(15 downto 0);
	
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
	pc_out : out std_logic_vector(15 downto 0);
	
	write_back : out std_logic;
	mem_write : out std_logic;
	is_addm : out std_logic;
	is_lw : out std_logic;
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


component mem_stage is
	port (	
	-- data input
	exec_res : in std_logic_vector(15 downto 0);
	exec_status : in std_logic_vector(3 downto 0);
	D2 : in std_logic_vector(15 downto 0);
	-- control input
	mem_write : in std_logic;
	is_lw : in std_logic;
	is_addm : in std_logic;
	clk : in std_logic;
	-- data output		   
	result : out std_logic_vector(15 downto 0);
	status : out std_logic_vector(3 downto 0)
		);
end component;

SIGNAL pc_set : std_logic_vector(15 downto 0);
SIGNAL pc_get : std_logic_vector(15 downto 0);


SIGNAL instruction_get : std_logic_vector(15 downto 0);
SIGNAL instruction_set : std_logic_vector(15 downto 0);

-- rd addresss,	rs,	rd,	immediate,	wb,	mw,	aluop,	alusrc,	is_addm,	status write, is lw	
-- 4			16,	16,	16,			1,	1,	2,		1,		1,			1,				1
SIGNAL id_to_exec_get: std_logic_vector(59 downto 0);
SIGNAL id_to_exec_set: std_logic_vector(59 downto 0);

-- rd address,	rs,	write back,	mem write, is addm,	status write,	is lw,	alu result,	status
-- 4,			16,	1,			1,			1,		1,				1,		16,			4
SIGNAL exec_to_mem_get: std_logic_vector(44 downto 0);
SIGNAL exec_to_mem_set: std_logic_vector(44 downto 0);


-- rd address,	write back,	status write,	write data,	status
-- 4			1			1				16			4
SIGNAL mem_to_wb_get: std_logic_vector(25 downto 0);
SIGNAL mem_to_wb_set: std_logic_vector(25 downto 0);

SIGNAL static_data_to_write : std_logic_vector(15 downto 0);

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
	size =>	60
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
	size =>	45
	)
	port map(
	input => exec_to_mem_set,
	reset => reset,
	clk => clk,
	output => exec_to_mem_get
	); 
	-- MEM/WB
	mem_to_wb : mid_reg
	generic map(
	size =>	26
	)
	port map(
	input => mem_to_wb_set,
	reset => reset,
	clk => clk,
	output => mem_to_wb_get
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
	pc_in => pc_get,
	
	write_reg1 => mem_to_wb_get(25 downto 22),
	write_reg2 => "1001",
	
	reg_write1 => mem_to_wb_get(21),
	reg_write2 => mem_to_wb_get(20),
	
	write_data1 => mem_to_wb_get(19 downto 4),
	write_data2 => static_data_to_write,
	
	rd_address => id_to_exec_set(59 downto 56),
	rs => id_to_exec_set(55 downto 40),
	rd => id_to_exec_set(39 downto 24),
	extended_immediate => id_to_exec_set(23 downto 8),
	write_back => id_to_exec_set(7),
	mem_write => id_to_exec_set(6),
	
	pc_out => pc_set,
	alu_op => id_to_exec_set(5 downto 4),
	alu_src => id_to_exec_set(3),
	
	is_addm => id_to_exec_set(2),
	status_write => id_to_exec_set(1),
	is_lw => id_to_exec_set(0)
	
	);
	
	
	-- exec
	exec_stage_comp : exec_stage
	port map(
	D1 => id_to_exec_get(55 downto 40),
	D2 => id_to_exec_get(39 downto 24),
	Immed => id_to_exec_get(23 downto 8),
	
	AluOP => id_to_exec_get(5 downto 4),
	AluSrc => id_to_exec_get(3),
	result => exec_to_mem_set(19 downto 4),
	status => exec_to_mem_set(3 downto 0)
	);
	
	exec_to_mem_set(44 downto 41) <= id_to_exec_get( 59 downto 56); -- rs address
	exec_to_mem_set(40 downto 25) <= id_to_exec_get(39 downto 24); -- rs
	exec_to_mem_set(24) <= id_to_exec_get(7); -- wb 
	exec_to_mem_set(23) <= id_to_exec_get(6); -- mw
	exec_to_mem_set(22) <= id_to_exec_get(2); -- is addm
	exec_to_mem_set(21) <= id_to_exec_get(1); -- status write 
	exec_to_mem_set(20) <= id_to_exec_get(0); -- is lw
	
	-- mem
	mem_stage_comp : mem_stage
	port map(
	exec_res => exec_to_mem_get(19 downto 4),
	exec_status => exec_to_mem_get(3 downto 0),
	D2 => exec_to_mem_get(40 downto 25),
	mem_write => exec_to_mem_get(23),
	is_lw => exec_to_mem_get(20),
	is_addm => exec_to_mem_get(22),
	clk => clk,
	
	result => mem_to_wb_set(19 downto 4), -- result
	status => mem_to_wb_set(3 downto 0) -- status 
	);
	
	exec_to_mem_set(28 downto 25) <= id_to_exec_get( 59 downto 56);
	exec_to_mem_set(24) <= id_to_exec_get(7);
	exec_to_mem_set(23) <= id_to_exec_get(6);
	exec_to_mem_set(22) <= id_to_exec_get(2);
	exec_to_mem_set(21) <= id_to_exec_get(1); 
	exec_to_mem_set(20) <= id_to_exec_get(0);
	
	mem_to_wb_set(25 downto 22) <= exec_to_mem_get(44 downto 41); -- rd address
	mem_to_wb_set(21) <= exec_to_mem_get(24); -- wb
	mem_to_wb_set(20) <= exec_to_mem_get(21); -- status write
	
	
	static_data_to_write <= "000000000000" & mem_to_wb_get(3 downto 0);
	
END gate_level;
