# vivado -mode batch -source proceduralLeapyeartb.tcl
# use xvlog, xelab and xsim for simulation
# read_verilog, synth_design for FPGA implemention

exec xvlog -sv leapyeartb.v ../design/procedural/leapyear.v
# lint files
exec xelab leapyeartb

exec xsim leapyeartb -runall

exit