transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/Barney/OneDrive\ -\ University\ of\ Toronto/2.\ Homework/10.\ Computer\ Organization\ (ECE243)/Labs/Lab\ 1\ Introduction\ to\ Processors/part1 {D:/Barney/OneDrive - University of Toronto/2. Homework/10. Computer Organization (ECE243)/Labs/Lab 1 Introduction to Processors/part1/main.v}
vlog -vlog01compat -work work +incdir+D:/Barney/OneDrive\ -\ University\ of\ Toronto/2.\ Homework/10.\ Computer\ Organization\ (ECE243)/Labs/Lab\ 1\ Introduction\ to\ Processors/part1 {D:/Barney/OneDrive - University of Toronto/2. Homework/10. Computer Organization (ECE243)/Labs/Lab 1 Introduction to Processors/part1/proc.v}

vlog -vlog01compat -work work +incdir+D:/Barney/OneDrive\ -\ University\ of\ Toronto/2.\ Homework/10.\ Computer\ Organization\ (ECE243)/Labs/Lab\ 1\ Introduction\ to\ Processors/part1 {D:/Barney/OneDrive - University of Toronto/2. Homework/10. Computer Organization (ECE243)/Labs/Lab 1 Introduction to Processors/part1/testbench.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  testbench

add wave *
view structure
view signals
run -all
