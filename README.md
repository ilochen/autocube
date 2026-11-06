# Autocube

[![Validation](https://github.com/ilochen/autocube/actions/workflows/check.yml/badge.svg)](https://github.com/ilochen/autocube/actions/workflows/check.yml)

DE2-115 FPGA Rubik’s Cube solver from the NTU Digital Circuit Lab project.

[Watch the team’s hardware demonstration](https://youtu.be/S8VXiabIi5Q) · [Interactive project page](https://ilochen.github.io/projects/autocube/)

The solver tracks 48 non-center stickers. Algorithm selects move combinations for successive layer checkpoints. State_Determination updates the cube representation, while motor translates relative moves into a queue of face and direction commands for Driver_Decoder. Top.sv uses a predefined initial state. The project also includes I²C corner and edge sensor logic.

The original SystemVerilog files are in rtl/ and tb/. Board sources and constraints are in board/, with supplied vectors in input/ and output/. The archive includes alternate implementations with overlapping module names. Select the matching variants before compiling. Several original benches use simulator-specific waveform tasks.

## Run the controller check

With Verilator 5 and a C++ compiler, run `make test`. The test sends a clockwise front turn, a view change, and a counterclockwise front turn. It checks that the first two physical queue entries select the green and red motors with opposite direction bits and that the view change consumes no queue slot.

## Integration map

| Function | Source | Interface |
| --- | --- | --- |
| Checkpoint controller | rtl/Algorithm.sv | Produces up to 32 four-bit operations from the 48-sticker state. |
| Sticker updates | rtl/State_Determination.sv | Applies a combination and acknowledges completion. |
| Move translation | rtl/motor.sv | Resolves the view and fills a 256-word motor queue. |
| Motor outputs | rtl/real_Driver_Decoder.sv | Driver_Decoder and En_Ctrl generate enable, direction and step. |
| Color acquisition | rtl/I2C_sensor.sv, I2C_Read.sv, I2C_Setup.sv, State_Preparer.sv | Corner and edge samples feed the preparation counter. |

Top.sv supplies a predefined starting sticker vector and declares 12 MHz, 2 kHz, and 100 kHz clock domains. Top_planB.sv is an alternate top. The original Quartus assignment file refers to course-directory paths outside this export; adapting those paths and providing board-specific IP is necessary before a board rebuild. The automated check covers motor queue translation. The physical demonstration is linked above.

## Elaborate the system

Run `make lint` from the repository root. The source list `rtl/top.f` selects the integrated Top.sv and real_Driver_Decoder.sv variants and both I²C engines. Verilator 5.052 elaborates this list. The supplied Top leaves the `i_dd_done` input open on Algorithm and motor, which matters when interpreting the random-wait and queue-clear transitions. Check those connections when selecting a hardware variant. Elaborating the hierarchy and running the motor unit test are separate from reproducing the physical board run.

CI uses the official Verilator 5.052 image pinned by digest. Older distributions can reject the sequential tri-state assignments in the original I²C modules even though the motor unit compiles.

## Validation snapshot

The selected top-level hierarchy elaborates, and the motor-queue unit test passes. A complete board rebuild remains dependent on the missing clock-IP project and board integration items listed below.

Rechecked on 6 November 2026. Simulation results establish the covered functional behavior; physical implementation measurements are identified separately in the documentation.

[Board integration and missing original artifacts](docs/board-integration.md)

## External clock-generation dependency

The board wrapper expects a Quartus Platform Designer/Qsys module named `Altpll`. Its generated IP and configuration are external to this source release. The wrapper connects a 50 MHz board clock to this module and consumes 12 MHz, 100 kHz and 2 kHz outputs. Provide a compatible clock-generation implementation before building the board design; frequency division may be required in addition to a PLL.

The portable `make lint` and `make test` targets do not instantiate the board wrapper and do not require this IP. See the [clock interface and board integration guide](docs/board-integration.md) for the required ports and remaining hardware integration steps.
