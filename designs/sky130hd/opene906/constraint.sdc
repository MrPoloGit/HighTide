current_design openE906

# Conservative first-pass period for sky130hd (40 MHz).
# E906 is a 5-stage in-order RISC-V RV32GC with FPU + ICache/DCache;
# tighten once the flow is clean and period_min is known.
set cpu_clk_period 25
set clk_io_pct 0.2

create_clock -name cpu_clk    -period $cpu_clk_period [get_ports pll_core_cpuclk]

# APB debug clock (TDT DMI): secondary async domain, much slower.
create_clock -name sys_apb_clk -period 200 [get_ports sys_apb_clk]

set_clock_groups -asynchronous \
    -group [get_clocks cpu_clk] \
    -group [get_clocks sys_apb_clk]

# Scan/test mode pins: inactive (0) during functional operation.
set_case_analysis 0 [get_ports pad_yy_scan_mode]
set_case_analysis 0 [get_ports pad_yy_icg_scan_en]
set_case_analysis 0 [get_ports pad_yy_scan_enable]
set_case_analysis 0 [get_ports pad_yy_scan_rst_b]
set_case_analysis 0 [get_ports pad_yy_dft_clk_rst_b]

# Static configuration straps: no timing path.
set_false_path -from [get_ports {pad_bmu_dahbl_base pad_bmu_dahbl_mask \
                                  pad_bmu_iahbl_base pad_bmu_iahbl_mask}]
set_false_path -from [get_ports {pad_cpu_sysmap_addr0 pad_cpu_sysmap_addr0_attr \
                                  pad_cpu_sysmap_addr1 pad_cpu_sysmap_addr1_attr \
                                  pad_cpu_sysmap_addr2 pad_cpu_sysmap_addr2_attr \
                                  pad_cpu_sysmap_addr3 pad_cpu_sysmap_addr3_attr \
                                  pad_cpu_sysmap_addr4 pad_cpu_sysmap_addr4_attr \
                                  pad_cpu_sysmap_addr5 pad_cpu_sysmap_addr5_attr \
                                  pad_cpu_sysmap_addr6 pad_cpu_sysmap_addr6_attr \
                                  pad_cpu_sysmap_addr7 pad_cpu_sysmap_addr7_attr}]
set_false_path -from [get_ports pad_cpu_tcip_base]

# Reset is async — no timing path.
set_false_path -from [get_ports pad_cpu_rst_b]

# I/O timing: exclude both clock ports, constrain rest to cpu_clk.
# APB debug I/O paths are cut by set_clock_groups above.
set non_clock_inputs [lsearch -inline -all -not -exact \
    [lsearch -inline -all -not -exact [all_inputs] [get_ports pll_core_cpuclk]] \
    [get_ports sys_apb_clk]]

set_input_delay  [expr $cpu_clk_period * $clk_io_pct] -clock cpu_clk $non_clock_inputs
set_output_delay [expr $cpu_clk_period * $clk_io_pct] -clock cpu_clk [all_outputs]
