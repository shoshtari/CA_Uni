library ieee;
use ieee.std_logic_1164.all;

entity Adder16 is
    port (
        inp1, inp2: in std_logic_vector(15 downto 0);
        sum: out std_logic_vector(15 downto 0);
        cout: out std_logic;
        overflow: out std_logic
    );
end entity Adder16;

architecture adder_struc of Adder16 is
begin
    process(inp1, inp2)
        variable carry: std_logic;
        variable isum: std_logic_vector(15 downto 0);
    begin				   
		carry := '0';
        for i in 0 to 15 loop
            isum(i) := inp1(i) xor inp2(i) xor carry;
            carry := (inp1(i) and inp2(i)) or (inp1(i) and carry) or (inp2(i) and carry);
        end loop;
        
        sum <= isum;
        cout <= carry;
        
         if (inp1(15) = inp2(15) and isum(15) /= inp1(15)) then
            overflow <= '1';
        else
            overflow <= '0';
        end if;
    end process;
end architecture adder_struc;Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;



entity alu is
	port (
	AluOP : in std_logic_vector(1 downto 0);	
	src1 : in std_logic_vector(15 downto 0);	  
	src2 : in std_logic_vector(15 downto 0);
	result : out std_logic_vector(15 downto 0);
	status : out std_logic_vector(3 downto 0)
		);
end alu; 



architecture alu_struc of alu is   
component Adder16
    port (
        inp1, inp2: in std_logic_vector(15 downto 0);
        sum: out std_logic_vector(15 downto 0);
        cout: out std_logic;
        overflow: out std_logic
    );	
end component;
signal adder_inp1 : std_logic_vector(15 downto 0);	
signal adder_inp2 : std_logic_vector(15 downto 0);
signal adder_sum : std_logic_vector(15 downto 0);	
signal adder_cout : std_logic;
signal adder_overflow : std_logic;

signal res_signed : signed(15 downto 0);
begin		
Adder : Adder16 port map(adder_inp1, adder_inp2, adder_sum, adder_cout, adder_overflow);
	
-- 00: add , 01: sub , 10 and, 11 sll
process (AluOP, src1, src2) 			 
variable tmp_res : std_logic_vector(15 downto 0);
variable status_flags : std_logic_vector(3 downto 0) := "0000";
begin					 
	
	
	if ( AluOP = "00" ) then -- ADD			
		adder_inp1 <= src1;
		adder_inp2 <= src2;
		tmp_res := adder_sum;
		-- setting the overflow and carry flags
		status_flags(0) := adder_overflow;
		status_flags(1) := adder_cout;
		
	elsif ( AluOP = "01" ) then -- SUB	 
		res_signed <= signed(src1) - signed(src2); 
		
		if (res_signed > to_signed(32767, 16)) or (res_signed < to_signed(-32768, 16)) then
            status_flags(0) := '1';
        end if;
		
		tmp_res := std_logic_vector(res_signed);
		

	elsif ( AluOP = "10" ) then -- AND	   
		tmp_res := std_logic_vector(unsigned(src1) and unsigned(src2));
		
	elsif ( AluOP = "11" ) then -- SLL
		tmp_res := std_logic_vector( signed(src1) sll to_integer(unsigned(src2)) );  -- signed or unsigned ?????
		
	end if;	
	
	if (tmp_res(15) = '1') then
		status_flags(2) := '1';
	end if;
	if (tmp_res = "0000000000000000") then	 
		status_flags(3) := '1';
	end if;
		
	result <= tmp_res;
	status <= status_flags;
	
end process;
	
	
	
end alu_struc;library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

