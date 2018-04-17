# ca-mips
This is a MIPS processor implementation that we are building as a final project in our 6th semester at the GUC for the Computer System Architecture course (CSEN601).

At the end of the project, we should (1) have an implementation of a pipelined MIPS processor, and (2) be able to test/simulate it with actual machine code instructions converted from MIPS assembly.

However, we started with a single-cycle implementation (without pipelining,) to make sure the components were working well, then we added pipeline registers to allow pipelining. For the time being, we are not handling data hazards nor doing branch prediction; these are bonus tasks, that we would do if we have enough time.

We are implementing this project in **Verilog.**

### Instruction set architecture (ISA)
The processor should support the following MIPS instructions only:
- **Arithmetic:** add, sub, addi
- **Load/Store:** lw, sw, lh, lhu
- **Logic:** and, or, sll, srl, nor
- **Control flow:** beq
- **Comparison:** slt, sltu


**Project Deadline:** Saturday ***April 28th,*** 2018. Evaluations will take place immediately afterwards.
