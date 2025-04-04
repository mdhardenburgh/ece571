# vivado -mode batch -source dataflowDivbyfourtb.tcl
# use xvlog, xelab and xsim for simulation
# read_verilog, synth_design for FPGA implemention

exec xvlog -sv divbyfourtb.v ../design/dataflow/divbyfour.v
# lint files
exec xelab divbyfourtb

exec xsim divbyfourtb -runall

exit