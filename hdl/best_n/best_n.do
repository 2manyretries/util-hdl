vlib work

vcom cswap.vhd
vcom best_n.vhd
vcom tb_best_n.vhd

vsim work.tb_best_n

add wave sim:/tb_best_n/clk
add wave sim:/tb_best_n/rst
add wave sim:/tb_best_n/dv
add wave -radix hex sim:/tb_best_n/din
add wave -radix hex sim:/tb_best_n/res

run -all

