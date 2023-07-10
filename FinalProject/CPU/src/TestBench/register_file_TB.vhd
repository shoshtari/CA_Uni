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

