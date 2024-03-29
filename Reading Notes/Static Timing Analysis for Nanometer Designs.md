#reserved 

![[primetime.png]]

![[digital_design_flow.png]]

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

```verilog
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

```verilog
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

```verilog
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

```verilog
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

```verilog
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

```verilog
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

```verilog
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

```verilog
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

```verilog
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

```verilog
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

```verilog
pin (IN) {
	. . .
	receiver_capacitance1_rise ("Lookup_table_4") {
	index_1: ("0.1, 0.2, 0.3, 0.4"); /* Input transition */
	values("0.001040, 0.001072, 0.001074, 0.001085");
}
```

Timing Arc level:

```verilog
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

```verilog
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

```verilog
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

```verilog
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

> A cell with high $V_t$ is normally means a small subthreshold current which will reduce the leakage.

> The ==strength of cells== is another trade-off between leakage and speed. It will be discussed further.

The subthreshold MOS leakage has a strong non-linear dependence with respect to temperature. ==A higher temperature normally causes a higher leakage==.

The contribution due to gate oxide tunneling is relatively invariant with respect to temperature or the $V_t$ of the devices.

| Lekage type | Process in 100nm and above | Process in 65nm or finer | High temperature |
| --- | --- | --- | --- |
| Subthreshold | dominant | equal | dominant |
| Gate oxide tunneling | negligible | equal | x |

An example in the cell library:

```verilog
cell_leakage_power : 1.366;
```

The leakage power is in nanowatts. It can also be specified using `when` condition for state-dependent values.

```verilog
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

```verilog
area: 2.35;
```
The above specifies that the area of the cell is 2.35 area units. It reflect the true area of the silicon of a relative measure.

#### Function Specification

The ==function specification== specify the functionality of a pin or pin group.

```verilog
pin (Z) {
	function: "IN1 & IN2";
	. . .
}
```
The above specifies that the functionality of the *Z* pin of a two-input *and* cell.

#### SDF Condition

The ==SDF condition== attributes supports the ==Standard Delay Format==, the annotation of SDF is denoted by *sdf_cond*.

```verilog
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

#### 4.2 Wireload Model

Prior to floorplanning or layout, ==wireload models== can be used to ==estimate resistance capacitance and area overhead== due to interconnect. 

The wireload model is used to estimate ==the length of a net== based upon the number of its fanouts.

The wireload model is based upon the area of the block, and thus designs with different areas may choose different wireload models.

The wireload model maps the estimated length of the net into resistance, capacitance and area overhead due to routing.

![[wireload_model_area.png]]

There is an example for the specification of wireload model.

```verilog
wire_load (“wlm_conservative”) {
	resistance : 5.0;
	capacitance : 1.1;
	area : 0.05;
	slope : 0.5;
	fanout_length (1, 2.6);
	fanout_length (2, 2.9);
	fanout_length (3, 3.2);
	fanout_length (4, 3.6);
	fanout_length (5, 4.1);
}
```

Where, `resistance`, `capacitance`, and `area` are all specified within the unit length of interconnect. 

`slope` is the extrapolation slope to be used for data points that are not specified in the fanout length table.

![[wireload_fanout.png]]

The wireload model illustrates how the ==length of wire== can be described as a functon of ==fanout==.

For any fanout value not explicitly listed in the table, the interconnect length can be deduced with linear extrapolation with the specified `slope`.

Where, the number of 8 for fanout is not specified.

```verilog
Length = 4.1 + (8 - 5) * 0.5 = 5.6 units
Capacitance = Length * cap_coeff(1.1) = 6.16 units
Resistance = Length * res_coeff(5.0) = 28.0 units
Area overhead = Length * area_coeff(0.05) = 0.28 area units
```

##### 4.2.1 Interconnect Tree

Once the resistance and capacitance of the interconnect net are estimated, the next question is to determine the ==interconnect delay== which is depend on the topology assumed for the net. 

For pre-layout estimation, the interconnect RC tree can be represented using one of the following models:

- Best-case tree:
	The desitination (load) pin is physically adjacent to the driver. Thus, none of the ==wire resistance== is in the path to the desitination pin.
- Balanced tree:
	It is assumed that each destination pin is on a separate portion of the interconnect wire.
- Worst-case tree:
	It is assumed that all the destination pins are together at the far end of the wire.

See Page 109.

##### 4.2.2 Specifying Wireload Models

