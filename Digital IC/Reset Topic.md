#reserved
## Synchronous

Implementation in FPGA:

1. Gating Data

![[gating_data.png]]

2. LAB control signal

Altera provides LAB control signals, a LAB contains a synchronous reset control signal, and two asynchronous reset control signals. (The situation in Xilinx is not clear)

RTL Architecture:

![[sync_rst.png]]

==Advantages== of synchronous reset:

- It is generally possible to ensure that the circuit is ==100% synchronous==.
- Ensuring that resets only occur on ==active clock edges== can be used as a means of filtering out ==glitches==.

==Disadvantag== of synchronous reset:

- The effective duration of the reset signal must be ==longer== than the clock period, so that it can be recognized by the system and reset. Besides, factors such as ==clock skew==, combinational logic ==path delay==, and ==reset delay== must also be considered.
- Since the flip-flops in most manufacturers' target libraries only have asynchronous reset ports, if synchronous reset is used, more logic ==resources== will be consumed.
- Affects the data arrival time of the register due to insertion into the ==data path==.

## Asynchronous Reset

Flip-Flop provides an asynchronous reset pin.

![[async_rst_pin.png]]


==Advantages== of asynchronous reset:

- The asynchronous reset signal is easy to identify, and it is very convenient to use the global reset (allocate ==global wiring resources== for the asynchronous reset, and connect to the reset pins of almost all registers).
- Reset is ==immediate, independent of clocks, and does not affect the data path==.
- Because most of the flip-flops in the vendor's target library have an asynchronous reset port, logic ==resources== can be saved.

==Disadvantag== of synchronous reset:

- Reset signals are susceptible to glitches
- When the reset removal time is just within the metastable state window, it is impossible to determine whether the current reset state is 1 or 0, which will lead to a metastable state. (Reset withdrawal time not meeting reset recovery time will lead to ==metastability==.)

## Asynchronous Reset Synchronous Release

Inserting a first-level register on the basis of synchronous reset can solve the metastability problem caused by asynchronous reset. When the asynchronous reset is released (Removal), the first-level register generates a logic '1' for the synchronization of the second-level synchronous register. Therefore, the output of the register always completes the release of the reset on the edge of the clock.

RTL codes:

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

![[async_rst_sync_removal.png]]

==Advantages==:

This method retains the advantages of asynchronous reset, and also ensures that the evacuation moment of reset is synchronous, and there is no case where the Removal check fails, so glitches can also be filtered out.

==Disadvantages==:

## Reset for PLL

For PLL, pay attention to the ==*locked*== signal when using asynchronous reset and synchronous release. When the clock is not locked (synchronous), the PLL cannot output the clock, so the register cannot be used to synchronize the reset signal, and this circuit will never be able to jump out of reset.

The correct way to deal with it is to use the locked signal of the PLL as the synchronization flag of the register, and then release the reset signal after the PLL clock is locked (the output clock of the PLL will be restored before the output of the locked signal, so there will be no possibility that the program cannot be triggered to enter the process in the case).

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
	else if(locked) begin 
		rst_mid <= 1; 
		rst_nout <= rst_mid; 
	end 
end 

endmodule
```

## Recommended Reset Methodology

![[global_rst.png]]

The ==external== asynchronous reset uses a synchronous release method as a ==global== reset signal, and this signal is allocated to each clock domain, and each clock domain uses this signal for asynchronous reset synchronous release.

## Reset Timing Check

Two timing check：Recovery (setup), Removal (hold). (#Reserved)

![[rst_check.png]]
