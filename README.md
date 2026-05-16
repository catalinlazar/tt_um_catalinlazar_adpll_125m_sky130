![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# Tiny Tapeout Verilog Project Template

- [Read the documentation for project](docs/info.md)

## What is Tiny Tapeout?

Tiny Tapeout is an educational project that aims to make it easier and cheaper than ever to get your digital and analog designs manufactured on a real chip.

To learn more and get started, visit https://tinytapeout.com.

## Set up your Verilog project

1. Add your Verilog files to the `src` folder.
2. Edit the [info.yaml](info.yaml) and update information about your project, paying special attention to the `source_files` and `top_module` properties. If you are upgrading an existing Tiny Tapeout project, check out our [online info.yaml migration tool](https://tinytapeout.github.io/tt-yaml-upgrade-tool/).
3. Edit [docs/info.md](docs/info.md) and add a description of your project.
4. Adapt the testbench to your design. See [test/README.md](test/README.md) for more information.

The GitHub action will automatically build the ASIC files using [LibreLane](https://www.zerotoasiccourse.com/terminology/librelane/).

## Enable GitHub actions to build the results page

- [Enabling GitHub Pages](https://tinytapeout.com/faq/#my-github-action-is-failing-on-the-pages-part)

## Resources

- [FAQ](https://tinytapeout.com/faq/)
- [Digital design lessons](https://tinytapeout.com/digital_design/)
- [Learn how semiconductors work](https://tinytapeout.com/siliwiz/)
- [Join the community](https://tinytapeout.com/discord)
- [Build your design locally](https://www.tinytapeout.com/guides/local-hardening/)

## What next?

- [Submit your design to the next shuttle](https://app.tinytapeout.com/).
- Edit [this README](README.md) and explain your design, how it works, and how to test it.
- Share your project on your social network of choice:
  - LinkedIn [#tinytapeout](https://www.linkedin.com/search/results/content/?keywords=%23tinytapeout) [@TinyTapeout](https://www.linkedin.com/company/100708654/)
  - Mastodon [#tinytapeout](https://chaos.social/tags/tinytapeout) [@matthewvenn](https://chaos.social/@matthewvenn)
  - X (formerly Twitter) [#tinytapeout](https://twitter.com/hashtag/tinytapeout) [@tinytapeout](https://twitter.com/tinytapeout)
  - Bluesky [@tinytapeout.com](https://bsky.app/profile/tinytapeout.com)


`README.md` custom-tailored for 127-stage SkyWater 130nm ADPLL project. 

---

# tt_um_catalinlazar_adpll_125m_sky130

A 125 MHz All-Digital Phase-Locked Loop (ADPLL) featuring a 127-stage coarse-tapped structural ring oscillator and a high-performance synchronous feedback frequency divider. This macro is engineered for deployment on the **SkyWater 130nm (sky130) open-source PDK** via the Tiny Tapeout multi-project silicon platform.

---

## 🛠 How It Works

The architecture consists of an entirely digital macro designed to lock onto an input reference frequency or evaluate high-speed oscillator performance using budget bench instruments.

### 1. Digitally Controlled Oscillator (DCO)

The core clock engine is a structural ring oscillator comprising **127 inverter stages** (implemented via 1 active-high gating `nand2` cell and 126 sequential `inv` cells from the `sky130_fd_sc_hd` library).

* **127-Stage Path:** Delivers a nominal target baseline frequency of **$\sim$125 MHz**.
* **63-Stage Path:** An intermediate multiplexer tap allows the loop to bypass half the chain, dynamically doubling the baseline frequency to **$\sim$250 MHz** for higher-speed testing.

### 2. Jitter-Mitigated Feedback Divider

To avoid the phase-noise degradation and tracking jitter inherent to typical asynchronous ripple counters, this design utilizes a fully **synchronous parallel-gated digital divider**. Every flip-flop stage within the counter is clocked simultaneously by the raw, high-speed DCO edge, ensuring strict phase-alignment. The division factor is dynamically adjustable at run-time from **Divide-by-2 to Divide-by-17** using a 4-bit input bus.

---

## 📌 Hardware Interface & Pinout

The macro maps directly to the standard Tiny Tapeout multi-project hardware frame:

### Inputs (`ui_in`)

| Pin | Signal Name | Type | Description |
| --- | --- | --- | --- |
| `ui[0]` | `ref_clk` | Input | External high-precision reference clock pin. |
| `ui[1]` | `clk_sel` | Input | Clock Source Selector (`0` = internal 50MHz system clock, `1` = external `ref_clk`). |
| `ui[2]` | `rst_n` | Input | Active-low synchronous core reset. |
| `ui[3]` | `tap_sel` | Input | Coarse loop-length multiplexer control (`0` = 127 stages, `1` = 63 stages). |
| `ui[4]` | `div_sel[0]` | Input | Bit 0 of the feedback counter configuration bus. |
| `ui[5]` | `div_sel[1]` | Input | Bit 1 of the feedback counter configuration bus. |
| `ui[6]` | `div_sel[2]` | Input | Bit 2 of the feedback counter configuration bus. |
| `ui[7]` | `div_sel[3]` | Input | Bit 3 of the feedback counter configuration bus. |

### Outputs (`uo_out`)

| Pin | Signal Name | Type | Description |
| --- | --- | --- | --- |
| `uo[0]` | `clk_out` | Output | Clean, divided, symmetrical output feedback clock. |
| `uo[1]` | `dco_clk_raw` | Output | Direct high-speed monitor tap from the raw DCO loop. |
| `uo[2]` | `status` | Output | Logic loop status monitoring bit (reflects `rst_n` status). |
| `uo[3..7]` | `unused` | Output | Driven low (`0`) internally to ensure low-noise signoff. |

> **Note:** All bidirectional IO pins (`uio_in`, `uio_out`, `uio_oe`) are tied off as unused input paths to prevent floating gate noise across the routing matrices.

---

## 🧪 Low-Cost Bench Testing Strategy

The inclusion of the high-speed multiplexer tap and configurable synchronous divider makes it possible to thoroughly test this silicon layout on a budget using hobbyist instruments (such as a Raspberry Pi Pico and a $15 24MHz USB Logic Analyzer running PulseView/sigrok).

```
                      +-------------------+
  Reference Clock --->|   ui[0] (ref_clk) |
  (e.g. 1-5MHz Pico)  |                   |    +-------------------------+
                      |   tt_um_adpll     |--->| uo[0] (clk_out)         |---> Logic Analyzer
  Feedback Ratio ---->|   ui[7:4]         |    | (Low frequency target)  |     (Sigrok/PulseView)
  (Set div_sel)       |   (div_sel)       |    +-------------------------+
                      +-------------------+

```

### Step-by-Step Test Sequence

1. **Initialize the Core:** Toggle `ui[2]` (`rst_n`) low to wipe and align all synchronous flip-flop registers.
2. **Inject a Reference Frame:** Supply an input clock signature. Set `ui[1]` (`clk_sel`) to `1` to run a customized low-frequency reference pulse (e.g., $1\text{ MHz}$ to $5\text{ MHz}$ generated easily by an RP2040 PWM channel) straight into `ui[0]`.
3. **Configure Loop Scaling:** Set the division factor via `div_sel` (`ui[7:4]`). The loop enforces an automatic offset equation:

$$\text{Division Ratio} = \text{div\_sel} + 2$$



*Setting `div_sel` to `4'b0010` (2) sets a total loop division factor of 4.*
4. **Monitor Output Signatures:** Because the raw high-speed DCO signal might cycle too rapidly for budget analyzer probes, capture the output from `uo[0]` (`clk_out`). If your oscillator is cycling at $120\text{ MHz}$ and your division factor is set to 12, `clk_out` will exit the chip pin at a perfectly clean $10\text{ MHz}$, allowing clear visual verification of tracking performance.

---

## 📁 Repository Structure

```text
├── .github/workflows/   # Automated GDSII and datasheet check pipelines
├── docs/
│   └── info.md          # Tiny Tapeout system documentation source
├── src/
│   ├── config.json      # Anti-optimization OpenLane build definitions
│   ├── sync_divider.v   # Synchronous edge-aligned clock counter
│   └── tt_um_..._sky130.v # Top-level structural ASIC macro
└── info.yaml            # Multi-project chip assembly registry metadata

```

## 📜 License

This project is released under the open-source **Apache-2.0 License**.

---

### 🚀 To include this in your local workspace:

Simply drop this markdown text directly into a file named `README.md` at the root level of your repo, and push it up via Git:

```bash
touch README.md
# Paste the content above inside the file
git add README.md
git commit -m "docs: add structural layout README summary"
git push origin main

```