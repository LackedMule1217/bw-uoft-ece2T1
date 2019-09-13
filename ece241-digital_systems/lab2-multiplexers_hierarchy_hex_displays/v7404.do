# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog mux2to1.v

#load simulation using mux as the top level simulation module
vsim v7404

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

# test case
force {pin1} 0 0ns, 1 {5ns} -r 10ns

force {pin2} 0 0ns, 1 {5ns} -r 10ns

force {pin3} 0 0ns, 1 {5ns} -r 10ns

force {pin4} 0 0ns, 1 {5ns} -r 10ns

force {pin5} 0 0ns, 1 {5ns} -r 10ns

force {pin6} 0 0ns, 1 {5ns} -r 10ns

#run simulation for a few ns
run 10ns