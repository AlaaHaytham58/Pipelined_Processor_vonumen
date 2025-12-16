vcom -2008 M_W_Register.vhd
vcom -2008 M_W_Register_tb.vhd

vsim M_W_Register_tb

add wave -radix hex sim:/M_W_Register_tb/*

run -all