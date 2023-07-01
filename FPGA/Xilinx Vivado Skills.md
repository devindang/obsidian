### 1. What is Out-Of-Context (OOC) mode?

**Out-of-Context Synthesis**

In the out-of-context (OOC) synthesis flow, certain levels of hierarchy are ==synthesized separately== from the top-level. The out-of-context hierarchy are ***synthesized first***. Then, the top-level synthesis is run, and each of the out-of-context runs are treated as a black box. 
Xilinx IP are often run in out-of-context synthesis mode. 

After all of the out-of-context synthesis runs and top-level synthesis runs are complete, the Vivado tools assemble the design from all of the synthesis runs when you open the top-level synthesized design.

This flow offers the following ==advantages==:
-   Reduces compile time for subsequent synthesis runs. Only the runs you specify are resynthesized, leaving the other runs as is.
-   Ensures stability when design changes are made. Only the runs that include changes are resynthesized.

The ==disadvantage== of this flow is that 
- it requires additional setup. 
- You must be careful in selecting which modules to set as out-of-context synthesis modules. 
- Any additional XDC constraints must be defined separately and must only be used for the out-of-context synthesis runs. 

## 2. Forward clock with ODDR

Refs: https://xilinx.eetrend.com/blog/2021/100062950.html

![[oddr.png]]

专用双数据速率输出寄存器

```verilog
   ODDR_main : ODDR
   generic map(
      DDR_CLK_EDGE => "OPPOSITE_EDGE", -- "OPPOSITE_EDGE" or "SAME_EDGE"
      INIT         => '0',             -- Initial value for Q port ('1' or '0')
      SRTYPE       => "SYNC")          -- Reset Type ("ASYNC or "SYNC")
   port map(
      Q  => clk_122m_oddr_m, -- 1-bit DDR output
      C  => clk_122m,        -- 1-bit clock input
      CE => '1',             -- 1-bit clock enable input
      D1 => '1',             -- 1-bit data input (positive edge)
      D2 => '0',             -- 1-bit data input (negative edge)
      R  => '0',             -- 1-bit reset input
      S  => '0'              -- 1-bit set input
   );
```

转发后的时钟质量更好，时序也会更好.

