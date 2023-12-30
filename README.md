# RISC-V Pipeline Processor with Three Stages

## Description
This Projects Implements Risc-V based 32 bit processor. The ISA is RV32I. The processor is pipelined with three stages of pipeline.

## Features

- Three-Stage Pipeline: Instruction Fetch, combined Decode and Execute, combined Memory and Writeback.
- Control and Status Registers (CSR): Manages processor state and control settings.
- Hazard Detection Unit: Identifies and resolves pipeline hazards to maintain efficiency.

## SystemVerilog Files Overview

- alu.sv: Arithmetic Logic Unit for arithmetic and logical operations.
- branch_comp.sv: Branch Comparator for branch instruction decisions.
- csr_reg.sv: Control and Status Register for special register operations.
- data_mem.sv: Data Memory simulating memory component for data storage.
- hazard_unit.sv: Hazard Detection Unit for identifying and resolving execution hazards.
- imm_gen.sv: Immediate Generator for processing immediate values from instructions.
- inst_decode.sv: Instruction Decoder for decoding fetched instructions.
- inst_mem.sv: Instruction Memory storing the instruction set.
- PC.sv: Program Counter tracking the current instruction address.
- Processor.sv: Main processor module integrating all components.
- reg_file.sv: Register File managing the set of processor registers.
- tb_processor.sv: Testbench for Processor used for simulation and verification.
- timer_interrupt.sv: Timer Interrupt for handling timing and interrupt operations.
- reg-id-to-ex.sv: register for holding variables for second stage of pipeline
- reg-ex-to-mem.sv: reg for holding mem stage variables for third stage of pipeline.