A wireload model is specified using the following command:

```verilog
set_wire_load_model “wlm_cons” -library “lib_stdcell”
# Says to use the wireload model wlm_cons present in the
# cell library lib_stdcell.
```

The wireload mode can be specified with

```verilog
set_wire_load_mode enclosed
```

- top
- enclosed
- segmented

![[wlm_top.png]]

In the ==*top*== wireload model, all nets within the hierarchy inherit the wireload model of the top-level. Which means that all the wireload models specified in lower-level block are ignored, and thus inherit the wireload model from the top-level.

![[wlm_enclosed.png]]

In the ==*enclosed*== wireload model, the wireload model of a block is only used for the net that is fully encompassed by the block. In the case of Figure 4-11, the net *NETQ* goes though B2, B3, and B5, but it is only enclosed by B2, so *wlm_light* is used for NETQ.

![[wlm_segmented.png]]

In the ==*segmented*== wireload model, if a net goes though multiple blocks, each segment of the net gets its wireload model from the block that encompasses the segment. As the figure illustrated, the portion of NETQ that within B3 uses *wl_aggr* wireload model, the portion of NETQ that within B2 uses *wl_light* wireload model.

Typically, a wireload model is selected based upon the chip area of the block, however, these can be modified at the user's discretion.

That's to say, one can select the wireload model *wlm_aggr* for a block area between 0 to 400, *wlm_typ* for block area between 400 to 1000, and *wlm_cons* for area 1000 or higher.

A ==default wireload model== can be optionally specified in the cell library:

```verilog
default_wire_load: "wlm_light";
```

A ==wireload selection group== would selects a wireload model based upon the block area, is defined in a cell library. Here is an example:

```verilog
wire_load_selection (WireAreaSelGrp) {
	wire_load_from_area(0, 50000, "wlm_light");
	wire_load_from_area(50000, 100000, "wlm_cons");
	wire_load_from_area(100000, 200000, "wlm_typ");
	wire_load_from_area(200000, 500000, "wlm_aggr");
}
```

A cell library may contain many such selection groups, thus one should specify which to use in STA by using the `set_wire_load_selection_group` specification.

```
set_wire_load_selection_group WireAreaSelGrp
```

### 4.3 Representation for Extracted Parasitics

Parasitics extracted from a layout can be described with the following three formats:

- Detailed Standard Parasitic Format (DSPF)
- Reduced Standard Parasitic Format (RSPF)
- Standard Parastic Extraction Format (SPEF)

This section is temporarily #reserved for future.

### 4.4 Representing Coupling Capacitance

### 4.5 Hierarchical Methodology

### 4.6 Reducing Parasitics for Critical Nets

#### Reducing Interconnect Resistance

For citical nets, it's important to maintain ==low slew== values (fast transition time), which implies that the interconnect ==resistance should be reduced==.

Two ways of achieving low resistance:

- Wide trace: Having a trace wider will reduce the interconnect resistance without increasing interconnect capacitance signifcantly.
- Routing in upper (thicker) metals: An upper metal layers normally have ==low resistivity== which can be utilized for critical signals.

The low resistance reduces the interconnect delay as well as the transition time at the destination pins.

#### Increasing Wire Spacing

Increasing the wire spacing between traces reduces the amount of coupling (and total) capacitance of the net, which decreases the crosstalk. 

#### Parasitic for Correlated Nets

In many cases, a group of nes have to be matched in terms of timing.

==An example is the data signals within a byte lane of a high speed DDR interface==.

It's important that all signals within a byte lane see identical parasitics, the signals must be routed in the ==same metal layer==.

For example, while metal layer M2 and M3 have the same average and the same statistical variations, they are independent so that the parasitic variation in these two layer do not track each other. 

Thus, if it's important for timing to match for critical signals, the routing must be identical in each metal layer.

## Ch.5 Delay Calculation

### 5.1 Overview

#### 5.1.1 Delay Calculation Basis

A typical design comprises of various combinational and sequential cells. Here is an example to describe delay calculation.


![[delay_calc_example.png]]

The library description of each cell specifies the pin capacitance values for each of the input pins. The standard libraries normally do not specify pin capacitances for cell outputs which is regarded as 0.

Every ==net== in the design has a capacitance load which is the sum of the ==pin capacitance loads  of every fanouts== of the net plus ==any contribution from the interconnect==. 

