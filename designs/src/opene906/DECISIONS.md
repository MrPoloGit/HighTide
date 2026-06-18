# opene906 DECISIONS

OpenE906: T-Head (Alibaba) 5-stage in-order RISC-V RV32GC with FPU, ICache, DCache, CLIC-128, TDT debug.
RTL from [XUANTIE-RV/opene906](https://github.com/XUANTIE-RV/opene906), Apache 2.0.

222 core Verilog modules + 8 FPGA behavioral SRAM models + 6 pa_spsram wrapper stubs (~105k lines total).
Top module: `openE906`. Two clock domains: `pll_core_cpuclk` (CPU) and `sys_apb_clk` (APB TDT debug).

Cache memory architecture: cache size selected at synth time via `ICACHE_*K` / `DCACHE_*K` defines.
The RTL instantiates abstract `pa_spsram_*` modules; the fpga/ directory provides behavioral equivalents
named `pa_f_spsram_*`. `pa_spsram_stubs.v` bridges the two naming conventions.

## sky130hd

**Status**: first pass (not yet validated through `_final`)

| Knob | Value | Notes |
|------|-------|-------|
| `CORE_UTILIZATION` | 40 | Conservative first pass |
| `PLACE_DENSITY` | 0.6 | Standard sky130hd baseline |
| `CORE_MARGIN` | 12 | Standard for sky130hd |
| `VERILOG_DEFINES` | `-D ICACHE_2K -D DCACHE_2K` | Smallest cache config (SRAM sizes ≤ 256×32) |
| `SYNTH_MEMORY_MAX_BITS` | 65536 | Forces all 6 cache SRAMs to FF synthesis |
| SDC `cpu_clk_period` | 25 ns | 40 MHz — conservative for 130nm, tighten after first run |
| `sys_apb_clk_period` | 200 ns | 5 MHz TDT APB debug; async-isolated |

**Decisions**:
- ICACHE_2K + DCACHE_2K: smallest available cache configuration; total SRAM state ≈ 23 Kbits.
  FFs add ~23K flip-flops above the CPU logic. Use /generate-sram to replace with FakeRAM macros
  (named `pa_spsram_*`) for a realistic area/timing benchmark.
- `pa_spsram_stubs.v` wraps `pa_f_spsram_*` FPGA behavioral models (bit-masked 1RW SRAMs)
  under the `pa_spsram_*` names that the core RTL instantiates.
- `gated_clk_cell` is a behavioral pass-through stub (`assign clk_out = clk_in`) — no ICG blackboxing.
- Scan/test ports set to `set_case_analysis 0`; async-reset (`pad_cpu_rst_b`), all strap inputs
  (`pad_bmu_*_base/mask`, `pad_cpu_sysmap_addr*`, `pad_cpu_tcip_base`) are `set_false_path -from`.
- TDT APB debug clock (`sys_apb_clk`) isolated with `set_clock_groups -asynchronous`.

**Known issues / open questions**:
- FF-based caches inflate cell count; DCache tag (32×46), ICache tag (32×47) have non-power-of-2
  widths (fine for behavioral synthesis but unusual for FakeRAM generation).
- BHT (`pa_spsram_512x16` = 8192 bits) is hardcoded regardless of cache size define.
- FPU introduces additional pipeline stages; critical path may be in FDIV/FSQRT → tighten
  period once `period_min` is known from `6_finish.rpt`.
- `sys_apb_rst_b` is in the APB domain — covered by `set_clock_groups -async`.
- No `pdn.tcl` or `io.tcl` yet — add if congestion or IR drop surfaces.
