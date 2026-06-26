# Tiny Processor — A Multi-Cycle 8-bit CPU in Verilog
 
A from-scratch, multi-cycle 8-bit processor implemented in Verilog, built to demonstrate core computer architecture concepts: instruction fetch/decode/execute pipelines (via FSM), a register file, an ALU, and a simple instruction set. The design is intentionally small and readable, making it a good reference for anyone learning RTL design or digital logic.
 
## Overview
 
`tiny_processor` is the top-level module that wires together five sub-modules into a working CPU:
 
| Module | File | Responsibility |
|---|---|---|
| `tiny_processor` | `tiny_processor.v` | Top-level integration; output register (`final_output`) |
| `program_counter` | `program_counter.v` | 4-bit PC, increments only when told to by the control unit |
| `instruction_memory` | `instruction_memory.v` | 16 x 16-bit ROM, pre-loaded with a sample program |
| `control_unit` | `control_unit.v` | 4-state FSM (Fetch → Decode → Execute → Writeback) that decodes instructions and drives all control signals |
| `register_file` | `register_file.v` | 4 x 8-bit general-purpose registers (R0–R3) |
| `alu` | `alu.v` | Combinational ALU: ADD, SUB, AND, OR, MOV |
 
The processor is **not pipelined** — each instruction takes 4 clock cycles to complete (Fetch, Decode, Execute, Writeback), controlled entirely by the FSM inside `control_unit`.
 
## Architecture
 
```
                ┌──────────────────┐
        ┌──────▶│  Program Counter │
        │       └──────────────────┘
        │                │ pc[3:0]
        │                ▼
        │       ┌──────────────────┐
        │       │ Instruction Mem  │
        │       └──────────────────┘
        │                │ instruction[15:0]
        │                ▼
        │       ┌──────────────────┐
        └───────│   Control Unit   │───────┐
        pc_update     (FSM)         │       │ alu_control, use_imm,
                └──────────────────┘       │ reg_write, store_en,
                         │ read_reg1/2,    │ imm_out
                         │ write_reg       │
                         ▼                 ▼
                ┌──────────────────┐   ┌────────┐
                │  Register File   │──▶│  ALU   │──▶ write_data / final_output
                │   (R0–R3, 8-bit) │   └────────┘
                └──────────────────┘
```
 
## Instruction Set Architecture (ISA)
 
Instructions are 16 bits wide, encoded as:
 
```
[15:13] [12:11] [10:9] [8] [7:0]
 Opcode    Rd      Rs   Flag  Immediate
```
 
| Opcode | Mnemonic | Operation | Notes |
|---|---|---|---|
| `000` | `LOAD Rd, imm` | `Rd ← Immediate` | Uses ALU MOV path (`alu_control = 101`) |
| `001` | `ADD Rd, Rs` | `Rd ← Rd + Rs` | |
| `010` | `SUB Rd, Rs` | `Rd ← Rd - Rs` | |
| `011` | `AND Rd, Rs` | `Rd ← Rd & Rs` | |
| `100` | `OR Rd, Rs` | `Rd ← Rd \| Rs` | |
| `110` | `STORE Rs` | `final_output ← Rs` | Uses the `Rs` (read_reg2) field |
| `111` | `HALT` | FSM holds at Fetch | Processor stops advancing the PC |
 
Register fields `Rd` (bits `[12:11]`) and `Rs` (bits `[10:9]`) select one of 4 registers (`R0`–`R3`).
 
## FSM (Control Unit)
 
The control unit is a classic 4-state Moore machine:
 
1. **FETCH** — Waits here forever if the current opcode is `HALT (111)`.
2. **DECODE** — Pass-through state (one cycle).
3. **EXECUTE** — ALU operation is computed combinationally based on `alu_control`.
4. **WRITEBACK** — `reg_write` or `store_en` is asserted; `pc_update` is asserted to advance to the next instruction.
`fsm_state` is exposed as a top-level output for observability in simulation/waveform viewers.
 
