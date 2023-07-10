Library ieee;
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

end mem_struc;