ENTITY cap23 IS
	PORT(
	
	clk : IN std_logic;
	reset : IN std_logic;
	
	-- instruction memory
	im_write_address   : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
	im_write_data : IN std_logic_vector(15 downto 0);

    im_reg_write : IN std_logic;
	
	pc_output : OUT std_logic_vector(15 downto 0);
	instruction_output: OUT std_logic_vector(15 downto 0);
	id_to_exe_output : OUT std_logic_vector(59 downto 0);
	exec_to_mem_output : OUT std_logic_vector(44 downto 0);
	mem_to_wb_output : OUT std_logic_vector(25 downto 0)
	
	
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
	
	reg_read : IN std_logic;
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
SIGNAL reg_read : std_logic;

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
	reg_read => reg_read,
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
	reg_read <= not reset;		
	pc_output <= pc_get;
	
	instruction_output <= instruction_get;
	id_to_exe_output <= id_to_exec_get;
	exec_to_mem_output <= exec_to_mem_get;
	mem_to_wb_output <= mem_to_wb_get;
	
END gate_level;
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
	
	alu_src <= op(3) nor op(2);
	
END gate_level;
Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;



entity data_memory is
	port (
		address : in std_logic_vector(15 downto 0);
		clk : in std_logic;						   
		mem_write : in std_logic;
		write_data : in std_logic_vector(15 downto 0);
		data_out : out std_logic_vector(15 downto 0)
		);
end data_memory;				





architecture dm_struc of data_memory is	
type data_array is array (0 to 1535) of std_logic_vector(15 downto 0);	   
signal data : data_array;
begin

process (clk)
variable index : integer;						  
begin  	 
if falling_edge(clk) then
	index := to_integer(unsigned(address));
	if mem_write = '1' then	  
		data(index) <= write_data;
	end if;
	data_out <= data(index);


end if;		  
end process;		   

	
end dm_struc;Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


entity exec_stage is
	port (	
	D1 : in std_logic_vector(15 downto 0);
	D2 : in std_logic_vector(15 downto 0);
	Immed : in std_logic_vector(15 downto 0);
	AluSrc : in std_logic;
	AluOP : in std_logic_vector(1 downto 0);
	result : out std_logic_vector(15 downto 0);
	status : out std_logic_vector(3 downto 0)
		);
end exec_stage;					

architecture exec_struc of exec_stage is   
component alu
	port (
	AluOP : in std_logic_vector(1 downto 0);	
	src1 : in std_logic_vector(15 downto 0);	  
	src2 : in std_logic_vector(15 downto 0);
	result : out std_logic_vector(15 downto 0);
	status : out std_logic_vector(3 downto 0)
	);
end component; 
signal alu_aluop : std_logic_vector(1 downto 0);	
signal alu_src1 : std_logic_vector(15 downto 0);	  
signal alu_src2 : std_logic_vector(15 downto 0);
signal alu_result : std_logic_vector(15 downto 0);
signal alu_status : std_logic_vector(3 downto 0);
begin		
Alu1 : alu port map (alu_aluop, alu_src1, alu_src2, alu_result, alu_status);  

with AluSrc select 
alu_src2 <= Immed when '1',
D2 when others;
alu_src1 <= D1;	   

result <= alu_result;
status <= alu_status;

end exec_struc;library IEEE;
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

	reg_read : IN std_logic;
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
	reg_read : IN std_logic;
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
	reg_read => reg_read,
	
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
			pc_out <= std_logic_vector(unsigned(pc_in) + 1 + unsigned(immediate));
			stall <= 1;
			hazard_detected <= '1';
		else
			pc_out <= std_logic_vector(unsigned(pc_in) + 1);
		end if;	
	
		
	end process;
	
	
	


END gate_level;library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

ENTITY instruction_fetch IS
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

END instruction_fetch;

ARCHITECTURE gate_level OF instruction_fetch IS

component instruction_memory IS
	PORT(
	read_address   : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
	write_address   : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
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
	read_address => address(15 downto 6),
	reg_write => reg_write,
	write_address => write_address,
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
    
END gate_level;library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

ENTITY instruction_memory IS
	PORT(
	read_address   : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
	write_address   : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
	write_data : IN std_logic_vector(15 downto 0);

    reg_write : IN std_logic;
    clk : IN STD_LOGIC; -- clock.
		 
    data_out : OUT STD_LOGIC_VECTOR(15 downto 0)
);

END instruction_memory;

ARCHITECTURE gate_level OF instruction_memory IS

type data_array is array (0 to 511) of std_logic_vector(15 downto 0);	   
signal data : data_array;

BEGIN
												 
process (clk)
variable index : integer;						  
begin  	 
	if falling_edge(clk) then
		index := to_integer(unsigned(write_address));
		if reg_write = '1' then	  
			data(index) <= write_data;
		end if;


		index := to_integer(unsigned(read_address));
		data_out <= data(index);
	end if;
	  
end process;
    
END gate_level;Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;



entity mem_stage is
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
end mem_stage;			 



architecture mem_struc of mem_stage is
component data_memory
port (
	address : in std_logic_vector(15 downto 0);
	clk : in std_logic;						   
	mem_write : in std_logic;
	write_data : in std_logic_vector(15 downto 0);
	data_out : out std_logic_vector(15 downto 0)
	);
end component;	
signal dm_address : std_logic_vector(15 downto 0);
signal dm_clk : std_logic;						   
signal dm_mem_write : std_logic;
signal dm_write_data : std_logic_vector(15 downto 0);
signal dm_data_out : std_logic_vector(15 downto 0);		   

component alu
	port (
	AluOP : in std_logic_vector(1 downto 0);	
	src1 : in std_logic_vector(15 downto 0);	  
	src2 : in std_logic_vector(15 downto 0);
	result : out std_logic_vector(15 downto 0);
	status : out std_logic_vector(3 downto 0)
	);
end component; 
signal alu_aluop : std_logic_vector(1 downto 0);	
signal alu_src1 : std_logic_vector(15 downto 0);	  
signal alu_src2 : std_logic_vector(15 downto 0);
signal alu_result : std_logic_vector(15 downto 0);
signal alu_status : std_logic_vector(3 downto 0); 

signal internal_res : std_logic_vector (15 downto 0);

begin
Alu1 : alu port map (alu_aluop, alu_src1, alu_src2, alu_result, alu_status);   
DM : data_memory port map (dm_address, dm_clk, dm_mem_write, dm_write_data, dm_data_out);

dm_mem_write <= mem_write;  
dm_address <= exec_res;	  
dm_write_data <= D2;
dm_clk <= clk;

alu_aluop <= "00";
alu_src1 <= dm_data_out;	  
alu_src2 <= D2;

with is_lw select 
internal_res <= dm_data_out when '1',
exec_res when others; 

with is_addm select 
result <= alu_result when '1',
internal_res when others;	

with is_addm select 
status <= alu_status when '1',
exec_status when others;

end mem_struc;library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

ENTITY mid_reg IS
	GENERIC(
	size : integer := 18	
	);
	
	
	PORT(
	input : IN std_logic_vector(size - 1 downto 0);							  
	reset : IN STD_LOGIC; -- async clear.
	
    clk : IN STD_LOGIC; 
	
    output   : OUT STD_LOGIC_VECTOR(size - 1 DOWNTO 0)
);
END mid_reg;

ARCHITECTURE gate_level OF mid_reg IS

SIGNAL master : std_logic_vector(size - 1 downto 0) := (others => '0');
BEGIN
	
    process(clk, reset)
    begin
		if reset = '1' then
			output <= (others => '0');
			master <= (others => '0');
		
		else 
			if clk = '0' then 
				master <= input;
			else
				output <= master;
			end if;
		end if;	
    end process;	   
END gate_level;library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

ENTITY register_file IS
	PORT(
	reg_read : IN std_logic;
	
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

type data_array is array (0 to 13) of std_logic_vector(15 downto 0);	 -- 14 register * 16 bit    
signal data : data_array;

BEGIN
	
	process(clk)
	begin	   
		if falling_edge(clk) then
			if reg_write1 = '1' then
				data(to_integer(unsigned(write_reg1))) <= write_data1;
			end if;
			
			if reg_write2 = '1' then
				-- bit_address_write2 <= ; 
				data(to_integer(unsigned(write_reg2))) <= write_data2;
			end if;
			
			-- read data...
			if reg_read = '1' then				
				data_out1 <= data(to_integer(unsigned(read_reg1)));
				if to_integer(unsigned(read_reg2)) < 0 or to_integer(unsigned(read_reg2)) > 14 then
					report "warn, reg overflow";
					data_out2 <= data(0);
				else 
					data_out2 <= data(to_integer(unsigned(read_reg2)));
				end if;
			end if;
		end if;
	end process;
    
END gate_level;library ieee;
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
		im_write_address : in STD_LOGIC_VECTOR(9 downto 0);
		im_write_data : in STD_LOGIC_VECTOR(15 downto 0);
		
		im_reg_write : in STD_LOGIC;
		
		pc_output : OUT std_logic_vector(15 downto 0);
		instruction_output: OUT std_logic_vector(15 downto 0);
		id_to_exe_output : OUT std_logic_vector(59 downto 0);
		exec_to_mem_output : OUT std_logic_vector(44 downto 0);
		mem_to_wb_output : OUT std_logic_vector(25 downto 0)
		
		);
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk : STD_LOGIC;
	signal reset : STD_LOGIC;
	signal im_write_address : STD_LOGIC_VECTOR(9 downto 0);
	signal im_write_data : STD_LOGIC_VECTOR(15 downto 0);
	signal im_reg_write : STD_LOGIC;
	
	signal pc_output : std_logic_vector(15 downto 0);
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
	im_write_address <= "0000000000";
	
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
		im_write_address <= std_logic_vector(unsigned(im_write_address) + 1);
  	end loop;
	  
	reset <= '0';
	im_reg_write <= '0';
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

library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity register_file_tb is
end register_file_tb;

architecture TB_ARCHITECTURE of register_file_tb is
	-- Component declaration of the tested unit
	component register_file
	port(
		reg_read : in STD_LOGIC;
		read_reg1 : in STD_LOGIC_VECTOR(3 downto 0);
		read_reg2 : in STD_LOGIC_VECTOR(3 downto 0);
		write_reg1 : in STD_LOGIC_VECTOR(3 downto 0);
		write_reg2 : in STD_LOGIC_VECTOR(3 downto 0);
		reg_write1 : in STD_LOGIC;
		reg_write2 : in STD_LOGIC;
		write_data1 : in STD_LOGIC_VECTOR(15 downto 0);
		write_data2 : in STD_LOGIC_VECTOR(15 downto 0);
		clk : in STD_LOGIC;
		data_out1 : out STD_LOGIC_VECTOR(15 downto 0);
		data_out2 : out STD_LOGIC_VECTOR(15 downto 0) );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal reg_read : STD_LOGIC;
	signal read_reg1 : STD_LOGIC_VECTOR(3 downto 0);
	signal read_reg2 : STD_LOGIC_VECTOR(3 downto 0);
	signal write_reg1 : STD_LOGIC_VECTOR(3 downto 0);
	signal write_reg2 : STD_LOGIC_VECTOR(3 downto 0);
	signal reg_write1 : STD_LOGIC;
	signal reg_write2 : STD_LOGIC;
	signal write_data1 : STD_LOGIC_VECTOR(15 downto 0);
	signal write_data2 : STD_LOGIC_VECTOR(15 downto 0);
	signal clk : STD_LOGIC;
	-- Observed signals - signals mapped to the output ports of tested entity
	signal data_out1 : STD_LOGIC_VECTOR(15 downto 0);
	signal data_out2 : STD_LOGIC_VECTOR(15 downto 0);

	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : register_file
		port map (
			reg_read => reg_read,
			read_reg1 => read_reg1,
			read_reg2 => read_reg2,
			write_reg1 => write_reg1,
			write_reg2 => write_reg2,
			reg_write1 => reg_write1,
			reg_write2 => reg_write2,
			write_data1 => write_data1,
			write_data2 => write_data2,
			clk => clk,
			data_out1 => data_out1,
			data_out2 => data_out2
		);

	-- Add your stimulus here ...
	process
	begin
		reg_read <= '1';
		clk <= '1';
		reg_write1 <= '1';
		reg_write2 <= '0';
		read_reg1 <= "0001";
		read_reg2 <= "0000";
		
		wait for 90ns;
		write_reg1 <= "0001";
		wait for 10ns;
		report "Entity: data_in=" & integer'image(to_integer(unsigned(write_reg1)));

		write_data1 <= "0000000000000001";
		wait for 10ns;
		clk <= '0';
		wait for 100ns;
		clk <= '1';
		wait for 100ns;
		clk <= '0';
		wait for 100ns;
		
		wait;
	end process;
	
	
end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_register_file of register_file_tb is
	for TB_ARCHITECTURE
		for UUT : register_file
			use entity work.register_file(gate_level);
		end for;
	end for;
end TESTBENCH_FOR_register_file;

