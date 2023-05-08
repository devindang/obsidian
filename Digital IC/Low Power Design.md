
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

#### 4. Transistor Level

Layout Optimization

Minimizing Capacitance

Oxide Related

