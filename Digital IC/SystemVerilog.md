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

