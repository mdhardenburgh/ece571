# vivado -mode batch -source structuralIszerotb.tcl
# use xvlog, xelab and xsim for simulation
# read_verilog, synth_design for FPGA implemention

exec xvlog -sv iszerotb.v ../design/structural/iszero.v
# lint files
exec xelab iszerotb

exec xsim iszerotb -runall

exit