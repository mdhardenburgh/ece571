# vivado -mode batch -source dataflowLeapyeartb.tcl
# use xvlog, xelab and xsim for simulation
# read_verilog, synth_design for FPGA implemention

exec xvlog -sv leapyeartb.v ../design/dataflow/leapyear.v
# lint files
exec xelab leapyeartb

exec xsim leapyeartb -runall

exit