# ca-mips
This is a MIPS processor that we implemented as a final project for the Computer System Architecture course (CSEN601), that we take in our 6th semester of Computer Science and Engineering study at the GUC.

At the end of the project, we were expected to have (1) an implementation of a pipelined MIPS processor, and (2) be able to test/simulate it with actual machine code instructions converted from MIPS assembly.

However, we started with a single-cycle implementation (without pipelining,) to make sure the components were working well, then we added pipeline registers to allow pipelining.

This project was implemented in **Verilog.**

#### Dates
- **Deadline:** Friday, ***May 4th,*** 2018.
- **Submission:** Wednesday, ***May 2nd,*** 2018.
- **Evaluation:** Monday, ***May 7th,*** 2018.


### Instruction set architecture (ISA)
The processor had to support the following MIPS instructions only:
- **Arithmetic:** add, sub, addi
- **Load/Store:** lw, sw, lh, lhu
- **Logic:** and, or, sll, srl, nor
- **Control flow:** beq
- **Comparison:** slt, sltu


### Authors
- **Shadi Barghash**
- **Abdelrahman Tarek**
- **Anwar Labib**
- **Daniel Achraf**


## Get started
['mips_proc'](mips_proc.v) is the module where all components are connected together and provided with the universal clock.

It can be considered as the test bench that simulates all of the components and the connections together.

### Architecture
The main processor module is designed Structural; we had a diagram, and we declared wires, used *assign* statements, and declared instances of the components, linking them to our wires and regs.

#### Remarks

1. ALU-ALU forwarding and Full forwarding (MEM-ALU) are implemented, so you shall place one **nop** instruction only for the latter one, and none at all for the earlier one.

2. No branch prediction is implemented, so you have to place **nop**s after a **beq** instruction to make sure the correct next instruction is fetched and executed.

3. Branch result is decided in the Execute stage, so you would need to waste 2 clock cycles only, with two **nop**s, instead of three.

> In the diagram, the branch result was decided in the Memory stage. However, we believe that in our simulation, the reason for doing so is not present, and so we decided to reduce the waste of clock cycles and the size of the program.

4. Extra multiplexer is added at the address of the Instruction Memory, to provide an initialization mode/datapath, where a special manual address is given to the memory to load a test program before the actual processor simulation starts, as an alternative to the normal mode/datapath where the PC value is used as the address for the instruction memory as usual and as shown in the diagram. The multiplexer uses a controlled 'initializing' `reg` (1-bit signal) to alternate between the two input sources.

5. A similar method to that in (5) is used at the inputs of the Register File read registers and Data Memory address lines, to read all their contents at the end of the simulation, as was required. Thus, they both rather use an 'ending' 1-bit signal, that is also stored and controlled in a `reg`.
