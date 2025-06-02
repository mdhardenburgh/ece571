# copyright (C) Matthew Hardenburgh
# matthew@hardenburgh.io

# vivado -mode batch -source arbiter.tcl
# use xvlog, xelab and xsim for simulation
# read_verilog, synth_design for FPGA implemention

exec xvlog -sv arbiter.sv top.sv assertions.sv
# lint files
exec xelab top

exec xsim top -runall 

exit