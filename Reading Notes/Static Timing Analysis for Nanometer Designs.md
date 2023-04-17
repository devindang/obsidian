#reserved 


## Ch.3 Standard Cell Library

A ==cell== could be
- a standard cell
- IO buffer
- complex IP (such as USB core)

A ==library cell description== contains
- timing information
- cell area
- functionality

The attribute of a cell would be 

### 3.1 Pin Capacitance

The pin capacitance describe the capacitance of the cell inputs and specify only for cell inputs, not for outputs, the cell outputs capacitance im most cell libraries is 0. 

```
pin (INP1) {
capacitance: 0.5;
rise_capacitance: 0.5;
rise_capacitance_range: (0.48, 0.52);
fall_capacitance: 0.45;
fall_capacitance_range: (0.435, 0.46);
. . .
}
```

`capacitance: 0.5` specify pin capacitance as a single value;
or, `rise_capacitance: 0.5` specify for rising capacitance and falling capacitance separatly;
or, `rise_capacitance_range: (0.48, 0.52)` specify as a range.

### 3.2 Timing Modeling

The timing models are normally ==obtained== from detailed circuit simulations for modeling the actual scenario of the cell operation.

##### Timing Arc for A Inverter

The two kind of timing arc delay stands for ***output rise delay***, and ***output fall delay*** shown below.

![[timing_arc.png]]

- $T_r$: Output rise delay
- $T_f$: Output fall delay

Both are measured based upon the threshold point defined in cell library, which is typically 50% $V_{dd}$. Thus the timing arc delays are measured from the input crossing threshold point to the output crossng threshold point.

==factors== influence the timing arc thought the inverter cell:
- the output load. (the capacitance at the output pin of the inverter)
- tha transition time of the signal at the input.
The larger the load capacitance $\Rightarrow$ the larger the delay.
The more input transition time $\Rightarrow$ the larger the delay, in most case. (In several scenarios, it shows non-monotonic with respect to input transition time, especially when the cell is lightly loaded)

#### 3.2.1 Linear Timing Model

The linear timing model describe the delay and output transition time as a linear function of input transition time and output load capacitance.
$$D=D_0+D_1\cdot S+D_2\cdot C$$
Where, $D_0,D_1,D_2$ is constant, and $S$ is the input transition time, $C$ is the output load capacitance.

The slew going thought a cell might be change. (improves or degrades)

![[timing_slew.png]]

> The linear delay models are not accurate over the range of input transition time and output capacitance for submicron technologies, and thus most cell libraries presently use the more complex models such as the ==non-linear== delay model.

#### 3.2.2 Non-Linear Timing Model

Most of the cell libraries include ==table models== to specify the delays and timing checks for various timing arcs of the cell. 

Some newer timing libraries for nanometer technologies also provide current source based advanced timing models (such as CCS, ECSM, etc.) 

The table models are referred to as NLDM (Non-Linear Delay Model) and are used for delay, output slew, or other timing checks.

Here is an example for an NLDM:

```
pin (OUT) {
	max_transition : 1.0;
	timing() {
		related_pin : "INP";
		timing_sense : negative_unate;
		rise_transition(delay_template_3x3) {
			index_1 ("0.1, 0.3, 0.7"); /* Input transition */
			index_2 ("0.16, 0.35, 1.43"); /* Output capacitance */
			values ( /* 0.16    0.35    1.43 */ \
			 /* 0.1 */ "0.0417, 0.1337, 0.4680", \
			 /* 0.3 */ "0.0718, 0.1827, 0.5676", \
			 /* 0.7 */ "0.1034, 0.2173, 0.6452");
		}
		fall_transition(delay_template_3x3) {
			index_1 ("0.1, 0.3, 0.7"); /* Input transition */
			index_2 ("0.16, 0.35, 1.43"); /* Output capacitance */
			values ( /* 0.16    0.35    1.43 */ \
			 /* 0.1 */ "0.0817, 0.1937, 0.7280", \
			 /* 0.3 */ "0.1018, 0.2327, 0.7676", \
			 /* 0.7 */ "0.1334, 0.2973, 0.8452");
		}
		. . .
	}
	. . .
}
```

Where, `negative_unate` means the input transition is negative unate for the output transition.

> input rise -> output fall
> input fall -> output rise

As illustrated above, the NLDM of an inverter contains the following tables:
- Rise delay
- Fall delay
- Rise transition
- Fall transition

