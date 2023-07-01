
## FPGA Resource

### Altera

In Altera FPGA,

The minimal unit is ==LE== (Logic Element), which contains a LUT and an FF.

A larger architecture is ==LAB== (Logic Array Block), which varies in different series.

### Xilinx

In Virtex-7,

The minimal unit is ==LC== (Logic Cell), which contains a 4-input LUT and two FFs.

A ==Slice== is comprised of 4 LUTs and 8 FFs. (For UltraScale+, a Slices contains 8 LUTs and 8 FFs)

A ==CLB== contains 2 Slices.

> Device capacity is often measured in terms of logic cells, which are the logical equivalent of a classic four-input LUT and a flip-flop.

## FPGA Composer

### LUT

#### LUT architecture

This is a native LUT4, which is composed of 2^4 depth SRAM and 2^4-1 MUX.

![[LUT_arch.png]]

k 输入的LUT，可以实现 $2^{2^k}$ 种逻辑函数。
https://blog.csdn.net/weiaipan1314/article/details/104317186

https://www.logic-fruit.com/blog/fpga/lut-in-fpga/

In Xilinx Series-7, the minimal LUT cell is LUT5.

![[lut_5_6.png]]

两种LUT6

![[lut6_1.png]]

![[lut6_2.png]]



### CARRY4

![[CARRY4.png]]

It's a 4 bits Look-Ahead Carry Adders.

> sum = A xor B xor C
> Cout = AB + (A xor B) C     ,or     Cout = AB + (A+B) C

A xor B is the common part, there is no need for extra logic.

### Flip Flop and Latch

In series-7,
FDCE, FDPE, FDRE, FDSE, 
LDCE, LDPE

F: Flip-Flop, which is sequantial unit.
L: Latch, which is combinational unit.

D: D type.

C: Asynchronous clear
P: Asynchronous preset
R: Synchronous reset
S: Synchronous set

E: Clock enable for Flip-Flop, or Gate enable for latch

### DSP48

https://www.xilinx.com/htmldocs/xilinx2017_4/sdaccel_doc/uwa1504034294196.html

The following is the basic architecture of a DSP48 block, as seen, a single DSP48 block could perform a $18\times25$ multiply calculation.

$19\times25$ or $18\times26$ would take 2 DSP48 blocks to implementation.

![[dsp48.png]]


