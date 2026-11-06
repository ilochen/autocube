# Board rebuild checklist

The supplied sources support hierarchy elaboration and a motor-queue regression. They are not yet a self-contained reproduction of the physical demo's Quartus project.

## Required original artifacts

- The `Altpll` Platform Designer/Qsys project, its generated source list, and the Quartus version used for the demo. `board/DE2_115.sv` instantiates ports for 12 MHz, 100 kHz, and 2 kHz outputs; the implementation is absent from the supplied archive.
- The final working QSF/QPF and selected top-level variant. The archived QSF refers to `../../include/LAB1_include.sv`, `../../sim/Top_test.sv`, `../../sim/tb_Top.sv`, and `../Top_example.sv`, which are not in this export. Its `../Top.sv` path also differs from the repository's `rtl/Top.sv`.
- Confirmation of the intended `i_dd_done` wiring for `Algorithm` and `motor`. Both ports are left open in the supplied `Top.sv`; their transitions cannot be reconstructed from the video alone.
- A wiring table for the actual motor-driver boards, supply, sensor placement, face orientation, and microstep configuration used in the demonstration.

## Existing sources

`rtl/top.f` selects the elaborated system variant, including `real_Driver_Decoder.sv`; do not compile both driver implementations together. The board wrapper, debounce module, seven-segment decoder, and original pin assignments remain under `board/`.

The wrapper maps motor enables to GPIO 0–5, step to GPIO 6, direction to GPIO 7, microstep to GPIO 8, and complemented enables to GPIO 10–15. Sensor data use GPIO 18 and 20, with clocks on 22 and 24. These are source-level assignments, not a substitute for the missing physical wiring documentation.

A full solver regression should also exercise sticker permutation and algorithm completion on multiple known scrambles, then verify the final uniform faces and emitted queue. The current motor test establishes translation for a short sequence only.

## External clock module interface

`Altpll` must expose these ports, matching the existing wrapper instance:

| Port | Direction | Connection / requested clock |
| --- | --- | --- |
| `clk_clk` | Input | `CLOCK_50`, 50 MHz board clock |
| `reset_reset_n` | Input | Active-low reset interface; wrapper connects `key3down` |
| `altpll_12m_clk` | Output | `CLK_12M`, 12 MHz |
| `altpll_100k_clk` | Output | `CLK_100K`, 100 kHz |
| `altpll_2k_clk` | Output | `CLK_2K`, 2 kHz |

Generate a compatible module with the board's Quartus/Platform Designer tools and include its generated source/IP assignment file in the selected Quartus project. Output frequencies alone do not recover the original PLL/divider topology, phase, reset behavior, or timing constraints. Check those properties and clock-domain interactions during board integration. The supplied SDC uses `derive_pll_clocks`; add and verify generated-clock constraints for any fabric dividers in the chosen implementation.

The generated clock module is not required for the repository's portable hierarchy-elaboration and motor-queue tests. This release provides the FPGA source archive and those reproducible checks; a complete board build requires the external clock IP and the integration items above.
