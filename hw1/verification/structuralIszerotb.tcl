# copyright (C) Matthew Hardenburgh
# matthew@hardenburgh.io

# vivado -mode batch -source structuralIszerotb.tcl
# use xvlog, xelab and xsim for simulation
# read_verilog, synth_design for FPGA implemention

exec xvlog -sv iszerotb.v ../design/structural/iszero.v
# lint files
exec xelab top

exec xsim top -runall

exit