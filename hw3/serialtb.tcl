# copyright (C) Matthew Hardenburgh
# matthew@hardenburgh.io

# vivado -mode batch -source serialtb.tcl
# use xvlog, xelab and xsim for simulation
# read_verilog, synth_design for FPGA implemention

exec xvlog -sv serial.sv serialtb.sv  --define DEBUG=1
# lint files
exec xelab top --define DEBUG=1

exec xsim top -runall 

exit