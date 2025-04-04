# copyright (C) Matthew Hardenburgh
# matthew@hardenburgh.io

# vivado -mode batch -source <your_Tcl_script>
# read_verilog, synth_design for FPGA implemention
# use xvlog, xelab and xsim for simulation

read_verilog -sv leapyear.v
# lint files
synth_design -top LeapYear -lint

exit