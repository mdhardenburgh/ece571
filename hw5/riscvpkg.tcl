# copyright (C) Matthew Hardenburgh
# matthew@hardenburgh.io

# vivado -mode batch -source riscvpkg.tcl
# use xvlog, xelab and xsim for simulation
# read_verilog, synth_design for FPGA implemention

exec xvlog -sv riscvpkg.sv top.sv
# lint files
exec xelab top -generic_top "PARSE_ASSEMBLY=1" -generic_top "FILENAME=\"test\""

exec xsim top -runall 

exit