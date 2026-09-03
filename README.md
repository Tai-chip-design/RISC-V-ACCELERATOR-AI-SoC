# RISC-V INT8 AI Accelerator

A custom-designed single-cycle RISC-V CPU integrated with a self-designed INT8 systolic-array AI accelerator, connected through a memory-mapped I/O bus. Every module is independently unit-tested and the full system is verified through integration testbenches.

## Overview

This project implements, from scratch, a small SoC (System on Chip) consisting of:

- A **single-cycle RISC-V CPU** (RV32I subset) designed and coded from the instruction encoding level up — no third-party CPU core used.
- A **systolic-array INT8 accelerator** (8x8 processing elements) that performs INT8 matrix multiplication, the core operation behind neural network inference.
- A **memory-mapped bus** that lets the CPU control and communicate with the accelerator using ordinary load/store instructions.

The accelerator was validated against real quantized weights exported from a PyTorch-trained model, confirming the hardware computation matches the software reference bit-for-bit.

## Why this project

Modern AI inference chips pair a general-purpose control core with a specialized math accelerator. This project is a small-scale, from-first-principles exploration of that pattern: understanding RISC-V instruction encoding well enough to build a CPU by hand, and understanding INT8 quantized inference well enough to design the systolic array that accelerates it.

## Architecture

```
                        ┌─────────────────────────────────────────┐
                        │              soc_top.v                  │
                        │                                         │
   ┌─────────────┐      │   ┌────────────────┐                    │
   │ instruction │◄─────┼───┤                │                    │
   │   memory    │      │   │  riscv_        │                    │
   └─────────────┘      │   │  processor     │                    │
                        │   │  (single-cycle │                    │
                        │   │   RV32I CPU)   │                    │
                        │   └───────┬────────┘                    │
                        │           │ addr / wdata / memwrite      │
                        │           ▼                              │
                        │   ┌───────────────┐   addr < 0x1000      │
                        │   │ address decode│──────────────┐       │
                        │   └───────┬───────┘              │       │
                        │           │ addr >= 0x1000        ▼       │
                        │           ▼                ┌─────────────┐│
                        │   ┌───────────────┐        │ data_memory ││
                        │   │  mmio_bus.v   │        └─────────────┘│
                        │   │ (register map)│                       │
                        │   └───────┬───────┘                       │
                        │           ▼                               │
                        │   ┌───────────────────────────┐           │
                        │   │        accel_top.v         │          │
                        │   │  ┌───────────┐ ┌──────────┐│          │
                        │   │  │  weight_  │ │activation││          │
                        │   │  │  buffer   │ │ _buffer  ││          │
                        │   │  └─────┬─────┘ └────┬─────┘│          │
                        │   │        ▼            ▼      │          │
                        │   │  ┌──────────────────────┐  │          │
                        │   │  │   pe_array (8x8)      │  │         │
                        │   │  │   systolic INT8 MACs  │  │         │
                        │   │  └───────────┬──────────┘  │          │
                        │   │              ▼              │          │
                        │   │  ┌──────────────────────┐  │          │
                        │   │  │  requantize (x64)     │  │         │
                        │   │  └──────────────────────┘  │          │
                        │   │  accel_controller (FSM)     │          │
                        │   └─────────────────────────────┘          │
                        └─────────────────────────────────────────┘
```

### Memory map

| Region | Address range | Purpose |
|---|---|---|
| CPU RAM | `0x0000` - `0x0FFF` | instruction and data memory |
| CTRL | `0x1000` | write bit 0 to trigger the accelerator |
| STATUS | `0x1004` | read `busy` / `done` flags |
| SCALE / SHIFT | `0x1008` / `0x100C` | requantization parameters |
| Weight buffer | `0x2000+` | write the 8x8 INT8 weight matrix |
| Activation buffer | `0x3000+` | write the 8x8 INT8 activation matrix |
| Result | `0x4000+` | read the 8x8 INT8 output matrix |

## Instruction set

Custom single-cycle RV32I implementation supporting a deliberately scoped subset:

`ADD, SUB, ADDI, AND, OR, XOR, ANDI, ORI, XORI, BEQ, BNE, JAL, LW, SW, LUI`

Built from the instruction encoding up: a hand-written immediate generator handles all six RISC-V instruction formats (R/I/S/B/U/J), and the control unit decodes opcode/funct3/funct7 directly rather than relying on any existing core.

## Accelerator design

