SetActiveLib -work
comp -include "$dsn\src\CAP23.vhd" 
comp -include "$dsn\src\TestBench\cap23_TB.vhd" 
asim +access +r TESTBENCH_FOR_cap23 
wave 
wave -noreg clk
wave -noreg reset
wave -noreg set_pc
wave -noreg set_pc_value
wave -noreg im_write_address
wave -noreg im_write_data
wave -noreg im_reg_write
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\cap23_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_cap23 
