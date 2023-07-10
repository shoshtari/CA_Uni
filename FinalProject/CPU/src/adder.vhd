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
end architecture adder_struc;