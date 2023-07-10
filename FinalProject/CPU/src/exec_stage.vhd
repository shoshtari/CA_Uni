Library ieee;
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

end exec_struc;