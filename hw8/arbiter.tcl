# copyright (C) Matthew Hardenburgh
# matthew@hardenburgh.io

# vivado -mode batch -source arbiter.tcl
# use xvlog, xelab and xsim for simulation
# read_verilog, synth_design for FPGA implemention
# exec xvlog -sv arbiter.sv top.sv assertions.sv --define cause_after_grant_agent_does_not_contine_to_request_after_256_cycles

exec xvlog -sv arbiter.sv top.sv assertions.sv
# lint files
exec xelab top

exec xsim top -runall 

exit