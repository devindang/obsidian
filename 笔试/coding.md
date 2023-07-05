
sync fifo
async fifo
non-glitch clock switching
fixed-priprity arbiter
round-robin arbiter
odd frequency division
fractional frequency division
overlapped sequence detector
non-overlap sequence detector

手撕一个代码吧，串行输入三个8bit数据，每个有效数据输入都会  有一个valid_in，之后进行比较，由大到小串行输出，每个有效数据输  出都要有valid_out，三个数据输出结束给一个done信号。  一开始我用了三组寄存器保存三个排列好大小的数据，再用了一组寄存器  做数据输出，用两个比较器进行数据比较。面试官让我优化，最后在其  循循善诱之下，我把输出寄存器去掉，利用另三组中某一组寄存器进行输出，  因为是串行输出，在第一个数据输出的同时将下一个数据赋值给“输出”寄存器。  并且利用串行特点优化成只使用一个比较器（只比较data_0与data_in）