## Sample Program (preloaded in `instruction_memory.v`)
 
| Addr | Instruction | Effect |
|---|---|---|
| 0x0 | `LOAD R1, 2` | R1 = 2 |
| 0x1 | `LOAD R2, 8` | R2 = 8 |
| 0x2 | `ADD R1, R2` | R1 = R1 + R2 = 10 |
| 0x3 | `LOAD R2, 10` | R2 = 10 |
| 0x4 | `AND R1, R2` (encoding below) | see **Known Issue** |
| 0x5 | `STORE R1` | `final_output` = R1 |
| 0x6–0xF | `HALT` | Processor halts |
 
> ⚠️ **Known issue:** The instruction at address `0x4` is commented as `AND R1, R2` but is encoded as `011_00_01_0_00000000`. Since the `Rd` field is `00` and the `Rs` field is `01`, this actually executes `R0 ← R0 & R1`, not an operation on `R1`. As a result, `R1` is untouched and `final_output` ends up holding the **ADD** result (`10`), not an ANDed value. This is left in place intentionally as a real example of an instruction-encoding bug, and is a good exercise for anyone extending this project (try fixing the encoding to `011_01_10_0_...` and re-verify the waveform).
 
## Repository Structure
 
```
.
├── alu.v                  # Combinational ALU
├── control_unit.v         # FSM + instruction decode + control signals
├── instruction_memory.v   # 16x16-bit instruction ROM (sample program)
├── program_counter.v      # 4-bit program counter
├── register_file.v        # 4x8-bit register file
├── tiny_processor.v        # Top-level module wiring everything together
├── testbench.v             # Simulation testbench
└── README.md
```
 
## Getting Started
 
### Prerequisites
 
You need a Verilog simulator. This project was tested with [Icarus Verilog](http://iverilog.icarus.com/) (`iverilog`) and [GTKWave](http://gtkwave.sourceforge.net/) for waveform inspection.
 
```bash
# Debian/Ubuntu
sudo apt install iverilog gtkwave
 
# macOS (Homebrew)
brew install icarus-verilog gtkwave
```
 
### Running the Simulation
 
```bash
# Compile all source files + testbench
iverilog -o processor_sim tiny_processor.v alu.v control_unit.v instruction_memory.v program_counter.v register_file.v testbench.v
 
# Run the simulation
vvp processor_sim
 
# Inspect the waveform
gtkwave processor.vcd
```
 
Expected console output:
```
Simulation complete. Check processor.vcd in GTKWave.
```
 
In GTKWave, add `final_output`, `fsm_state`, and the internal wires (`pc_wire`, `instruction_wire`, etc.) to the waveform to trace execution cycle-by-cycle.
 
## Design Highlights
 
- **Modular RTL** — each functional unit (PC, instruction memory, control, register file, ALU) is a separate, independently testable module.
- **Explicit FSM-driven control** — every control signal (`reg_write`, `use_imm`, `pc_update`, `store_en`, `alu_control`) is derived from a clean 2-bit state register, making the datapath easy to trace and extend.
- **Synchronous, single-write-port register file** — straightforward read-during-write semantics suitable for teaching/learning register file design.
- **Self-contained simulation** — no external dependencies beyond a Verilog simulator; the testbench drives `clk`/`reset` and dumps a `.vcd` for waveform analysis.
## Possible Extensions
 
- Fix the `AND` instruction encoding bug noted above and add a regression check in the testbench.
- Add branch/jump instructions and conditional control flow.
- Add a `$display`-based instruction trace in the testbench for easier debugging without GTKWave.
- Parameterize register/data width (currently fixed at 8-bit data, 4-bit PC, 2-bit register select).
- Add a proper assembler/disassembler script to generate `instruction_memory.v` from assembly source.
## License
 
This project is open-sourced under the [MIT License](LICENSE). Feel free to fork, extend, or use it as a learning reference.
 
## Author
 
Built as a hands-on exercise in digital logic and computer architecture design using Verilog HDL.
 
