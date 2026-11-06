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
