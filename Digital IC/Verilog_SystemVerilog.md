## Task Function

### Task

Tasks are very handy in testbench simulations because **tasks can include timing delays**.

Tasks should be utilized when the same operation is done over and over throughout Verilog code. Rather than rewriting code, one can just call the task.

static task: Shared between all calls of the task
automatic task:  Allocated upon every individual call of the task



-   Tasks can have any number of inputs and outputs
-   The order of inputs/outputs to a task dictates how it should be wired up when called
-   Tasks can have time delay (posedge, # delay, etc)
-   Tasks can call other tasks and functions
-   Tasks can drive global variables external to the task
-   Variables declared inside a task are local to that task
-   Tasks can use [non-blocking and blocking](https://nandland.com/blocking-vs-nonblocking-in-verilog/ "Blocking vs. Nonblocking assignment in Verilog") assignments
-   Tasks can be _automatic_ (see below for more detail)

### Function

Functions are used for creating combinational logic.

Often a function is created when the same operation is done over and over throughout Verilog code.

-   Functions can have any number of inputs but only one output (one return value)
-   The order of inputs to a function dictates how it should be wired up when called
-   The return type defaults to one bit unless defined otherwise
-   Functions execute immediately (zero time delay)
-   Functions can call other functions but they cannot call tasks
-   Functions can drive global variables external to the function
-   Variables declared inside a function are local to that function
-   [Non-blocking assignment](https://nandland.com/blocking-vs-nonblocking-in-verilog/ "Blocking vs. Nonblocking assignment in Verilog") in function is illegal
-   Functions can be _automatic_ (see below for more detail)

| | Function | Task |
| --- | --- | ---|
| Input | At least one input, cannot be *inout* | None or multiple is acceptable, can be *inout* |
| Output | No output | None of multiple is acceptable |
| Return | At least one | No return |
| Simulation time | Always at 0 time | Can be non-0 time |
| Sequential control | Cannot contain any sequential control | *always* is not allowed, but other sequential control is acceptable such as delay |
| Call | Function can only call function, cannot call task | task can call both function and task |
| Style | Can only be RHS | Can be independent |
| Synthesizable | Yes | Yes |
| Assignment | Non-blocking | Blocking and Non-blocking |


## Fork ... Join

Difference between ==fork ... join==, ==fork ... join_any==, ==fork ... join_none== :

![[fork_join.png]]

```systemverilog
module fork_join_none;
  initial begin
    $display("-----------------------------------------------------------------");
    fork
      //Process-1
      begin
        $display($time,"\tProcess-1 Started");
        #5;
        $display($time,"\tProcess-1 Finished");
      end
      //Process-2
      begin
        $display($time,"\tProcess-2 Startedt");
        #20;
        $display($time,"\tProcess-2 Finished");
      end
    join    // join_any, join_none
    $display($time,"\tOutside Fork-Join_none");
    $display("-----------------------------------------------------------------");
  end
endmodule
```

Output for ==fork ... join==

```systemverilog
# -----------------------------------------------------------------
#                    0	Process-1 Started
#                    0	Process-2 Startedt
#                    5	Process-1 Finished
#                   20	Process-2 Finished
#                   20	Outside Fork-Join_none
# -----------------------------------------------------------------
```

Output for ==fork ... join_any==

```systemverilog
# -----------------------------------------------------------------
#                    0	Process-1 Started
#                    0	Process-2 Startedt
#                    5	Process-1 Finished
#                    5	Outside Fork-Join_none
# -----------------------------------------------------------------
#                   20	Process-2 Finished
```

Output for ==fork ... join_none==

```systemverilog
# -----------------------------------------------------------------
#                    0	Outside Fork-Join_none
# -----------------------------------------------------------------
#                    0	Process-1 Started
#                    0	Process-2 Startedt
#                    5	Process-1 Finished
#                   20	Process-2 Finished
```


## Singed Unsigned

### Singed? Unsigned? For a RHS

#### Case 1: integer <= unsigned + singed

```verilog
`timescale 1ns/1ps

module test();

reg  signed     [3:0]   din1;
reg             [3:0]   din2;
wire integer    [3:0]   dout;

initial begin
    din1    <=  -5;
    din2    <=  2;
end

assign dout = din1+din2;

endmodule
```

The `dout` would be 13.

> As long as there is `unsigned` in the RHS, the operation is treated as unsigned.

#### Case 2: singed <= unsigned + singed

```verilog
wire signed  [3:0]   dout;
```

The `dout` would be -3.

#### Case 3: undefined <= unsigned + singed

```verilog
wire         [3:0]   dout;
```

The `dout` would be -3. It will be treated as singed as if there is at least one `singed` as the RHS.


