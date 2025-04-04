# copyright (C) Matthew Hardenburgh
# matthew@hardenburgh.io

# vivado -mode batch -source structuralDivbyfourtb.tcl
# use xvlog, xelab and xsim for simulation
# read_verilog, synth_design for FPGA implemention

exec xvlog -sv divbyfourtb.v ../design/structural/divbyfour.v
# lint files
exec xelab top

exec xsim top -runall

exit