# openc906 DECISIONS

OpenC906: T-Head (Alibaba) 5-stage+ in-order RISC-V RV64GCV Linux-capable CPU.
RTL from [XUANTIE-RV/openc906](https://github.com/XUANTIE-RV/openc906), Apache 2.0.

244 core Verilog modules + 6 header files + 8 FPGA SRAM models + 29 aq_spsram stubs (~142k lines).
Top module: `openC906`. AXI-4 main bus (128-bit data). Two clock domains:
`pll_core_cpuclk` (CPU) and `sys_apb_clk` (APB TDT debug).

Cache configuration is fixed in `cpu_cfig.h` (checked in, part of the merged RTL):
`ICACHE_32K`, `DCACHE_32K`, `BHT_16K`, `JTLB_ENTRY_128`. Cache sizes are **not configurable
via VERILOG_DEFINES** — they are compile-time constants in the header. Total SRAM state ≥ 620 Kbits.

SRAM macros: 29 distinct `aq_spsram_<depth>x<width>` types. Only 8 have FPGA behavioral
equivalents (`aq_f_spsram_*`); the remaining 21 are pure behavioral stubs in `aq_spsram_stubs.v`.

## sky130hd

**Status**: placeholder — FakeRAM generation required before P&R is meaningful

| Knob | Value | Notes |
|------|-------|-------|
| `CORE_UTILIZATION` | 40 | Conservative placeholder |
| `PLACE_DENSITY` | 0.6 | Standard sky130hd baseline |
| `CORE_MARGIN` | 12 | Standard for sky130hd |
| `SYNTH_HIERARCHICAL` | 1 | Large design; needed for synthesis |
| `ABC_AREA` | 1 | Minimize area in area-dominated design |
| `SYNTH_MEMORY_MAX_BITS` | 4194304 | Forces all ~620 Kbits of cache to FF synthesis |
| SDC `cpu_clk_period` | 30 ns | ~33 MHz — conservative for RV64GCV on 130nm |
| `sys_apb_clk_period` | 200 ns | 5 MHz TDT APB debug; async-isolated |

**Decisions**:
- 6 Verilog header files (`cpu_cfig.h`, `aq_dtu_cfig.h`, `aq_idu_cfig.h`, `aq_lsu_cfig.h`,
  `sysmap.h`, `tdt_define.h`, `tdt_dmi_define.h`) are PREPENDED to the merged RTL file.
  The generated RTL uses backtick macros (e.g. `` `I_DATA_INDEX_WIDTH ``) that must be defined
  before the RTL files are processed; the headers are not `\`include`d in the generated .v files.
- `cpu_cfig.h` is the authoritative configuration: `ICACHE_32K`, `DCACHE_32K`, `BHT_16K`.
  These correspond to `aq_spsram_2048x32` (4× for ICache), `aq_spsram_2048x32` (4× for DCache),
  `aq_spsram_1024x16` (BHT). Total: 4×131072 + 4×131072 + 16384 = ~1 Mbit from caches alone.
- `aq_spsram_stubs.v` provides behavioral FF-array implementations for all 29 SRAM types.
  With `SYNTH_MEMORY_MAX_BITS = 4194304`, yosys synthesizes all as flip-flops.
- Scan/test ports, reset, and static strap inputs (apb_base, rvba) are false-pathed.
- `pad_yy_mbist_mode` case-analysis 0 (BIST inactive).

**REQUIRED next step — FakeRAM generation**:
Run `/generate-sram` to create proper LEF/LIB macros for sky130hd. The 29 SRAM types are
all 1RW single-port with bit-level WEN. Priority order by total bits:
1. `aq_spsram_2048x32` (≥8 instances, ICache+DCache data): 131K bits each
2. `aq_spsram_1024x64` (2 instances, likely vector RF or DCache): 65K bits each
3. `aq_spsram_2048x64` (1 instance): 131K bits
4. `aq_spsram_4096x32` (1 instance, commented-out larger cache): 131K bits

**Known issues / open questions**:
- `SYNTH_HIERARCHICAL = 1` may surface hierarchy-naming issues; if so, remove it and retry flat.
- The `PLIC` subsystem has 240 interrupt sources and `PLIC_INT_NUM 240` in cpu_cfig.h —
  this creates a large interrupt controller; ensure it synthesizes without timeout.
- Vector subsystem (vdsp/vfalu/vfdsu/vfmau/vidu) adds significant logic; timing may be
  dominated by vector FP divider (vfdsu).
- No `pdn.tcl` or `io.tcl` yet; with AXI 128-bit bus the IO count is high — add io.tcl
  if pin congestion surfaces.
