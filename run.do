vsim -voptargs="+acc" work.processor_tb
add wave -position insertpoint  \
sim:/processor_tb/wr_en \
sim:/processor_tb/reset \
sim:/processor_tb/rd_en \
sim:/processor_tb/PC_debug \
sim:/processor_tb/OUT_PORT \
sim:/processor_tb/linenumber \
sim:/processor_tb/INTR_IN \
sim:/processor_tb/instruction_debug \
sim:/processor_tb/IN_PORT \
sim:/processor_tb/endoffile \
sim:/processor_tb/dataread \
sim:/processor_tb/CLK_PERIOD \
sim:/processor_tb/clk \
sim:/processor_tb/CCR_debug \
sim:/processor_tb/ALU_result_debug \add wave -position insertpoint  \
sim:/processor_tb/UUT/Register_file_inst/registers