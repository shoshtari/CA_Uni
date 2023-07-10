SetActiveLib -work
comp -include "$dsn\src\register_file.vhd" 
comp -include "$dsn\src\TestBench\register_file_TB.vhd" 
asim +access +r TESTBENCH_FOR_register_file 
wave 
wave -noreg reg_read
wave -noreg read_reg1
wave -noreg read_reg2
wave -noreg write_reg1
wave -noreg write_reg2
wave -noreg reg_write1
wave -noreg reg_write2
wave -noreg write_data1
wave -noreg write_data2
wave -noreg clk
wave -noreg data_out1
wave -noreg data_out2
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\register_file_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_register_file 
