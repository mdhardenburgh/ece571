# copyright (C) Matthew Hardenburgh
# matthew@hardenburgh.io

# vivado -mode batch -source simplebusbug.tcl
# use xvlog, xelab and xsim for simulation
# read_verilog, synth_design for FPGA implemention

exec xvlog -sv simplebusbug.sv
# lint files
exec xelab top

exec xsim top -runall 

exit