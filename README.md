# Autocube

DE2-115 FPGA Rubik’s Cube solver from the NTU Digital Circuit Lab project.

[Watch the team’s hardware demonstration](https://youtu.be/S8VXiabIi5Q) · [Interactive project page](https://ilochen.github.io/projects/autocube/)

The solver tracks 48 non-center stickers. Algorithm selects move combinations for successive layer checkpoints. State_Determination updates the cube representation, while motor translates relative moves into a queue of face and direction commands for Driver_Decoder. Top.sv uses a predefined initial state. The project also includes I²C corner and edge sensor logic.

The original SystemVerilog files are in rtl/ and tb/. Board sources and constraints are in board/, with supplied vectors in input/ and output/. The archive includes alternate implementations with overlapping module names. Select the matching variants before compiling. Several original benches use simulator-specific waveform tasks.
