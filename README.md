# ca-mips
This is a MIPS processor implementation that we are building as a final project in an academic course in our 6th semester at the GUC: Computer System Architecture (CSEN601).

At the end of the project, we should (1) have an implementation of a pipelined MIPS processor, and (2) be able to test/simulate it with actual machine code instructions converted from MIPS assembly.

However, we will start with a single-cycle implementation (without pipelining,) to make sure the components are working well, then we add pipeline registers to allow pipelined processing.

We are going to implement this project in **Verilog.**

### Instruction set architecture (ISA)
The processor should support the following MIPS instructions only:
- **Arithmetic:** add, sub, addi
- **Load/Store:** lw, sw, lh, lhu
- **Logic:** and, or, sll, srl, and, or
- **Control flow:** beq
- **Comparison:** slt, sltu


**Project Deadline:** Friday ***April 21st,*** 2016. Evaluations will take place immediately afterwards.
