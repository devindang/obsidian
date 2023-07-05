### CMOS vs. Bipolar(TTL)

Generally speaking, CMOS transistors are preferred for low-power, high-noise-immunity, and high-integration-density applications, while bipolar transistors are preferred for high-speed, high-gain, and high-linearity applications.

![[CMOS_symbol.png]]

![[CMOS_inverter.png]]

![[dynamic_power.png]]
Only during switching from high to low or from low to high, current is flowing for a very short time across both transistors .

![[dynamic_power_1.png]]
P = SCV^2f
![[dynamic_losses.png]]

###  Universal Gate

The universal gate is a NAND gate or NOR gate.

https://www.eeweb.com/implementing-logic-functions-using-only-nand-or-nor-gates/

In a CMOS based circuit,

- NOT gate: 2 transistor
- NAND, NOR gate: 4 transistor
- AND, OR gate: 6 transistor

Actually, an AND gate is comprised of a NAND gate and a NOT gate, so does an OR gate.

refs: https://forum.allaboutcircuits.com/threads/number-of-cmos-transistors-required-for.43613/


74HC283 : Look-Ahead Full Adder
74HC85 : Comparator

### Circuit Diagram

1. Half Adder



![[half_adder.png]]

2. Full Adder

![[full_adder.png]]

Another expression:

> $\sum=(A \xor B) \xor C$
> $C_{out}=AB+(A+B)C$
> $C_{out}=C_g+C_p C_{in}$, where, $C_g=AB$, $C_p=A+B$

3. Multiplexer

![[MUX4.png]]

4. SR Latch

8 transistors

![[SR_latch.png]]

5. Negative-OR Equivalent NAND based SR Latch

8 transistors

![[SR_not_latch.png]]

6. D Latch

18 transistors

![[D_latch.png]]

7. one D latch beased D Flip-Flop

18 transistors

![[D_FF.png]]

8. Pulse transition detector

![[transition_detector.png]]

9. 2 D-latch based D Flip-Flop

36 transistors

![[DFF2.png]]

10. Frequency Division - 2

![[div_2_dff.png]]

11. Frequency Division - 4 Ripple Counter

![[div_4_ripple.png]]

12. Counter?



### FSM

The Moore state machine is one where the outputs depend only on the internal present state. 

The Mealy state machine is one where the outputs depend on both the internal present state and on the inputs. 

### Logic

$J=\bar{A}\bar{B}C+\bar{A}B\bar{C}+A\bar{B}\bar{C}+ABC=A\XOR B\XOR C$

### Process

45nm process: gate length, or channel length.
https://www.quora.com/What-is-45nm-technology-in-MOSFET


