# vivado -mode batch -source <your_Tcl_script>
# vivado -mode batch -source leapyear.tcl
# read_verilog, synth_design for FPGA implemention
# use xvlog, xelab and xsim for simulation

read_verilog -sv leapyear.v divbyfour.v iszero.v
# lint files
synth_design -top LeapYear -lint

exit