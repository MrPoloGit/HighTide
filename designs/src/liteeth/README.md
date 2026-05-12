# LiteEth Cores

## Quick Start

Build any liteeth variant through the Bazel flow:

```bash
bazel build //designs/nangate45/liteeth/<variant>:<variant>_final
# e.g.
bazel build //designs/nangate45/liteeth/liteeth_mac_axi_mii:liteeth_mac_axi_mii_final
```

The release RTL is pre-generated. To regenerate from the upstream
liteeth submodule, run with `--define update_rtl=true`:

```bash
bazel build --define update_rtl=true //designs/nangate45/liteeth/liteeth_mac_axi_mii:liteeth_mac_axi_mii_final
```

This initializes the `designs/src/liteeth/dev/repo` submodule and
runs `designs/src/liteeth/dev/setup.sh` to (re)generate the Verilog.

---

## Generated Cores

- liteeth_mac_axi_mii
- liteeth_mac_wb_mii
- liteeth_udp_stream_sgmii
- liteeth_udp_stream_rgmii
- liteeth_udp_raw_rgmii
- liteeth_udp_usp_gth_sgmii
