current_design openC910

# Conservative first-pass period for sky130hd.
# C910 is a dual-core (PROCESSOR_0 + PROCESSOR_1) superscalar OOO RV64GCV with
# 64KB I/D cache per core, 1MB L2, 1024-entry JTLB, 1024-entry BTB.
# NOTE: synthesis uses behavioral FPGA models for all SRAM arrays (20+ Mbits).
#       Run /generate-sram to replace with FakeRAM macros for realistic P&R.
set cpu_clk_period 35
set clk_io_pct 0.2

# Single external CPU clock; APB/TDT clocks derived internally.
create_clock -name cpu_clk  -period $cpu_clk_period [get_ports pll_cpu_clk]

# JTAG clock: very slow async debug clock.
create_clock -name jtag_clk -period 200 [get_ports pad_had_jtg_tclk]

set_clock_groups -asynchronous \
    -group [get_clocks cpu_clk] \
    -group [get_clocks jtag_clk]

# Scan/test mode pins: inactive during functional operation.
set_case_analysis 0 [get_ports pad_yy_scan_mode]
set_case_analysis 0 [get_ports pad_yy_icg_scan_en]
set_case_analysis 0 [get_ports pad_yy_scan_enable]
set_case_analysis 0 [get_ports pad_yy_scan_rst_b]
set_case_analysis 0 [get_ports pad_yy_dft_clk_rst_b]
set_case_analysis 0 [get_ports pad_yy_mbist_mode]

# Static configuration straps: no timing path.
set_false_path -from [get_ports pad_cpu_apb_base]
set_false_path -from [get_ports pad_core0_rvba]
set_false_path -from [get_ports pad_core1_rvba]
set_false_path -from [get_ports pad_cpu_rst_b]
set_false_path -from [get_ports pad_core0_rst_b]
set_false_path -from [get_ports pad_core1_rst_b]
set_false_path -from [get_ports pad_cpu_sys_cnt]

# I/O timing: exclude both clock ports, constrain rest to cpu_clk.
# JTAG debug I/O is cut by set_clock_groups above.
set non_clock_inputs [lsearch -inline -all -not -exact \
    [lsearch -inline -all -not -exact [all_inputs] [get_ports pll_cpu_clk]] \
    [get_ports pad_had_jtg_tclk]]

set_input_delay  [expr $cpu_clk_period * $clk_io_pct] -clock cpu_clk $non_clock_inputs
set_output_delay [expr $cpu_clk_period * $clk_io_pct] -clock cpu_clk [all_outputs]