In this case, *NET0* has a net capacitance which is comprised of the input pin capacitance from *UAND1* and *UNOR2* cells. The output *O1* has the pin capacitance of the *UNOR2* cell plus any capacitive loading from the output of the blocks. The Input *I1* and *I2* has the pin capacitance corresponding to the *UAND1* and *UINV0* cells.

Delay calculation (for a given process, temperature, and voltage conditions) performs the following activities:

- Compute the ==delay== through specifi c gates, nets, net segments, paths, etc.
- Compute the ==slew== at the output of specifi c gates.
- Compute the ==slew degradation== as the signal passes through a wire (which in turn becomes the slew at the input pin of the next gate).

#### 5.1.2 Delay Calculation with Interconnect

##### Pre-layout Timing

The interconnect parasitics are estimated using the wireload models during the pre-layout timing verification. The interconnect resistance is normally set to 0 in the wireload models.

In this case, the delay is obtainded for all the timing arcs in the design from the library description with wireload model.

##### Post-layout Timing

The parasitics of the metal traces are extracted so that it can be mapped into an RC network between driver and destination cells.

In this case, the internal net such as *NET0* maps into multiple subnodes.

![[post_layout_timing.png]]

### 5.2 Cell Delay using Effective Capacitance

The NLDM models can not directly utilized when the load at the output of the cell includes the ==interconnect resistance==. Instead, an "effective" capacitance approach is employed, which attempts to find a single capacitance that can be used as ==equivalent load== so that the ==original design as well the design with effictive capacitance behave similarly in terms of timing==.

The cell with RC interconnect as its fanout could be represented by equivalent PI-network model. The concept of effective capacitance is to obtain an equivalent output capacitance $Ceff$ which has the same delay throught the cell as the original RC load.

> Normally, the cell output waveform with ==RC load== is very different from the waveform with ==only capacitive loads==.

![[eff_capacitance.png]]

In relation to PI-equivalent representation, the effective capacitance can be expressed as:

```verilog
Ceff = C1 + k*C2, 0 <= k <= 1
```

Where, *C1* is the near-end capacitance, and *C2* is the far-end capacitance. 

If the interconnect resistance of the PI-model is negligible, the effective capacitance is nearly equal to the total capacitance. However, if the interconnect resistance is relatively large, the effective capacitance is almost equal to the near-end capacitance *C1*.

The effective capacitance is a function of
- the driving cell
- the characteristics of the load, specifically the ==input impedance of the load== as seen from the driving cell 

For a given interconnect, a cell with a ==weak output drive== will see a ==larger effective capacitance== than a cell with a strong drive.

Thus, the effective capacitance will be between the ==minimal== value of C1 for ==high interconnect resistance== or ==strong driving cell== and the ==maximum== value which is equal to the total capacitance when the interconnect resistance can be negligible.

The destination pin ==transitions later== than the output of the driving cell.

The phenomenon of near-end capacitance charging faster than the far-end capacitance is also referred to as the ==resistive shielding effect== of the interconnect, since only a portion of the far-end capacitance is seen by the driving cell

![[load_transition.png]]

The delay calculation tool obtains the effective capacitance by an iterative procedure.

1. Obtain the driving point impedance seen by the cell output for the actual RC load.
2. Computing the equivalent effective capacitance.

The method to obtain the equivalent effective capacitance is ==equating== the charge transferred until the midpoint of the transition in the two senarios -- Actual RC load, and effective capacitance as load.

The value of effective capacitance converges within a small number of iterations in most pratical senarios.

With this method, the output slew obtained does not match the actual waveform, especially for the trailing half of the waveform.

In a typically senario, the waveform of interest is ==not== at the ==output of the cell== but the ==destination point of the interconnect== which are the ==input pins of the fanout cells==.

Ones the effective capacitance is obtained, there are various approaches to compute the delay and the waveform at the destination points. The ==effective capacitance procedure== also computes an ==equivalent Thevenin voltage source== for the driving cell.

The Thevenin source comprises of a ==ramp source== with a series resistance $R_d$ . The series resistance $R_d$ corresponds to the pull-down (or pull-up) resistance of the output stage of the cell.

![[thevenin.png]]

### 5.3 Interconnect Delay

The basis delay calculation treats all capacitances as capacitances to ground.

For a ==post-layout== design, the interconnect delay of a pin is computed by the equivalent Thevenin voltage source at the input of the interconnect.

