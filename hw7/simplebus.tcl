# copyright (C) Matthew Hardenburgh
# matthew@hardenburgh.io

# vivado -mode batch -source simplebusif.tcl
# use xvlog, xelab and xsim for simulation
# read_verilog, synth_design for FPGA implemention

exec xvlog -sv simplebus.sv
# lint files
exec xelab top

exec xsim top -runall 

exit