- **Systolic array (8x8)**: weights flow horizontally, activations flow vertically, each processing element performs a local INT8 multiply-accumulate. This is the same dataflow pattern used in TPU-style accelerators, chosen over a simpler "broadcast" design to reduce wiring complexity at the cost of requiring precisely-timed (skewed) input feeding.
- **Requantization**: 64 parallel units scale the INT32 accumulator output back down to INT8, with saturation/clamping at the [-128, 127] boundary.
- **FSM controller**: sequences the load, compute, and drain phases and generates the `done` signal the CPU polls for.

## Verification approach

Every module was unit-tested in isolation against a Python/NumPy golden model before integration, following a bottom-up V-model process:

| Module | Verified against | Result |
|---|---|---|
| ALU | hand-calculated values, boundary cases | pass |
| Register file | read/write ordering, x0 hard-wired to zero | pass |
| Immediate generator | all 6 instruction formats, sign extension | pass |
| Control unit | full opcode/funct3/funct7 table | pass |
| CPU datapath | 8+ instruction mixed program, register trace | pass |
| Processing element | signed multiply-accumulate, boundary values (-128 x -128) | pass |
| Systolic PE array (8x8) | skewed dataflow timing vs `numpy.matmul` | pass |
| Weight / activation buffers | staggered read schedule | pass |
| Requantize | scale/shift/clamp vs Python reference | pass |
| Accelerator FSM + top | full load-compute-done cycle, 2 consecutive runs (reset correctness) | pass |
| MMIO bus | address decode, register read/write | pass |
| Full SoC integration | CPU-RAM vs accelerator address isolation | pass |
| Accelerator vs real quantized weights | PyTorch-trained + quantized 8x8 layer vs RTL output | pass |

## What this project does not include (scope notes)

In the interest of an honest account of what was built:

- **No software toolchain integration.** The end-to-end demo validates the accelerator against real PyTorch-quantized weights at the RTL/testbench level, not through a compiled C program running on the CPU driving the accelerator live. Cross-compilation and linker scripting were out of scope for this iteration.
- **No FPGA synthesis / physical implementation.** The design has not been synthesized or run on real hardware; all verification is simulation-based (Questa/vsim).
- **No full neural network inference.** The accelerator was validated against one real quantized 8x8 layer, not a complete multi-layer network with tiling.

These are natural next steps rather than gaps in the core design work.

## Repository structure

```
RISC-V-ACCELERATOR-AI-SoC/
├── rtl/
│   ├── cpu/
│   │   ├── alu.v
│   │   ├── control_unit.v
│   │   ├── imm_gen.v
│   │   ├── register_file.v
│   │   ├── riscv_processor.v
│   │   └── top_cpu.v
│   ├── memory/
│   │   ├── data_memory.v
│   │   └── instruction_memory.v
│   ├── accelerator/
│   │   ├── pe.v
│   │   ├── pe_array.sv
│   │   ├── weight_buffer.sv
│   │   ├── activation_buffer.sv
│   │   ├── requantize.v
│   │   ├── accel_controller.v
│   │   └── accel_top.sv
│   └── soc/
│       ├── mmio_bus.sv
│       └── soc_top.sv
├── tb/
│   ├── cpu/
│   │   ├── tb_alu.v
│   │   ├── tb_control_unit.v
│   │   ├── tb_imm_gen.v
│   │   ├── tb_register_file.v
│   │   ├── tb_riscv_processor.v
│   │   └── tb_top_cpu.v
│   ├── accelerator/
│   │   ├── tb_pe.v
│   │   ├── tb_pe_array.sv
│   │   ├── tb_weight_buffer.v
│   │   ├── tb_activation_buffer.v
│   │   ├── tb_requantize.v
│   │   ├── tb_accel_controller.v
│   │   └── tb_accel_top.v
│   └── soc/
│       ├── tb_mmio_bus.sv
│       └── tb_soc_top.sv
├── sim/
│   └── program.hex
└── .gitignore
```

## Running the tests

Requires ModelSim/Questa (`vsim`, `vlog`). Files with a `.sv` extension use SystemVerilog unpacked array syntax and must be compiled with the `-sv` flag.

```bash
vlib work

vlog -sv \
  rtl/cpu/*.v \
  rtl/memory/*.v \
  rtl/accelerator/*.v rtl/accelerator/*.sv \
  rtl/soc/*.sv \
  tb/soc/tb_soc_top.sv

vsim -c work.tb_soc_top -do "run -all; quit"
```

Each module under `tb/` can be run independently against its corresponding file in `rtl/` for isolated verification, for example:

```bash
vlog -sv rtl/accelerator/pe.v rtl/accelerator/pe_array.sv tb/accelerator/tb_pe_array.sv
vsim -c work.tb_pe_array -do "run -all; quit"
```

## Author's note

This was built as a personal project to understand RISC-V instruction encoding and INT8 accelerator design from first principles, rather than by integrating existing IP. Feedback and questions welcome.
