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

The pin capacitance describe the capacitance of the cell inputs and specify only for cell inputs, not for outputs, the cell outputs capacitance in most cell libraries is 0. 

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
-   SE: Enable input pin used to control whether the output of a register or flip-flop is valid. (Maybe ==Scan Enable==?)
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

#### 3.4.1 Setup and Hold Checks

##### Negative Values in Setup or Hold Checks

The setup and hold values for timing check can be negative. it's acceptable normally when the path from the pin of flip-flop to the latch point of data is longer than the clock path. In that case, it implies that the data pin of the flip-flop can change ahead of the clock pin and still meet the hold timing check.

The image below illustrate the occasion of negative hold check values.

![[neg_timing_check.png]]

==The setup values of a flip-flop can also be negative==. This means that at the pins of the flip-flop, the data can change after the clock pin and still meet the setup time check.

But the setup check value and hold check value cannot be negative both. 

If the setup (hold) contains a negative value, the hold (setup) must be sufficiently positive so that the ==setup plus hold== is a positive quantity.

> The ==setup plus hold== time is the width of the region where the data signal is required to be steady.

A negative hold time is helpful for a ==scan data== pin. This gives flexibility in terms of clock skew and can eliminate the need for almost all buffer insertion for fixing hold violations in scan mode. 

