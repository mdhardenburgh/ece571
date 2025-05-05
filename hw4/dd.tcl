# copyright (C) Matthew Hardenburgh
# matthew@hardenburgh.io

# vivado -mode batch -source dd.tcl
# use xvlog, xelab and xsim for simulation
# read_verilog, synth_design for FPGA implemention

exec xvlog -sv dd.sv ddTest.sv ddtb.sv --define DEBUG=1
# lint files
exec xelab top --define DEBUG=1

exec xsim top -runall 

exit