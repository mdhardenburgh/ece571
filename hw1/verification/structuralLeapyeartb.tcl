# vivado -mode batch -source structuralLeapyeartb.tcl
# use xvlog, xelab and xsim for simulation
# read_verilog, synth_design for FPGA implemention

exec xvlog -sv leapyeartb.v ../design/structural/leapyear.v
# lint files
exec xelab leapyeartb

exec xsim leapyeartb -runall

exit