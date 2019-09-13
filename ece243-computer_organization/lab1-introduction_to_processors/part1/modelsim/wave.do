onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label Clock /testbench/Clock
add wave -noupdate -label ResetN /testbench/ResetN
add wave -noupdate -label Run /testbench/Run
add wave -noupdate -label DIN /testbench/DIN
add wave -noupdate -label Done /testbench/Done
add wave -noupdate -label BusWires /testbench/BusWires
add wave -noupdate -divider Proc
add wave -noupdate -label Rin /testbench/U1/Rin
add wave -noupdate -label Rout /testbench/U1/Rout
add wave -noupdate -label Sum /testbench/U1/Sum
add wave -noupdate -label IRin /testbench/U1/IRin
add wave -noupdate -label Done /testbench/U1/Done
add wave -noupdate -label DINout /testbench/U1/DINout
add wave -noupdate -label Ain /testbench/U1/Ain
add wave -noupdate -label Gin /testbench/U1/Gin
add wave -noupdate -label Gout /testbench/U1/Gout
add wave -noupdate -label AddSub /testbench/U1/AddSub
add wave -noupdate -label Tstep_Q -radix Unsigned /testbench/U1/Tstep_Q
add wave -noupdate -label Tstep_D -radix Unsigned /testbench/U1/Tstep_D
add wave -noupdate -label I -radix Unsigned /testbench/U1/I
add wave -noupdate -label Xreg -radix Unsigned /testbench/U1/Xreg
add wave -noupdate -label Yreg -radix Unsigned /testbench/U1/Yreg
add wave -noupdate -label R0 -radix Unsigned /testbench/U1/R0
add wave -noupdate -label R1 -radix Unsigned /testbench/U1/R1
add wave -noupdate -label R2 -radix Unsigned /testbench/U1/R2
add wave -noupdate -label R3 -radix Unsigned /testbench/U1/R3
add wave -noupdate -label R4 -radix Unsigned /testbench/U1/R4
add wave -noupdate -label R5 -radix Unsigned /testbench/U1/R5
add wave -noupdate -label R6 -radix Unsigned /testbench/U1/R6
add wave -noupdate -label R7 -radix Unsigned /testbench/U1/R7
add wave -noupdate -label A -radix Unsigned /testbench/U1/A
add wave -noupdate -label G -radix Unsigned /testbench/U1/G
add wave -noupdate -label IR /testbench/U1/IR
add wave -noupdate -label Sel /testbench/U1/Sel
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 80
configure wave -valuecolwidth 40
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
WaveRestoreZoom {0 ps} {300 ns}
