# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog mux7to1.v

#load simulation using mux as the top level simulation module
vsim mux7to1

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

# switch test case
force {SW[7]} 0 0ns, 1 {5ns} -r 10ns
force {SW[8]} 0 0ns, 1 {10ns} -r 20ns
force {SW[9]} 0 0ns, 1 {20ns} -r 40ns

# input test case (on/off)
force {SW[0]} 0 0ns, 1 40ns, 0 {80ns} -r 320ns
force {SW[1]} 0 0ns, 1 80ns, 0 {120ns} -r 320ns
force {SW[2]} 0 0ns, 1 120ns, 0 {160ns} -r 320ns
force {SW[3]} 0 0ns, 1 160ns, 0 {200ns} -r 320ns
force {SW[4]} 0 0ns, 1 200ns, 0 {240ns} -r 320ns
force {SW[5]} 0 0ns, 1 240ns, 0 {280ns} -r 320ns
force {SW[6]} 0 0ns, 1 280ns, 0 {320ns} -r 320ns


#run simulation for a few ns
run 320ns