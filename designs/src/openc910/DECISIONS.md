# openc910 DECISIONS

OpenC910: T-Head (Alibaba) dual-core superscalar out-of-order RISC-V RV64GCV processor.
RTL from [XUANTIE-RV/openc910](https://github.com/XUANTIE-RV/openc910), Apache 2.0.

441 non-fpga core modules + 41 ct_f_spsram_* FPGA models (~415k lines total).
Top module: `openC910`. AXI-4 main bus (128-bit data, 40-bit PA).
Single external clock: `pll_cpu_clk`. Secondary clock: `pad_had_jtg_tclk` (JTAG debug).
APB and TDT debug clocks are derived internally from pll_cpu_clk.

Default configuration (hardcoded in `cpu_cfig.h`):
- `ICACHE_64K` + `DCACHE_64K` (per core), `L2_CACHE_1M` + `L2_CACHE_16WAY`
- `JTLB_ENTRY_1024`, `BTB_1024`, `IBP_PRO` (indirect branch predictor)
- `MULTI_PROCESSING` (PROCESSOR_0 + PROCESSOR_1 — 2 cores)
- `PLIC` with 144 interrupts, `PMP` (8 regions), `HPCP` (16 perf counters)
- `FPR_WIDTH 63`, `VEC_WIDTH 63` (double precision FPU + vector unit)
- `FPGA` (enables ct_f_spsram_* behavioral models — set in cpu_cfig.h)
- `L1_CACHE_ECC` is NOT defined → non-ECC data SRAMs (2048x32, not 2048x33)

SRAM: 42 distinct `ct_spsram_*` abstract types, all with `ct_f_spsram_*` behavioral
FPGA models. No additional stubs needed. Total SRAM capacity > 20 Mbits:
- L2 data: ct_spsram_65536x128 or ct_spsram_32768x128 (up to 8 Mbit each)
- ICache data (×2 cores): 4 × ct_spsram_2048x32_split per core = ~512 Kbits/core
- DCache data (×2 cores): similar to ICache
- L2 tag, TLB, BTB, BHT, issue queues, ROB, etc.

## sky130hd

**Status**: placeholder — FakeRAM generation required before P&R is meaningful.
bp_quad-scale design; expect multi-100GB RAM and 14h+ for P&R once FakeRAM is in place.

| Knob | Value | Notes |
|------|-------|-------|
| `CORE_UTILIZATION` | 40 | Conservative placeholder |
| `PLACE_DENSITY` | 0.6 | Standard sky130hd baseline |
| `CORE_MARGIN` | 12 | Standard for sky130hd |
| `SYNTH_HIERARCHICAL` | 1 | Needed for design this large |
| `ABC_AREA` | 1 | Minimize area |
| `SYNTH_MEMORY_MAX_BITS` | 268435456 | Allows all ct_f_spsram_* to be inferred as FF |
| SDC `cpu_clk_period` | 35 ns | ~28 MHz — conservative for OOO RV64 on 130nm |
| `jtag_clk_period` | 200 ns | 5 MHz JTAG; async-isolated |

**Decisions**:
- `cpu_cfig.h` and `sysmap.h` are PREPENDED to the merged RTL file. Both headers
  define backtick macros (``\`define FPGA``, ``\`define ICACHE_64K``, etc.) that the gen_rtl
  Verilog files use directly via backtick references. They are not `\`include`d in the
  generated .v files; the headers must appear before any module that uses them.
- `cpu_cfig.h` defines `\`define FPGA` which activates the `ct_f_spsram_*` behavioral FPGA
  models in each `ct_spsram_*.v` wrapper. No additional stubs needed.
- Scan/test ports, per-core and global reset, static configuration straps (rvba, apb_base,
  sys_cnt), and MBIST ratio inputs are false-pathed or case-analyzed.
- `SYNTH_MEMORY_MAX_BITS = 268435456` (256M bits) forces ALL ct_f_spsram_* arrays to FF
  synthesis. This will produce a design with >20M flip-flops — synthesis will complete but
  P&R is meaningless and will not finish in reasonable time.

**REQUIRED next step — FakeRAM generation**:
Run `/generate-sram` to create LEF/LIB macros for sky130hd. The ct_spsram_* types all have
the same 1RW interface (A, CEN, CLK, D, GWEN, WEN, Q) with bit-level WEN.

Priority order by impact (total bits):
1. `ct_spsram_65536x128` or `ct_spsram_32768x128` — L2 data (4–8 Mbit each; use 2 instances)
2. `ct_spsram_16384x128`, `ct_spsram_8192x128` — L2 data variants
3. `ct_spsram_2048x32_split` (×4 banks × 2 arrays × 2 cores) — ICache data
4. `ct_spsram_2048x32` (DCache data)

**Known issues / open questions**:
- `SYNTH_HIERARCHICAL = 1` required; 441 modules flat may exhaust ABC memory.
- Dual-core increases die area roughly 2× vs single-core; sky130hd floorplan will be huge.
- The L2 cache interconnect (multi-bank L2) creates complex routing; io.tcl may be needed
  for the AXI master port (wide bus) and coherency interface.
- `axim_clk_en` is an AXI clock-enable output; it is a registered signal so it should be
  fine in the SDC, but verify it's not mis-identified as a clock by OpenROAD.
- No `pdn.tcl` or `io.tcl` yet.