Scan mode is the one in which flip-flops are tied serially forming a scan chain - output of flip-flop is typically connected to the scan data input pin of the next flip-flop in series; these connections are for testability (see [[DFT#Scan Mode]])

#### 3.4.2 Asynchronous Checks

Similar to setup and hold check, there are constraint checks for governing the asynchronous pins, which are denoted as Recovery and Removal.

##### Recovery and Removal

##### Pulse Width Checks

##### Example for Recovery, Removal, and Pulse Width Checks

```
pin(CDN) {
	direction : input;
	capacitance : 0.002236;
	. . .
	timing() {
		related_pin : "CDN";
		timing_type : min_pulse_width;
		fall_constraint(width_template_3x1) { /*low pulse check*/
			index_1 ("  0.032, 0.504, 0.788"); /* Input transition */
			values ( /* 0.032  0.504 0.788 */ \
					   "0.034, 0.060, 0.377");
		}
	}
	timing() {
		related_pin : "CK";
		timing_type : recovery_rising;
		rise_constraint(recovery_template_3x3) { /* CDN rising */
			index_1 ("0.032, 0.504, 0.788"); /* Data transition */
			index_2 ("0.032, 0.504, 0.788"); /* Clock transition */
			values( /*     0.032   0.504  0.788 */ \
			 /* 0.032 */ "-0.198, -0.122, 0.187", \
			 /* 0.504 */ "-0.268, -0.157, 0.124", \
			 /* 0.788 */ "-0.490, -0.219, -0.069");
		}
	}
	timing() {
		related_pin : "CK";
		timing_type : removal_rising;
		rise_constraint(removal_template_3x3) { /* CDN rising */
			index_1 ("0.032, 0.504, 0.788"); /* Data transition */
			index_2 ("0.032, 0.504, 0.788"); /* Clock transition */
			values( /*    0.032  0.504  0.788 */ \
			 /* 0.032 */ "0.106, 0.167, 0.548", \
			 /* 0.504 */ "0.221, 0.381, 0.662", \
			 /* 0.788 */ "0.381, 0.456, 0.778");
		}
	}
}
```

In this case,
- `timing_type` is asserted by min_pulse_width, which checks both high pulse and low pulse width. It can also be asserted by min_low_pulse_width or min_high_pulse_width, which only checks low and high pulse width, separately.
- The recovery and removal checks are with respect to the clock pin CK.

#### 3.4.3 Propagation Delay

The ==propagation delay== of a sequential cell is from the ==active edge of the clock== to a ==rising or falling== edge on the output

Here is an example of a propagation delay arc for a ==negative edge-triggered flip-flop==, from clock pin CKN to output Q.

This is a ==non-unate timing arc== as the active edge of the clock can cause either a rising or a falling edge on the output Q. Here is the delay table:

```
timing() {
	related_pin : "CKN";
	timing_type : falling_edge;
	timing_sense : non_unate;
	cell_rise(delay_template_3x3) {
		index_1 ("0.1, 0.3, 0.7"); /* Clock transition */
		index_2 ("0.16, 0.35, 1.43"); /* Output capacitance */
		values ( /* 0.16    0.35    1.43 */ \
		 /* 0.1 */ "0.0513, 0.1537, 0.5280", \
		 /* 0.3 */ "0.1018, 0.2327, 0.6476", \
		 /* 0.7 */ "0.1334, 0.2973, 0.7252");
	}
	...
}
```

A rising edge-triggered flip-flop will specify rising_edge as its `timing_type`.

```
timing() {
	related_pin : "CKP";
	timing_type : rising_edge;
	timing_sense : non_unate;
	cell_rise(delay_template_3x3) {
		. . .
	}
	. . .
}
```

### 3.5 State-Dependent Model

In many combination blocks, the timing arc between input pins and output pins depends on the state of other pins in the block, it can be positive unate, negative unate, or both positive unate and negative unate.

An example is *xor* or *xnor* cell, where the timing arc of an input pint depends on the other one. Such cell models are referred as ==state-dependent model==.

Consider an *xor* cell with two input pin A1 and A2, and the output pin Z. The timing arc of the path from A1 to Z is positive unate when A2 is logic-0, and when the input A2 is logic-1, the path from A1 to Z is negative unate.

These two timing models are specified using ==state-dependent model==, here is an example of the *xor* cell.

The timing model from A1 to Z when A2 is logic-0 is specified as follows:

```
pin (Z) {  
	direction : output; 
	max_capacitance : 0.0842; 
	function : "(A1^A2)"; 
	timing() {
		related_pin : "A1"; 
		when : "!A2";  
		sdf_cond : "A2 == 1'b0";
		timing_sense : positive_unate; 
		cell_rise(delay_template_3x3) {
			index_1 ("0.0272, 0.0576, 0.1184"); /* Input slew */ 
			index_2 ("0.0102, 0.0208, 0.0419"); /* Output load */ 
			values( \
				"0.0581, 0.0898, 0.2791", \ 
				"0.0913, 0.1545, 0.2806", \ 
				"0.0461, 0.0626, 0.2838");
		}
		... 
	}
	...
}
```

Similarly, the timing model from A1 to Z when A2 is logic-1 is specified as follows:

```
timing() {  
	related_pin : "A1";  
	when : "A2";  
	sdf_cond : "A2 == 1'b1"; 
	timing_sense : negative_unate; 
	cell_fall(delay_template_3x3) {
		index_1 ("0.0272, 0.0576, 0.1184"); 
		index_2 ("0.0102, 0.0208, 0.0419"); 
		values( \
			"0.0784, 0.1019, 0.2269", \ 
			"0.0943, 0.1177, 0.2428", \ 
			"0.0997, 0.1796, 0.2620");
	}
	... 
}
```

The state-dependent condition is specified using the ==when condition==.

State-dependent models are also used for various of timing arcs such as Scan Mode testing in DFT. There is an example for scan flip-flop using state-dependent model for hold constraint.

In this case, two sets of timing models are specified - one for scan enable pin SE active, and the other for SE inactive.

```
pin (D) { 
	...
	timing() {  
		related_pin : "CK";  
		timing_type : hold_rising;  
		when : "!SE"; 
		fall_constraint(hold_template_3x3) {
			index_1("0.08573, 0.2057, 0.3926"); 
			index_2("0.08573, 0.2057, 0.3926"); 
			values("-0.05018, -0.02966, -0.00919",\
				   "-0.0703, -0.05008, -0.0091",\ 
				   "-0.1407, -0.1206, -0.1096");
		}
		... 
	}
}
```

> **The state-dependent model applying order**
> If the state-dependent model do not cover the condition of the cell, the timing from non-state-dependent model will be ultilized.

For example, if there is a hold constraint specified by only one `when` condition for SE at logic-0, and no separate state-dependent model is specified for logic-1. In such scenario, the hold constraint from ==non-state-dependent model== is used. However, if there is no non-state-dependent model for hold constraints, there will *not* be any active hold constraints!!!

State-dependent model can also be specified for any other attributes in the timing library. For example,
- Power
- Leakage power
- Transition time
- Rise delays & fall delays
- Timing constraint

```
leakage_power() { 
	when : "A1 !A2"; 
	value : 259.8;
} 
leakage_power() {
	when : "A1 A2";
	value : 282.7; 
}
```

### 3.6 Interface Timing Model for a Black Box

The timing arc for the IO interface of a black box (an arbitrary module or block).

The timing model of a black box can be expressed as follows:

![[io_model.png]]

Where the timing arc contains the following categories:

- ==*Input to output combinational arc*== : This corresponds to a direct combinational path from input to output, where in this case, check FIN to FOUT;
- ==*Input sequential arc*== : This is described as setup or hold time for the input connected to a D-pin of a flip-flop, where in this case, check DIN with respect to ACLK;
- ==*Asynchronous input arc*== : This is similar to recovery and removal timing constraint for a input asynchronos pin of a flip-flop, where in this case, check ARST connected to the asynchronous clear pin of UFF0;
- ==*Output sequential arc*== : This is similar to the output propagation timing for the clock to output connected to Q of a flip-flop, where in this case, check the path from BCLK to the output port DOUT.

In summary, the timing arc of a black box can be the following:

- Input to output timing arcs for combinational logic paths.
- Setup and hold timing arcs from the synchronous inputs to the related clock pins.
- Recovery and removal timing arcs for the asynchronous inputs to the related clock pins.
- ==Output propagation delay== from clock pins to the output pins.

### 3.7 Advanced Models

#### Effective Capacitance

NLDM represent the ==delay== or ==output transition time== arcs based upon the ==input transition time== and ==output load capacitance==, discard the presense of ==interconnect resistance==.

The delay calculation tool retrofit the NLDM models with ==effective capacitance== which has the same delay at the output of the cell as the cell with RC interconnect.

#### 3.7.1 Receiver Pin Capacitance

The receiver pin capacitance corresponds to the ==input pin capacitance== specified for NLDM models.

There is another advanced models named CCS (composite current source), which allow applying different receiver pin capacitance at different portions of the transitioning waveform. Due to ==Miller effect== from the input devices within the cell, the receiver pin capacitance value varies at different points on the transitioning waveform.

The capacitance is thus modeled differently in the initial (leading) portion versus the trailing portion of the waveform.

The receiver pin capacitance can either be specified in ==PIN== level or ==Timing Arc== level.

PIN level:

```
pin (IN) {
	. . .
	receiver_capacitance1_rise ("Lookup_table_4") {
	index_1: ("0.1, 0.2, 0.3, 0.4"); /* Input transition */
	values("0.001040, 0.001072, 0.001074, 0.001085");
}
```

Timing Arc level:

```
pin (OUT) {
	. . .
	timing () {
		related_pin : "IN" ;
		. . .
		receiver_capacitance1_rise ("Lookup_table_4x4") {
			index_1("0.1, 0.2, 0.3, 0.4"); /* Input transition */
			index_2("0.01, 0.2, 0.4, 0.8"); /* Output capacitance */
			values("0.001040 , 0.001072 , 0.001074 , 0.001075", \
				"0.001148 , 0.001150 , 0.001152 , 0.001153", \
				"0.001174 , 0.001172 , 0.001172 , 0.001172", \
				"0.001174 , 0.001171 , 0.001177 , 0.001174");
		}
		. . .
	}
	. . .
}
```

The above example specifies the model for *receiver_capacitance1_rise*, the library include similar definitions for *receiver_capacitance2_rise*, *receiver_capacitance1_fall*, *receiver_capacitance2_fall* specifications.

| Capacitance type | Edge | Transition |
| -- | -- | --|
| Receiver_capacitance1_rise | Rising | Leading portion of transition |
| Receiver_capacitance1_fall | Falling | Leading portion of transition |
| Receiver_capacitance2_rise | Rising | Trailing portion of transition |
| Receiver_capacitance2_fall | Falling | Trailing portion of transition |

#### 3.7.2 Output Current for CCS

In the CCS model, the non-linear timing is represented in terms of ==output current==. The output current is specified for different combination of ==input transition time== and ==output capacitance==.

Essentially, the waveform in CCS model refers to output current values specified as a function of time. 

```
pin (OUT) {
	. . .
	timing () {
		related_pin : "IN" ;
		. . .
		output_current_fall () {
			vector ("LOOKUP_TABLE_1x1x5") {
				reference_time : 5.06; /* Time of input crossing
					threshold */
				index_1("0.040"); /* Input transition */
				index_2("0.900"); /* Output capacitance */
				index_3("5.079e+00, 5.093e+00, 5.152e+00,
						5.170e+00, 5.352e+00");/* Time values */
				/* Output charging current: */
				values("-5.784e-02, -5.980e-02, -5.417e-02,
						-4.257e-02, -2.184e-03");
			}
			. . .
		}
		. . .
	}
	. . .
}
```

-  *reference_time*: attribute refers to the time when the input waveform crosses the delay threshold. 
- *index_1* and *index_2*: can have only one value each.

#### 3.7.3 Models for Crosstalk Noise Analysis #reserved 

CCS models for crosstalk noice (glitch) are described as CCSN (CCS Noise) models.

CCSN models are represented for different ==CCBs== (Channel Connected Blocks).

What is a CCB? 

> - The CCB refers to the ==source-drain== channel connected portion of a cell. For example, single stage cells such as an ==*inverter*==, ==*nand*== and ==*nor*== cells contain only one CCB - the entire cell is connected through using one channel connection region. 
> - Multi-stage cells such as ==*and*== cells, or ==*or*== cells, contain multiple CCBs.

```
pin (OUT) {
	. . .
	timing () {
		related_pin : "IN1";
		. . .
		ccsn_first_stage() { /* First stage CCB */
			is_needed : true;
			stage_type : both; /*CCB contains pull-up and pull-down*/
			is_inverting : true;
			miller_cap_rise : 0.8;
			miller_cap_fall : 0.5;
			dc_current (ccsn_dc) {
				index_1 ("-0.9, 0, 0.5, 1.35, 1.8"); /* Input voltage */
				index_2 ("-0.9, 0, 0.5, 1.35, 1.8"); /* Output voltage*/
				values ( \
					"1.56, 0.42, . . ."); /* Current at output pin */
			}
			. . .
			output_voltage_rise () {
				vector (ccsn_ovrf) {
					index_1 ("0.01"); /* Rail-to-rail input transition */
					index_2 ("0.001"); /* Output net capacitance */
					index_3 ("0.3, 0.5, 0.8"); /* Time */
					values ("0.27, 0.63, 0.81");
				}
				. . .
			}
			output_voltage_fall () {
				vector (ccsn_ovrf) {
					index_1 ("0.01"); /* Rail-to-rail input transition */
					index_2 ("0.001"); /* Output net capacitance */
					index_3 ("0.2, 0.4, 0.6"); /* Time */
					values ("0.81, 0.63, 0.27");
				}
				. . .
			}
			propagated_noise_low () {
				vector (ccsn_pnlh) {
					index_1 ("0.5"); /* Input glitch height */
					index_2 ("0.6"); /* Input glitch width */
					index_3 ("0.05"); /* Output net capacitance */
					index_4 ("0.3, 0.4, 0.5, 0.7"); /* Time */
					values ("0.19, 0.23, 0.19, 0.11");
				}
			propagated_noise_high () {
			. . .
		}
	}
}
```

### 3.8 Power Dissipation Modeling

The cell library contains definition related to power dissipation in the cells. This include both ==active power== as well as ==leakage power==. 

#### 3.8.1 Active Power

The active power in the cell is due to the ==charging of the output load== as well as the ==internal switching==. These two are normally referred to as ==*output switching power*== and ==*internal switching power*==.

The output switching power is ==independent== of the cell type, and depend upon only the ==output capactive load==, ==frequency of switching==, and the ==power supply== of the cell.

The internal switching power is consumpted when there is activity at the input or output of the cell. An input pin transition can cause the output to switch and thus results in internal switching power. For example, An ==*inverter*== cell consumes power whenever the input switches (rise or fall transition).

```
pin (Z1) {
	. . .
	power_down_function : "!VDD + VSS";
	related_power_pin : VDD;
	related_ground_pin : VSS;
	internal_power () {
		related_pin : "A";
		power (template_2x2) {
			index_1 ("0.1, 0.4"); /* Input transition */
			index_2 ("0.05, 0.1"); /* Output capacitance */
			values ( /* 0.05  0.1 */ \
			/* 0.1 */ "0.045, 0.050", \
			/* 0.4 */ "0.055, 0.056");
		}
	}
}
```

This case described the internal power model from the input pin A the output pin Z1 of the cell. The value in the table represents the internal energy dissipated in the cell at each switching (rise or fall).

The units of the index are normally derived from other units in the library. Typically, voltage is in volts (V), capacitance is in picofarads (pF), and this map to energy in picojoules (pJ).

Switching power can be dissipated even when the outputs or the internal state does not have a transition.  A common example is the clock drive the *CLK* pin of a FF toggles.

> It's important that the value in the CLK -> Q specification tables ==DO NOT== contains the contribution due to the CLK internal power comsumption when the output Q does not switch.

The above guideline refers to consistency of usage of power tables by the application tool and ensures that the internal power specified due to clock input is not double-counted during power calculation.

#### 3.8.2 Leakage Power

Leakage Powert: cell is powered but there is no activity.

In the earlier generation of CMOS process technologies, the leakage power has been ==negligible== and has ==not been the major consideration== during the design process.

However, as the technology shrinks, the leakage power is becoming ==significant== and is no longer be negligible in comparision to active power.

The leakage power contribution:
- ==subthreshold== current in the MOS devices;
- ==tunneling current== throught the gate oxide.

By using high $V_t$ cells, one can reduce the subthreshold current thus reduce the leakage power. However, there is a trade-off due to ==reduced speed== of high $V_t$ cells. The high $V_t$ cells have smaller leakage but are slower in speed, and the low $V_t$ cells have larger leakage but greater in speed.

> The high $V_t$ cells refer to cells with higher threshold voltage than the standard one for the process technology.


> The ==strength of cells== is another trade-off between leakage and speed. It will be discussed further.

The subthreshold MOS leakage has a strong non-linear dependence with respect to temperature. ==A higher temperature normally causes a higher leakage==.

The contribution due to gate oxide tunneling is relatively invariant with respect to temperature or the $V_t$ of the devices.

| Lekage type | Process in 100nm and above | Process in 65nm or finer | High temperature |
| --- | --- | --- | --- |
| Subthreshold | dominant | equal | dominant |
| Gate oxide tunneling | negligible | equal | x |

An example in the cell library:

```
cell_leakage_power : 1.366;
```

The leakage power is in nanowatts. It can also be specified using `when` condition for state-dependent values.

```
cell_leakage_power : 0.70;
leakage_power() {
	when : "!I";
	value : 1.17;
}
leakage_power() {
	when : "I";
	value : 0.23;
}
```

Where, *I* is the input pin of an inverter *INV1*, and it should be noted that the specification includes a default value `0.70` outside the `when` conditions, the default value is generally the average of the leakage power specified within the `when` condition.

### 3.9 Other Attributes in Cell Library

#### Area Specification

The ==area specification== provides the area of a cell or cell group.

```
area: 2.35;
```
The above specifies that the area of the cell is 2.35 area units. It reflect the true area of the silicon of a relative measure.

#### Function Specification

The ==function specification== specify the functionality of a pin or pin group.

```
pin (Z) {
	function: "IN1 & IN2";
	. . .
}
```
The above specifies that the functionality of the *Z* pin of a two-input *and* cell.

#### SDF Condition

The ==SDF condition== attributes supports the ==Standard Delay Format==, the annotation of SDF is denoted by *sdf_cond*.

```
timing() {
	related_pin : "A1";
	when : "!A2";
	sdf_cond : "A2 == 1'b0";
	timing_sense : positive_unate;
	cell_rise(delay_template_7x7) {
	. . .
	}
}
```

### The remaining is #reserved  

## Ch.4 Interconnect Parasitic

A ==wire== connecting pins of standard cells and blocks is referred to as a ==net==. 

A net is typically has only one driver while it can drive a number of fanouts cells or blocks.

After physical implementation, the ==net== can travel on multiple metal layers of the chip, which has different resistance and capacitance values. Thus, a net can be divided into several segment, we refer to an ==interconnect trace== as a synonym to a segment, which is a part of the net.

#### 4.1 RLC for Interconnect

==The interconnect resistance== comes from the ==interconnected traces traversed in various metal layers and vias== in the design as shown in the figure.

![[nets_n_metal_layers.png]]

Thus, the interconnect resistance can be considered as the resistance between the input pin of the cell and the output pin of the fanout cells.

==The interconnect capacitance== contribution is also from the ==metal traces== and is comprised of ==grounded capacitance== as well as the ==capacitance between neighboring signal routes==.

==The interconnect inductance== arises due to ==current loops==. 

The resistant and capacitance (*RC*) for a section of interconnect trace can be ideally represented by a distributed RC tree. Consider $R_p$ and $C_p$ as the resistance and capacitance of the trace  per unit, and L as the trace length. The total RC can be represented as follows:
$$R_t=R_p\cdot L$$
$$C_t=C_p\cdot L$$
It can be obtained bty extracted parasitics which is provided by the ==ASIC foundry==. 

![[RC_tree.png]]

The RC interconnect can be represented by various simplified models, such as T-model, Pi-model etc.

##### T-model

![[t_model.png]]

##### Pi-model

![[pi_model.png]]




### 4.6 Reducing Parasitics for Critical Nets

#### Reducing Interconnect Resistance

For citical nets, it's important to maintain ==low slew== values (fast transition time), which implies that the interconnect resistance should be reduced.

Two ways of achieving low resistance:

- 

### Ch.5 Delay Calculation



