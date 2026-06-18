# opene902 DECISIONS

OpenE902: T-Head (Alibaba) 2-stage in-order RISC-V RV32EC microcontroller core.
RTL from [XUANTIE-RV/opene902](https://github.com/XUANTIE-RV/opene902), Apache 2.0.

87 pure Verilog modules (~36k lines), no SRAMs in the CPU core (GPRs are flip-flop arrays).
Top module: `openE902`. Two clock domains: `pll_core_cpuclk` (CPU) and `pad_had_jtg_tclk` (JTAG debug).

## sky130hd

**Status**: first pass (not yet validated through `_final`)

| Knob | Value | Notes |
|------|-------|-------|
| `CORE_UTILIZATION` | 40 | Conservative first pass |
| `PLACE_DENSITY` | 0.6 | Matches minimax sky130hd baseline |
| `CORE_MARGIN` | 12 | Standard for sky130hd |
| SDC `cpu_clk_period` | 20 ns | 50 MHz — conservative for 130nm, tighten once clean |
| `jtag_clk_period` | 200 ns | 5 MHz; async-isolated via `set_clock_groups` |

**Decisions**:
- Concatenate all 87 gen_rtl .v files into a single `opene902.v` (no timescale/include directives found, so safe to merge).
- `gated_clk_cell` is a behavioral stub (`assign clk_out = clk_in`) — no ICG blackboxing needed.
- `pad_yy_test_mode` and `pad_yy_gate_clk_en_b` set to `set_case_analysis 0` (scan/test mode inactive).
- `pad_bmu_iahbl_base/mask` false-pathed (static IBUS memory-map straps).
- JTAG clock domain isolated with `set_clock_groups -asynchronous`; JTAG I/O timing cut by this.

**Known issues / open questions**:
- Initial period of 20 ns is a guess; run `_final` and read `period_min` from `6_finish.rpt` to converge.
- No `pdn.tcl` or `io.tcl` — add if congestion or IR drop surfaces.
