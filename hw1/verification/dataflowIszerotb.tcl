# copyright (C) Matthew Hardenburgh
# matthew@hardenburgh.io

# vivado -mode batch -source dataflowIszerotb.tcl
# use xvlog, xelab and xsim for simulation
# read_verilog, synth_design for FPGA implemention

exec xvlog -sv iszerotb.v ../design/dataflow/iszero.v
# lint files
exec xelab top

exec xsim top -runall

exit