While for a ==pre-layout== analysis, the RC interconnect structure is determined by the tree type, which in trun determines the net delay. The selected tree type is normally specified in the library.

#### Elmore Delay Model

Elmore delays are applicable only for RC trees, which satisfy:
-  Has a single input (source) node
-  Does not have any resistive loops
-  All capacitances are between a node and ground

![[elmore.png]]

The Elmore delay equation can be represented as

```verilog
T_{d1}=C_1*R_1;
T_{d2}=C_1*R_1+C_2*(R_1+R_2);
...
T_{dn}=\sum (i=1,N) C_i (\sum (j=1,i)R_j); # Elmore delay equition
```

The equivalent RC network can be simplified as a PI-model or T-model, either representation provides the net delay as :

$$R_{wire}*(C_{wire}/2+C_{load})$$
This is because the $C_{load}$ sees the entire wire resistance in its charging path, whereas $C_t$ sees $R_t/2$ in its charging path at the T-representation.

![[t-model_elmore.png]]

And $C_t/2$ sees $R_t$ in its charging path at the PI-representation.

![[pi-model_elmore.png]]

For a more complex interconnect tree such as the worst-case tree, balanced tree, best-case tree, the situation is similar.

#reserved 

### 5.4 Slew Merging



## Ch.7 Configuring the STA Environment

### 7.2 Specifying Clocks

```tcl
create_clock \
	-name SYSCLK \
	-period 20 \
	-waveform {0 5} \
	[get_ports SCLK]
```

```tcl
create_clock -period 125 \
	-waveform {100 150} [get_ports ARMCLK]
# Since the first edge has to be rising edge,
# the edge at 100ns is specified first and then the
# falling edge at 150ns is specified. The falling edge
# at 25ns is automatically inferred.
```

![[create_clock.png]]

#### 7.2.1 Clock Uncertainty

```tcl
set_clock_uncertainty -setup 0.2 [get_clocks CLK_CONFIG]
set_clock_uncertainty -hold 0.05 [get_clocks CLK_CONFIG]
```

The uncertainty can be ==clock jitter== or other pessimism.

![[uncertainty.png]]

The uncertainty can also be used on paths crossing clock boundaries, called ==inter clock uncertainty==.

```tcl
set_clock_uncertainty -from VIRTUAL_SYS_CLK -to SYS_CLK \
-hold 0.05
set_clock_uncertainty -from VIRTUAL_SYS_CLK -to SYS_CLK \
-setup 0.3
set_clock_uncertainty -from SYS_CLK -to CFG_CLK -hold 0.05
set_clock_uncertainty -from SYS_CLK -to CFG_CLK -setup 0.1
```

#### 7.2.3 Clock Latency

![[clock_latency.png]]

Two kind of clock latency: ==source latency== and ==network latency==.

-  source latency: from clock source to clock definition point.
-  network latency: from clock definition point to the clock pin of a flip-flop.

```tcl
# Specify a network latency (no -source option) of 0.8ns for
# rise, fall, max and min:
set_clock_latency 0.8 [get_clocks CLK_CONFIG]
# Specify a source latency:
set_clock_latency 1.9 -source [get_clocks SYS_CLK]
# Specify a min source latency:
```

```tcl
set_clock_latency 0.851 -source -min [get_clocks CFG_CLK]
# Specify a max source latency:
set_clock_latency 1.322 -source -max [get_clocks CFG_CLK]
```

==clock tree synthesis==

### 7.3 Generated Clock

A generated clock is clock derived from the master clock. A master clock is defined using the `create_clock` specification.

```tcl
create_clock -name CLKP 10 [get_pins UPLL0/CLKOUT]
# Create a master clock with name CLKP of period 10ns
# with 50% duty cycle at the CLKOUT pin of the PLL.
create_generated_clock -name CLKPDIV2 -source UPLL0/CLKOUT \
-divide_by 2 [get_pins UFF0/Q]
# -multiply_by
# Creates a generated clock with name CLKPDIV2 at the Q
# pin of flip-flop UFF0. The master clock is at the CLKOUT
# pin of PLL. And the period of the generated clock is double
# that of the clock CLKP, that is, 20ns.
```

A generated clock is used for the new clock that is generated based on a master clock.

It is specified for STA to determine the clock period.

![[generated_clock.png]]

