# copyright (C) Matthew Hardenburgh
# matthew@hardenburgh.io

# vivado -mode batch -source <your_Tcl_script>
# vivado -mode batch -source iszero.tcl
# read_verilog, synth_design for FPGA implemention
# use xvlog, xelab and xsim for simulation

read_verilog -sv iszero.v
# lint files
synth_design -top IsZero -lint

exit