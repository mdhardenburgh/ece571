# vivado -mode batch -source <your_Tcl_script>
# vivado -mode batch -source divbyfour.tcl
# read_verilog, synth_design for FPGA implemention
# use xvlog, xelab and xsim for simulation

read_verilog -sv divbyfour.v
# lint files
synth_design -top DivisibleByFour -lint

exit