# RISC-V Processor Verilog Implementation

This repository contains a modular Verilog implementation of a RISC-V processor in two versions:

- **Sequential processor** (`/seqential/src`)
- **5-stage pipelined processor** (`/pipelined/src`)

The project focuses on building and simulating core datapath and control components, then extending them with pipeline hazard handling.

## Supported RISC-V Instructions

- `add`
- `sub`
- `and`
- `or`
- `ld`
- `sd`
- `beq`

## Repository Structure

- `/seqential/`
  - Baseline single-cycle/sequential processor implementation
  - Includes module sources, instruction/data preload files, and waveform artifacts
- `/pipelined/`
  - 5-stage pipelined implementation
  - Includes forwarding and hazard detection modules, targeted hazard test inputs, and testbenches
- `/IPA_Project_2025.pdf`, `/IPA_Project_Report.pdf`
  - Project statement and report documents

## Main Hardware Components

Across both implementations, the design is organized into reusable modules such as:

- Instruction memory
- Data memory
- Register file
- Instruction decoder / control logic
- Immediate generator
- ALU and arithmetic blocks
- Multiplexer library
- Pipeline registers (pipelined version)
- Hazard detection and forwarding units (pipelined version)

## Simulation

Typical simulation flow uses Icarus Verilog (`iverilog`) and GTKWave:

1. Compile the selected testbench (`main.v` or `main_testbench.v`).
2. Run the generated simulation binary (`vvp`).
3. Open `output.vcd` in GTKWave if waveform inspection is needed.

> Note: Tool availability depends on your environment (for example, `iverilog` may need to be installed).