The NLDM is a lookup table with two variables. Given the ==input transition time== and ==output capacitance== of a cell, we the obtain the timing arc of such a cell.

Where, the ==rise delay== is obtained from the *cell_rise* table with 15ps input transition time (falling) and 10fF load, and the ==fall delay== is obtained from the *cell_fall* table with 20ps input transition time (rising) and 10fF load. (==negative_unate==)

##### Two-dimention Lookup

I the input transition time and output load correspond to a table entry, it's trivial to obtain the Delay and Output transition time. While if not, the two-dimention interpolation is applied.

#### 3.2.3 Threshold Specifications and Slew Derating

The ==slew== values are based upon the measurement thresholds specified in the library. Most of the previous generation libraries (0.25$\mu m$ or older) used 10% and 90% as measurement ==thresholds== for slew or transition time.

> The slew thresholds are chosen to correspond to the ==linear portion== of the waveform.

In the new generation libraries, the portion where the actual waveform is mostly linear is typically between 30% and 70% points, so the ==slew derating== is introduced to extrapolate the equivalent 10% to 90% point. (because the transition times were previously measured between 10% and 90%) In this case, the slew derating is 0.5. ((70-30)/(90-10))

Here is an example:

```
/* Threshold definitions */ 
slew_lower_threshold_pct_fall : 30.0; 
slew_upper_threshold_pct_fall : 70.0; 
slew_lower_threshold_pct_rise : 30.0; 
slew_upper_threshold_pct_rise : 70.0; 
input_threshold_pct_fall : 50.0; 
input_threshold_pct_rise : 50.0; 
output_threshold_pct_fall : 50.0; 
output_threshold_pct_rise : 50.0; 
slew_derate_from_library : 0.5;
```

However, if the `slew_derate_from_library` is undefined, the actual transion times are specified as 30% to 70%.

![[slew_derate.png]]

### 3.3 Timing Models - Combinational Cells

#### Timing Arc for *And* Cell

For a two input *and* cell, both the timing arcs for the cell are *positive_unate*, which denotes that an input pin rise corresponds to an output pin rise, and vice versa.


> [!ERROR]
> reserved

### 3.4 Timing Models - Sequential Cells

A general timing arc of sequential cells can be expressed as below.

![[seq_arc.png]]

Where,
-   D: Data input pin used to input data to be stored in a register or flip-flop.
-   SI: Serial data input pin used to input serial data to be stored in a shift register.
-   SE: Enable input pin used to control whether the output of a register or flip-flop is valid.
-   CK: Clock input pin used to control the timing of data transfer in a register or flip-flop.
-   CDN: Asynchronous clear input pin used to clear the data in a register or flip-flop.
-   Q: Data output pin used to output the data stored in a register or flip-flop.
-   QN: Complementary output pin used to output the signal that is the complement of the Q output.

For synchronous inputs, such as pin D, SI, SE, there are the following timing arcs:
- Setup check arc (rising and falling)
- Hold check arc (rising and falling)

For asynchronous inputs, such as pin CDN (async reset pin), there are the following timing arcs:
- Recovery check arc
- Removal check arc

For synchronous outputs of a flip-flop, such as pins Q or QN, there is the following timing arc:
- CK-to-output propagation delay arc (rising and falling)

![[timing_arc_check.png]]

#### Setup and Hold Checks

#### Negative Values in Setup or Hold Checks

The setup and hold values for timing check can be negative. it's acceptable normally when the path from the pin of flip-flop to the latch point of data is longer than the clock path. In that case, it implies that the data pin of the flip-flop can change ahead of the clock pin and still meet the hold timing check.

The image below illustrate the occasion of negative hold check values.

![[neg_timing_check.png]]

==The setup values of a flip-flop can also be negative==. This means that at the pins of the flip-flop, the data can change after the clock pin and still meet the setup time check.

But the setup check value and hold check value cannot be negative both. 

If the setup (hold) contains a negative value, the hold (setup) must be sufficiently positive so that the ==setup plus hold== is a positive quantity.

> The ==setup plus hold== time is the width of the region where the data signal is required to be steady.

A negative hold time is helpful for a scan data pin. This gives flexibility in terms of clock skew and can eliminate the need for almost all buffer insertion for fixing hold violations in scan mode (see [[DFT#Scan Mode]])

