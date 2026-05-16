# bp_processor Design Decisions

Per-platform notes for Black-Parrot, an open-source RISC-V multicore from the BSG group at UW.

| Variant | Description |
|---|---|
| `bp_uno` | Single-core BP (`e_bp_unicore_cfg`) — minimal config for first-bring-up. |
| `bp_quad` | Four-core multicore (`e_bp_multicore_4_cfg`) — exercises the on-chip mesh + LLC + coherency. |

FakeRAM macros live at `designs/<platform>/bp_processor/sram/{lef,lib}/`. The wrapper `designs/<platform>/bp_processor/macros.v` swaps `bsg_mem_*_synth` instances for hard macros above a 1024-bit threshold and lets the rest synthesize as FF arrays.

## FakeRAM regeneration (2026-05-13)

- **Generator**: `bsg_fakeram` (VLSIDA fork @ `asap7-area-calib-v2`, with `write_granularity: 1` enabled for per-bit write masks). Run via `tools/regenerate_sram.sh bp_processor <platform>`.
- **Cfg**: `designs/src/bp_processor/dev/generated/fakeram_{asap7,nangate45}.cfg` — 6 macros each, `1rw + per-bit wmask`.
- **Macros.v generator**: `designs/src/bp_processor/dev/gen_macros_v.py` produces both `designs/asap7/bp_processor/macros.v` and `designs/nangate45/bp_processor/macros.v` with bsg_fakeram's port-index pin names (`rw0_clk`, `rw0_ce_in`, `rw0_we_in`, `rw0_wmask_in`, `rw0_addr_in`, `rw0_wd_in`, `rw0_rd_out`).
- **Prior generator**: in-repo `designs/src/bp_processor/dev/gen_fakeram.py` (area_per_bit heuristic + macros.v emission, now deleted).

### Macro vs FF fallback

The original 8-size LARGE_CONFIGS list shrinks to 6; two sizes become FF arrays via the `else begin : nz` branch of `macros.v`:

| (D, W) | Bits | Status | Reason |
|---|---:|---|---|
| 512x64 | 32 768 | macro | |
| 64x184 | 11 776 | macro | |
| 512x8 | 4 096 | macro | |
| 64x50 | 3 200 | macro | |
| **32x66** | 2 112 | **FF** | depth-32 fails CACTI on nangate45 (the +8-bit retry can't recover) |
| 32x48 | 1 536 | macro | |
| **8x174** | 1 392 | **FF** | depth-8 fails CACTI on nangate45 |
| 128x8 | 1 024 | macro | |

Per-bit write masking is necessary for the `bsg_mem_1rw_sync_mask_write_bit_synth` flavour — bp_processor passes `w_mask_i[width_p-1:0]` straight through to `rw0_wmask_in`. The bsg_fakeram fork patch (`write_granularity: 1`) is what makes that legal LEF/LIB/.v emission.