The output of the flip-flop can also be defined as a master clock, but it will create a new clock domain, where the generated clock is considered in phase with its master clock.

Another important aspect is a generated clock is not required to set the ==source delay==, while it is must for a master clock. The generated clock origin is considered as its master clock definition point, instead of the definition point. Thus the source delay is automatically included for generaeted clock.

##### Multiplexer Selecting Clocks

![[MUX_clock.png]]

It is not necessary to define a generated clock for TCLK_MUX_OUT.

-  If CLK_SELECT is set to a constant, the output clock gets the correct clock propagated automatically.
-  If CLK_SELECT is not constrainted, the STA will report paths between TCLK and TCLKDIV5, we need to ==set a false path== or specify an ==exclusive clock== relationship between them. This of course assume that there is no any paths between TCLK and TCLKDIV5 elsewhere in the design.
-  If CLK_SELECT is not static and can change during device operation, ==clock gating checks== are inferred for the input of the multiplexer, it ensure the clock switches at the input of a multiplexer is safe with respect to the multiplexer select signal.

##### Generated Clock using Edge and Edge_Shift Option

#reserved 

#### `invert` option

![[generated_invert.png]]

```tcl
create_clock -period 10 [get_ports CLK]
create_generated_clock -name NCLKDIV2 -divide_by 2 -invert \
-source CLK [get_pins UINVQ/Z]
```

An `invert` option is required when the generated clock is an inversion clock. It is specified for STA.


#### PLL Generated Clocks


### 7.4 Constraining Input Paths

`input_delay` is specified for the input of the Flip-Flop in DUA with respect to the external ==Lauch Clock==.

![[input_constr.png]]

```tcl
set Tclk2q
0.9
set Tc1
0.6
set_input_delay -clock CLKA -max [expr Tclk2q + Tc1] \
[get_ports INP1]
```

![[wc_bc_input_delay.png]]

-  available setup time slow corner: 15-6.7=8.3ns
-  available setup time fast corner: 15-3=12ns

> input_delay max = Tclk2q_{max} + Tc1_{max}
> input_delay min = Tclk2q_{min} + Tc1_{min}

> 一般经验值 input_delay max 设置为采样时钟的70%，min设置为采样时钟的30%。这个范围指定了外部输入可以变化的范围，这个范围越大，允许数据变化的范围越大，对外部的时序要求越宽松，对内部时序分析越紧。

> ***set_input_delay是说该输入信号是在时钟沿后多长时间到达模块的port上的 。***
> ***set_output_delay是说该输出信号在后级模块中需要在时钟沿之前提前多长时间准备好。***

https://blog.csdn.net/zyn1347806/article/details/108649518

