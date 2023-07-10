Library ieee;
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
	
	
	
end alu_struc;