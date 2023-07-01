
## FPGA Resource

### Altera

In Altera FPGA,

The minimal unit is ==LE== (Logic Element), which contains a LUT and an FF.

A larger architecture is ==LAB== (Logic Array Block), which varies in different series.

### Xilinx

In Virtex-7,

The minimal unit is ==LC== (Logic Cell), which contains a 6-input LUT and two FFs.

A ==Slice== is comprised of 4 LCs. (For UltraScale+, a Slices contains 8 LUTs and 8 FFs)

A ==CLB== contains 2 Slices.

## FPGA Composer

### LUT

k 输入的LUT，可以实现 $2^{2^k}$ 种逻辑函数。
https://blog.csdn.net/weiaipan1314/article/details/104317186

https://www.logic-fruit.com/blog/fpga/lut-in-fpga/

### Flip Flop

### DSP48

https://www.xilinx.com/htmldocs/xilinx2017_4/sdaccel_doc/uwa1504034294196.html

The following is the basic architecture of a DSP48 block, as seen, a single DSP48 block could perform a $18\times25$ multiply calculation.

$19\times25$ or $18\times26$ would take 2 DSP48 blocks to implementation.

![[dsp48.png]]

