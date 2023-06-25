
## 1 APB

### 1.1 Overview

Characteristics:

1. not pipelined
2. synchronous
3. every transfer takes at least two cycles


The ==Setup phase== of the write transfer occurs at T1 in Figure 3-1. The select signal, PSEL, is asserted, which means that PADDR, PWRITE and PWDATA must be valid.

The ==Access phase== of the write transfer is shown at T2 in Figure 3-1 where PENABLE is asserted. PREADY is asserted by the Completer at the rising edge of PCLK to indicate that the write data will be accepted at T3. PADDR, PWDATA, and any other control signals, must be stable until the transfer completes.

PREADY can take any value when PENABLE is LOW. This ensures that peripherals that have a fixed ==two cycle access== can tie PREADY HIGH.

