current_design openE902

# Conservative first-pass period for sky130hd (50 MHz).
# The design is a 2-stage in-order RISC-V CPU; tighten once the flow is clean.
set cpu_clk_period 20
set clk_io_pct 0.2

create_clock -name cpu_clk  -period $cpu_clk_period [get_ports pll_core_cpuclk]

# JTAG is a secondary async domain running at ~5 MHz; isolate it from timing analysis.
create_clock -name jtag_clk -period 200 [get_ports pad_had_jtg_tclk]

set_clock_groups -asynchronous \
    -group [get_clocks cpu_clk] \
    -group [get_clocks jtag_clk]

# Test/scan mode pins: inactive during normal operation.
set_case_analysis 0 [get_ports pad_yy_test_mode]
set_case_analysis 0 [get_ports pad_yy_gate_clk_en_b]

# IBUS memory-map straps: static configuration, no timing path.
set_false_path -from [get_ports {pad_bmu_iahbl_base pad_bmu_iahbl_mask}]

# I/O delays: exclude both clock ports, constrain everything else to cpu_clk.
# JTAG I/O paths are cut by set_clock_groups above.
set non_clock_inputs [lsearch -inline -all -not -exact \
    [lsearch -inline -all -not -exact [all_inputs] [get_ports pll_core_cpuclk]] \
    [get_ports pad_had_jtg_tclk]]

set_input_delay  [expr $cpu_clk_period * $clk_io_pct] -clock cpu_clk $non_clock_inputs
set_output_delay [expr $cpu_clk_period * $clk_io_pct] -clock cpu_clk [all_outputs]
