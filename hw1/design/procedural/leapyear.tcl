# vivado -mode batch -source <your_Tcl_script>

read_verilog -sv leapyear.v
# lint files
synth_design -top LeapYear -lint

exit