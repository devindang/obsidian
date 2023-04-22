#reserved 

### Avoid Latches

#### The Inferring of Latch

In a ==combinational== logic circuit, an *if* statement without *else* branch will cause the inferring of the Latch.

```verilog
process(read_data, fifo_out)
begin
  if read_data = '1' then
    data_out <= fifo_out;
  // else    // latch
  end if;
end process;
```

*case* statement didn't cover all the conditions and without *default* branch in a ==combinational== process.

> Didn't cover all the conditions

```verilog
module decoder3_8(
    input wire in_1,
    input wire in_2,
    input wire in_3,
    
    output reg [7:0] out            
    );
    always@(*)
        case ({in_1, in_2, in_3})
            3'b000 : out = 8'b0000_0001;
            3'b001 : out = 8'b0000_0010;
            3'b010 : out = 8'b0000_0100;
            3'b011 : out = 8'b0000_1000;
            3'b100 : out = 8'b0001_0000;
            3'b101 : out = 8'b0010_0000;
            3'b110 : out = 8'b0100_0000;
            // 3'b111 : out = 8'b1000_0000;           
            // default : out = 8'b0000_0001;    //latch
        endcase
endmodule
```

Assign the value of signal to itself in a ==combinational== process.

```verilog
always@(*)
	if(a_i) 
	   out_o = c_i; 
	else if(b_i) 
	   out_o = 1'b0; 
	else 
	   out_o = out_o;    //latch
```

Another senario to obtain latch is that forgot to use `if clk'event and clk='1'` or `if rising_edge(clk)` : (This case happened on a ==sequential== logic)

```verilog
process(clk)
begin
  if clk = '1' then  // latch
    q <= d;
  end if;
end process;
```

In summary, the Latch won't be inferred in a ==sequential== logic (expect for the special case that forgot to use rising_edge clk). That's because that the Flip-Flop has the feature to latch data.

The inferring of latch is normally considered only in ==combinational== design.

#### Disadvantages of A Latch

-  A Flip-Flop is an edge-sensitive memory element, which a Latch is level-sensitive, which determines that a latch is easily influenced by a glitch.
-  A Latch is not clock triggered, so it is bad for STA.
-  The latch gives the place and route tool less flexibility to meet timing.
-  A latch doesn’t save logic resources in the FPGA because it uses the same primitive as a flip-flop.
-  The latch's output is only guaranteed to be stable during half of the clock cycle, while for logic between two flip-flops, the router can utilize the full clock period.

