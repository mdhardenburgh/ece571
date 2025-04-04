# copyright (C) Matthew Hardenburgh
# matthew@hardenburgh.io

# vivado -mode batch -source structuralLeapyeartb.tcl
# use xvlog, xelab and xsim for simulation
# read_verilog, synth_design for FPGA implemention

exec xvlog -sv leapyeartb.v ../design/structural/leapyear.v ../design/structural/divbyfour.v ../design/structural/iszero.v
# lint files
exec xelab top

exec xsim top -runall

exit