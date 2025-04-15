# copyright (C) Matthew Hardenburgh
# matthew@hardenburgh.io

# vivado -mode batch -source multtb.tcl
# use xvlog, xelab and xsim for simulation
# read_verilog, synth_design for FPGA implemention

exec xvlog -sv fa.sv rca.sv mult.sv multtb.sv --define DEBUG=1
# lint files
exec xelab top

exec xsim top -runall 

exit