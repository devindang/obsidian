
## CH.4 Pipelining

performance of a computer is determined by three key factors:
- instruction count
- clock cycle time
- clock cycles per instruction (CPI)

Implementation of the processor determines:
- clock cycle time 
- the number of clock cycles per instruction.

three instruction classes:
- memory-reference
- arithmetic-logical
- branches

### Simplicity and Regularity

1. Use ALU after reading the registers
	- Memory-reference: address calculation
	- Arithmetic-logical: operatio execution
	- Conditional-branchs: equality test
2. 
