onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label Resetn /testbench/Resetn
add wave -noupdate -label Clock /testbench/CLOCK_50
add wave -noupdate -label KEY /testbench/KEY
add wave -noupdate -label SW /testbench/SW
add wave -noupdate -label HEX0 /testbench/HEX0
add wave -noupdate -label HEX1 /testbench/HEX1
add wave -noupdate -label HEX2 /testbench/HEX2
add wave -noupdate -label HEX3 /testbench/HEX3
add wave -noupdate -label HEX4 /testbench/HEX4
add wave -noupdate -label HEX5 /testbench/HEX5
add wave -noupdate -label LEDR /testbench/LEDR
add wave -noupdate -divider proc
add wave -noupdate -label Resetn /testbench/U1/U3/Resetn
add wave -noupdate -label Clock /testbench/U1/U3/Clock
add wave -noupdate -label Run /testbench/U1/U3/Run
add wave -noupdate -label IR -radix octal /testbench/U1/U3/IR
add wave -noupdate -label FSM -radix hexadecimal /testbench/U1/U3/Tstep_Q
add wave -noupdate -label Done /testbench/U1/U3/Done
add wave -noupdate -label W /testbench/U1/U3/W
add wave -noupdate -label PC -radix hexadecimal /testbench/U1/U3/R7
add wave -noupdate -label DIN -radix hexadecimal /testbench/U1/U3/DIN
add wave -noupdate -label ADDR -radix hexadecimal /testbench/U1/U3/ADDR
add wave -noupdate -label inst_mem -radix hexadecimal /testbench/U1/inst_mem_q
add wave -noupdate -label Xreg -radix Unsigned /testbench/U1/U3/Xreg
add wave -noupdate -label Yreg -radix Unsigned /testbench/U1/U3/Yreg
add wave -noupdate -label R0 -radix Hexadecimal /testbench/U1/U3/R0
add wave -noupdate -label R1 -radix Hexadecimal /testbench/U1/U3/R1
add wave -noupdate -label R2 -radix Hexadecimal /testbench/U1/U3/R2
add wave -noupdate -label R3 -radix Hexadecimal /testbench/U1/U3/R3
add wave -noupdate -label R4 -radix Hexadecimal /testbench/U1/U3/R4
add wave -noupdate -label R5 -radix Hexadecimal /testbench/U1/U3/R5
add wave -noupdate -label R6 -radix Hexadecimal /testbench/U1/U3/R6
add wave -noupdate -label R7 -radix Hexadecimal /testbench/U1/U3/R7
add wave -noupdate -label A -radix Unsigned /testbench/U1/U3/A
add wave -noupdate -label G -radix Unsigned /testbench/U1/U3/G
add wave -noupdate -label DINout /testbench/U1/U3/DINout
add wave -noupdate -label Rin /testbench/U1/U3/Rin
add wave -noupdate -label sum_c /testbench/U1/U3/sum_c
add wave -noupdate -label Gout /testbench/U1/U3/Gout
add wave -noupdate -label BusWires /testbench/U1/U3/BusWires
add wave -noupdate -label flag_z /testbench/U1/U3/flag_z
add wave -noupdate -label flag_c /testbench/U1/U3/flag_c
add wave -noupdate -label flag_c_temp /testbench/U1/U3/flag_c_temp


TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {200000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 112
configure wave -valuecolwidth 64
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {560 ns}
