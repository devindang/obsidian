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
