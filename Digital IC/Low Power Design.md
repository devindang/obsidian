
### Fundamentals of Power Consumption in CMOS

Three contributions to power consumption in CMOS:
1.  Switching Power (Dynamic Power)
2.  Short Circuit Power or Internal Power
3.  Leakage Power

where, switching power is defined by the following equation:
$$E_{dynamic}=S\times C_L \times V_{DD}^2 \times f$$
- $S$ : Average number of transitions across the entire circuit per cycle
- $C_L$ : Circuit parastic capacitance
- $V_{DD}$ : Voltage supplied
- $f$ : Frequency of clock

### Power Saving Abstraction

A higher level abstraction saves much power.

![[power_save_level.png]]

| Level of Abstraction | Power Redcution Opportunities |
| ---- | ---- |
| System Level | 10-100X |
| Architecture Level | 10-90% |
| RTL | 15-50% |
| Logic/Gate Level | 15-20% |
| Transistor Level | 2-10% |

#### 1. System Level Power Reduction

Hardware/Software Partitioning

Power Management

#### 2. Architecture Level

Frequency Scaling

Dynamic Voltage Scaling

Multi Threshold Voltage Cells

Multi VDD

Power Gating

Asynchronous Design

#### 3. Register Transfer Level

Minimizing Transitions

Resource Sharing

Logic Optimization

One-hot code or Gray code in FSM

Avoid free running counter

Clock Gating
Architectural clock gating
Gate level clock gating

流水线设计：流水线设计在降低电源电压的情况下，可以减少功耗。但是如果不降压，功耗是会增加的。

#### 4. Transistor Level

Layout Optimization

Minimizing Capacitance

Oxide Related

### Tejas Hadke


Bibles

![[ICG.png]]

The D-Latch is active-low, which can filter glitch.

1. MUX: The following codes cannot infer an ICG.

```verilog
always @(posedge clk) begin
	if(en)
		q <= d;
	else
		q <= q;
	end
end
```

It will infer a MUX for the input D for keeping the value.

2. ICG: The folling codes could infer an ICG by DC command `compile_ultra -gate_clock` :

```verilog
always @(posedge clk) begin
	if(en)
		q <= d;
	end
end
```

It will infer an ICG if `-gate_clock` compile option is applied.

![[ICG_MUX.png]]

An ICG is usually 10 times the area than a MUX. If the width of any D/Q is 10 bits wider, an ICG is applied, otherwise MUX is inferred. The threshold can be set in systhesis tool.

REFS: https://zhuanlan.zhihu.com/p/20323661
https://www.design-reuse.com/articles/23701/power-analysis-clock-gating-rtl.html