> - input_delay 和 output_delay 约束是从 clk 到 ports 的约束
> - clk 对于 input_delay 而言，是发起时钟，对于 output_delay 而言，是采样时钟，都不是DUT内部寄存器的CK端
> - 如果输入数据的驱动是外部时钟，而不是DUT的时钟，可以使用虚拟时钟 [[Static Timing Analysis for Nanometer Designs#7.9 Virtual Clock]]

![[input_delay_fpga.png]]

The input delay values for the both types of analysis are:

```
Input Delay(max) = Tco(max) + Ddata(max) + Dclock_to_ExtDev(max) - Dclock_to_FPGA(min)
Input Delay(min) = Tco(min) + Ddata(min) + Dclock_to_ExtDev(min) - Dclock_to_FPGA(max)
```

The following figure shows a simple example of input delay constraints for both setup (max) and hold (min) analysis, assuming the `sysClk` clock has already been defined on the `CLK` port:

```
set_input_delay -max -clock sysClk 5.4 [get_ports DIN]
set_input_delay -min -clock sysClk 2.1 [get_ports DIN]
```

### 7.5 Constraining Output Paths

`output_delay` is specified for the output of the Flip-Flop in DUA with respect to the external ==Capture Clock==.

![[output_delay_constr.png]]

```tcl
set Tc2
3.9
set Tsetup
1.1
set_output_delay -clock CLKQ -max [expr Tc2 + Tsetup] \
[get_ports OUTB]
```

![[wc_bc_output_delay.png]]

```tcl
create_clock -period 20 -waveform {0 15} [get_ports CLKQ]
set_output_delay -clock CLKQ -min -0.2 [get_ports OUTC]
set_output_delay -clock CLKQ -max 7.4 [get_ports OUTC]
```

![[output_delay_caseC.png]]

```tcl
create_clock -period 100 -waveform {5 55} [get_ports MCLK]
set_input_delay 25 -max -clock MCLK [get_ports DATAIN]
set_input_delay 5 -min -clock MCLK [get_ports DATAIN]
set_output_delay 20 -max -clock MCLK [get_ports DATAOUT]
set_output_delay -5 -min -clock MCLK [get_ports DATAOUT]
```

> output_delay max = Tc2_{max} + T_{setup}
> output_delay min = Tc2_{min} - T_{hold}

> output_delay max 实际上也限定了信号可以改变的范围，同时需要保持稳定的范围也确定了，在采样时钟边沿处，数据应该==保持稳定==。

> ***set_input_delay是说该输入信号是在时钟沿后多长时间到达模块的port上的 。***
> ***set_output_delay是说该输出信号在后级模块中需要在时钟沿之前提前多长时间准备好。***


![[input_output_delay.png]]

XIlinx

![[output_delay_fpga.png]]

The output delay values for the both types of analysis are:

```
Output Delay(max) = Tsetup + Ddata(max) + Dclock_to_FPGA(max) - Dclock_to_ExtDev(min)
Output Delay(min) = Ddata(min) - Thold + Dclock_to_FPGA(min) - Dclock_to_ExtDev(max)
```

The following figure shows a simple example of output delay constraints for both setup (max) and hold (min) analysis, assuming the `sysClk` clock has already been defined on the `CLK` port:

```
set_output_delay -max -clock sysClk 2.4 [get_ports DOUT]
set_output_delay -min -clock sysClk -1.1 [get_ports DOUT]
```

### 7.6 Timing Path Groups

![[timing_path_classify.png]]

Four kinds of timing paths:

-  from an input port to an output port;
-  from an input port to an input of a flip-flop or a memory;
-  from the clock pin of a flip-flop or a memory to an input of flip-flop or a memory;
-  from the clock pin of flip-flop to an output port.

In this case, these paths are:

-  A -> Z
-  A -> UFFA/D
-  UFFA/CK -> UFFB/D
-  UFFB/CK -> Z

Timing paths are sorted into path groups by the clock associated with the ==endpoint== of the path. 

Every design has a default path group that includes all non-clocked (asynchronous) paths.

Thus, in the following case, the clock groups are:

-  CLKA group: A to UFFA/D
-  CLKB group: UFFA/CK to UFFB/D
-  DEFAULT group: A to Z; UFFB/CK to Z

![[path_groups.png]]

### 7.7 Modeling of External Attributes

`create_clock`, `set_input_delay`, `set_output_delay` is enough to constrain all paths in a design, but insufficient for IO pins of the block.

For inputs, the slew of the input is required to be specified:

-  set_drive (not recommended)
-  set_drive_cell
-  set_input_transition

For outputs, the output load capacitance seen by the output port needs to be specified:

-  set_load

#### 7.7.1 Drive Strength

##### Input Driving

![[drive_strengt.png]]

The smaller the drive value, the higher the drive strength. A resistance value of 0 implies an infinite drive strength.

By default, all inputs are assumed to have an infinite drive strength. The default condition implies that the ==transition time== at the input pins is 0.

The unit is defined in the library, usually Kohms.

```tcl
set_drive 100 UCLK
# Specifies a drive resistance of 100 on input UCLK.
# Rise drive is different from fall drive:
set_drive -rise 3 [all_inputs]
set_drive -fall 2 [all_inputs]
```

![[set_driving_cell.png]]

The set_driving_cell specification offers a more convenient and accurate approach in describing the drive capability of a port. The set_driving_cell can be used to specify a cell driving an input port.

```tcl
set_driving_cell -lib_cell INV3 \
-library slow [get_ports INPB]
# The input INPB is driven by an INV3 cell
# from library slow.
set_driving_cell -lib_cell INV2 \
-library tech13g [all_inputs]
# Specifies that the cell INV2 from a library tech13g is
# the driving cell for all inputs.
set_driving_cell -lib_cell BUFFD4 -library tech90gwc \
[get_ports {testmode[3]}]
# The input testmode[3] is driven by a BUFFD4 cell
# from library tech90gwc.
```

##### Input Transition

```tcl
set_input_transition 0.85 [get_ports INPC]
# Specifies an input transition of 850ps on port INPC.
set_input_transition 0.6 [all_inputs]
# Specifies a transition of 600ps on all input ports.
set_input_transition 0.25 [get_ports SD_DIN*]
# Specifies a transition of 250ps on all ports with
# pattern SD_DIN*.
# Min and max values can optionally be specified using
# the -min and -max options.
```

##### Capacitive Load

```tcl
set_load 5 [get_ports OUTX]
# Places a 5pF load on output port OUTX.
set_load 25 [all_outputs]
# Sets 25pF load capacitance on all outputs.
set_load -pin_load 0.007 [get_ports {shift_write[31]}]
# Place 7fF pin load on the specified output port.
# A load on the net connected to the port can be
# specified using the -wire_load option.
# If neither -pin_load nor -wire_load option is used,
# the default is the -pin_load option.
```

The unit is defined in the library, usually picofarads.

##### Design Rule Checks

```tcl
set_max_transition 0.6 IOBANK
# Sets a limit of 600ps on IOBANK.
set_max_capacitance 0.5 [current_design]
# Max capacitance is set to 0.5pf on all nets in
# current design.
```

![[drc_example.png]]

for N1,

``` tcl
max capacitance = 0.03+0.02+0.07+0.05 = 0.17 pF
max_transition = cap*rise_resistance = 0.17*1=0.17 ns
```

for N2,

``` tcl
max capacitance = 0.04+0.03 = 0.07 pF
max_transition = cap*input_drive = 0.07*2=0.14 ns
```

### 7.9 Virtual Clock

in some cases the user needs to constraint ports/pins in a block that has no clocks. In such cases, ports/ pins are assumed to be triggered by or dependent on clocks outside the block. To capture the characteristics of such ==off-block== or ==off-chip== clocks, designers use the concept of virtual clocks.

![[virtual_clock.png]]

The clock driving input port ROW_IN is CLK_SAD, which is not drived to DUA, the constraint of `set_input_delay` must have a reference clock.

```tcl
create_clock -name VIRTUAL_CLK_SAD -period 10 -waveform {2 8}
create_clock -name VIRTUAL_CLK_CFG -period 8 \
-waveform {0 4}
create_clock -period 10 [get_ports CLK_CORE]
```

```tcl
set_input_delay -clock VIRTUAL_CLK_SAD -max 2.7 \
[get_ports ROW_IN]
set_output_delay -clock VIRTUAL_CLK_CFG -max 4.5 \
[get_ports STATE_O]
```

Where the available time for input path in DUA is 10-2-2.7=5.3ns

### 7.10 Refining the Timing Analysis

-  `set_case_analysis`: Specifies constant value on a pin of a cell, or on an input port.
-  `set_disable_timing`: Breaks a timing arc of a cell.
-  `set_false_path`: Specifies paths that are not real which implies that these paths are not checked in STA
-  `set_multicycle_path`: Specifies paths that can take longer than one clock cycle.

##### `set_case_analysis`

It is normally used for DFT design, which is specified to switch between test mode and functional mode.

```tcl
set_case_analysis 0 TEST
set_case_analysis 0 [get_ports {testmode[3]}]
set_case_analysis 0 [get_ports {testmode[2]}]
set_case_analysis 0 [get_ports {testmode[1]}]
set_case_analysis 0 [get_ports {testmode[0]}]
```

It will not analyze the paths that are irrelevant.

```tcl
set_case_analysis 1 func_mode[0]
set_case_analysis 0 func_mode[1]
set_case_analysis 1 func_mode[2]
```

Used for clock selecting:

```tcl
set_case_analysis 1 UCORE/UMUX0/CLK_SEL[0]
set_case_analysis 1 UCORE/UMUX1/CLK_SEL[1]
set_case_analysis 0 UCORE/UMUX2/CLK_SEL[2]
```

##### `set_disable_timing`

![[disable_timing.png]]

```tcl
set_disable_timing -from S -to Z [get_cells UMUX0]
```

The path from S to Z is not a timing path.

It will remove all timing paths throught the pin.

#### 7.11 Point to Point Specification

```tcl
set_max_delay 5.0 -to UFF0/D
# All paths to D-pin of flip-flop should take 5ns max.
set_max_delay 0.6 -from UFF2/Q -to UFF3/D
# All paths between the two flip-flops should take a
# max of 600ps.
set_max_delay 0.45 -from UMUX0/Z -through UAND1/A -to UOR0/Z
# Sets max delay for the specified paths.
set_min_delay 0.15 -from {UAND0/A UXOR1/B} -to {UMUX2/SEL}
```

Between clocks:

```tcl
set_max_delay 1.2 -from [get_clocks SYS_CLK] \
-to [get_clocks CFG_CLK]
# All paths between these two clock domains are restricted
# to a max of 1200ps.
set_min_delay 0.4 -from [get_clocks SYS_CLK] \
-to [get_clocks CFG_CLK]
# The min delay between any path between the two
# clock domains is specified as 400ps.
```

## Ch.8 Timing Verification

==The worst-case slow condition is critical for setup checks.==

==The best-case fast condition is critical for hold checks.==

### 8.1 Setup Timing Check

![[set_up_check.png]]

==Setup Check==:

$$T_{launch}+T_{ck2q}+T_{dq}<T_{capture}+T_{cycle}-T_{setup}$$
The setup check poses a max constraint, so it always uses the longest or the max timing path.

This check is normally verified at the slow corner where the delays are the largest.

### 8.2 Hold Timing Check

![[hold_check.png]]

==Hold Check==:

$$T_{launch}+T_{ck2q}+T_{dp}>T_{capture}+T_{hold}$$

The hold check imposes a lower bound or min constraint for paths, it always uses the shortest or the min timing path.

The hold checks are typically performed at the fast timing corner.

A hold timing check ensures that

-  Data from the subsequent launch edge must not be captured by the setup receiving edge.
-  Data from the setup launch edge must not be captured by the preceding receiving edge.

![[hold_rule.png]]

These two checks are essentially the same when the launch clock and the capture clock belong to the same clock domain, while it is different for different clocks.


### 8.3 Multicycle Path

The following for setup checks:

```tcl
create_clock -name CLKM -period 10 [get_ports CLKM]
set_multicycle_path 3 -setup \
-from [get_pins UFF0/Q] \
-to [get_pins UFF1/D]
```

![[multicycle_setup.png]]

The following for hold checks:

```tcl
set_multicycle_path 2 -hold -from [get_pins UFF0/Q] \
-to [get_pins UFF1/D]
```

![[multicycle_hold.png]]

The default hold check is done on the active edge prior to the setup capture edge which is not the intent.

> In most designs, a multicycle setup specified as N (cycles) should be accompanied by a multicycle hold constraint specified as N-1 (cycles).

The following is specified for clocks.

![[multicycle_async.png]]

```tcl
set_multicycle_path 4 -setup \
-from [get_clocks CLKM] -to [get_clocks CLKP] -end
set_multicycle_path 3 -hold \
-from [get_clocks CLKM] -to [get_clocks CLKP] -end
```

![[multicycle_2.png]]

```tcl
set_multicycle_path 2 -setup \
-from [get_clocks CLKP] -to [get_clocks CLKM] -start
set_multicycle_path 1 -hold \
-from [get_clocks CLKP] -to [get_clocks CLKM] -start
# The -start option refers to the launch clock and is
# the default for a multicycle hold.
```

`start` is default for a multicycle hold, where `end` is default for a multicycle setup.

### 8.4 False Paths

Too many false paths which are wildcarded using the through specification can slow down the analysis.

```tcl
set_false_path -from [get_clocks SCAN_CLK] \
-to [get_clocks CORE_CLK]
# Any path starting from the SCAN_CLK domain to the
# CORE_CLK domain is a false path.
set_false_path -through [get_pins UMUX0/S]
# Any path going through this pin is false.
set_false_path \
-through [get_pins SAD_CORE/RSTN]]
# The false path specifications can also be specified to,
# through, or from a module pin instance.
set_false_path -to [get_ports TEST_REG*]
# All paths that end in port named TEST_REG* are false paths.
set_false_path -through UINV/Z -through UAND0/Z
# Any path that goes through both of these pins
# in this order is false.
```

Recommendations:

-  minimize the usage of -through options
-  not to use a false path when a multicycle path is the real intent

## Ch.9 Interface Analysis

### 9.1 


##### PVT Corners

There is an example for 5-corner model.

![[pvt_corner.png]]

*TT* : Typical NMOS Typical PMOS
*FF* : Fast NMOS Fast PMOS
*SS* : Slow NMOS Slow PMOS
*FS* : Fast NMOS Slow PMOS
*SF* : Slow NMOS Fast PMOS

