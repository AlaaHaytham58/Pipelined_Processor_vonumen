vcom -2008 E_M_Register.vhd
vcom -2008 E_M_Register_tb.vhd

vsim E_M_Register_tb

add wave -radix hex sim:/E_M_Register_tb/*

run -all