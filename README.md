
# ca-mips
This is a MIPS processor that we implemented as a final project for the Computer System Architecture course (CSEN601), that we take in our 6th semester of Computer Science and Engineering study at the GUC.

At the end of the project, we were expected to have (1) an implementation of a pipelined MIPS processor, and (2) be able to test/simulate it with actual machine code instructions converted from MIPS assembly. Both objectives were reached.

However, we started with a single-cycle implementation (without pipelining,) to make sure the components were working well, then we added pipeline registers to allow pipelining.

This project was implemented in **Verilog.** We used **ModelSim Altera** to simulate the full processor, and **JDoodle** to edit some of the component modules at the beginning.

#### Dates

**Deadline:** Friday, ***May 4th,*** 2018.

**Submission:** Wednesday, ***May 2nd,*** 2018.

**Evaluation:** Monday, ***May 7th,*** 2018.


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
