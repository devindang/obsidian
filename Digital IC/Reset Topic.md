Reset Timing Check

两种时序检查：Recovery检查（setup），Removal检查（hold）。（此部分预留）

https://res.craft.do/user/full/3bf92654-d7a3-01d8-4d74-2a11bd838937/doc/1625199c-d66b-41f7-b781-ec0c04a49f97/d8ec5640-be0d-401e-882b-bff1e3ccddd5

同步复位

在FPGA中的实现方式：

（1）门控数据

https://res.craft.do/user/full/3bf92654-d7a3-01d8-4d74-2a11bd838937/doc/1625199c-d66b-41f7-b781-ec0c04a49f97/038dc7fc-4200-487e-b2e9-1b11cc2e7b37

（2）LAB块控制信号

Altera中提供了LAB块控制信号，一个LAB中包含一个同步复位控制信号，以及2个异步复位控制信号。（Xilinx中的情况不清楚）

https://res.craft.do/user/full/3bf92654-d7a3-01d8-4d74-2a11bd838937/doc/1625199c-d66b-41f7-b781-ec0c04a49f97/ed4e5948-7248-4316-bec4-cfada339df15

同步复位优点：

一般能够确保电路是百分之百同步的。

确保复位只发生在有效时钟沿，可以作为过滤掉毛刺的手段

同步复位缺点：

复位信号的有效时长必须大于时钟周期，才能真正被系统识别并完成复位。同时还要考虑如：时钟偏移、组合逻辑路径延时、复位延时等因素。

由于大多数的厂商目标库内的触发器都只有异步复位端口，采用同步复位的话，就会耗费较多的逻辑资源。

由于插入到了数据路径，影响寄存器的数据到达时间。

异步复位

FF提供了异步复位引脚。

https://res.craft.do/user/full/3bf92654-d7a3-01d8-4d74-2a11bd838937/doc/1625199c-d66b-41f7-b781-ec0c04a49f97/74504586-850f-4cea-af56-db5368dfaf04

异步复位优点：

异步复位信号识别方便，而且可以很方便的使用全局复位（给异步复位分配全局布线资源，连接到几乎所有寄存器的复位引脚）。

复位是立即发生的，不依赖于时钟，不会影响数据路径。

由于大多数的厂商目标库内的触发器都有异步复位端口，可以节约逻辑资源。

异步复位缺点：

复位信号容易受到毛刺的影响。

复位结束时刻恰在亚稳态窗口内时，无法决定现在的复位状态是1还是0，会导致亚稳态。（复位撤离时间不满足复位恢复时间会导致亚稳态。）

异步复位同步释放

在同步复位的基础上插入一级寄存器，可以解决异步复位带来的亚稳态问题。在异步复位释放（撤离）（Removal）时，第一级寄存器产生逻辑‘1’，用于第二级同步寄存器的同步。因此寄存器的输出总是在时钟的边沿完成复位的释放。

RTL代码：
```verilog
module Reset_test( 
	input clk, 
	input rst_nin, 
	output reg rst_nout 
); 

reg rst_mid; 

always@(posedge clk or negedge rst_nin) begin 
	if(!rst_nin) begin 
		rst_mid <= 0; 
		rst_nout <= 0; 
	end 
	else begin 
		rst_mid <= 1; 
		rst_nout <= rst_mid; 
	end 
end 

endmodule
```

https://res.craft.do/user/full/3bf92654-d7a3-01d8-4d74-2a11bd838937/doc/1625199c-d66b-41f7-b781-ec0c04a49f97/2dc903b5-91f7-4595-adca-393e8cf95cb9

优点：

这种方法保证了复位的撤离时刻是同步的，不存在Removal检查不通过的情况，因此也可以滤除毛刺。

？？

缺点：

PLL复位

对于PLL，使用异步复位同步释放时要注意locked信号，在时钟未锁定（同步时），PLL是无法输出时钟的，因此也就无法用寄存器进行复位信号的同步，这个电路将永远无法跳出复位。

正确的处理方法是使用PLL的locked信号作为寄存器的同步标志，在PLL时钟锁定后再进行复位信号的释放（PLL的输出时钟会在locked信号输出之前恢复，因此不会出现程序无法触发进入到process中的情况）。

module Reset_test( input clk, input rst_nin, output reg rst_nout ); reg rst_mid; always@(posedge clk or negedge rst_nin) begin if(!rst_nin) begin rst_mid <= 0; rst_nout <= 0; end else if(locked) begin rst_mid <= 1; rst_nout <= rst_mid; end end endmodule

推荐的复位方法

https://res.craft.do/user/full/3bf92654-d7a3-01d8-4d74-2a11bd838937/doc/1625199c-d66b-41f7-b781-ec0c04a49f97/678abd78-9c95-497e-bdaa-89edcc5c5576

外部异步复位使用同步释放的方式当作全局复位信号，同时这个信号分配个各个时钟域，每个时钟域内使用该信号进行异步复位同步释放。