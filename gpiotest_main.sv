// gpiotest_main.sv
//
// Based on https://github.com/XarkLabs/upduino-gpiotest
//
// Simple main module of for gpiotest design (above is either FPGA top or
// testbench).
//
// This module has the gpiotest LED control logic, counter and buttons
//
`default_nettype none             // mandatory for Verilog sanity
`timescale 1ns/1ps

module gpiotest_main (
	// all 48 normal GPIO pins output
	output logic J1_0,
	output logic J1_1,
	output logic J1_2,
	output logic J1_3,
	output logic J1_4,
	output logic J1_5,
	output logic J2_0,
	output logic J2_1,
	output logic J2_2,
	output logic J2_3,
	output logic J2_4,
	output logic J2_5,
	output logic J3_0,
	output logic J3_1,
	output logic J3_2,
	output logic J3_3,
	output logic J3_4,
	output logic J3_5,
	output logic J4_0,
	output logic J4_1,
	output logic J4_2,
	output logic J4_3,
	output logic J4_4,
	output logic J4_5,
	output logic J5_0,
	output logic J5_1,
	output logic J5_2,
	output logic J5_3,
	output logic J5_4,
	output logic J5_5,
	output logic J6_0,
	output logic J6_1,
	output logic J6_2,
	output logic J6_3,
	output logic J6_4,
	output logic J6_5,
	output logic J7_0,
	output logic J7_1,
	output logic J7_2,
	output logic J7_3,
	output logic J7_4,
	output logic J7_5,
	output logic J8_0,
	output logic J8_1,
	output logic J8_2,
	output logic J8_3,
	output logic J8_4,
	output logic J8_5,
	// clock input
	input wire logic    clk_i         // clock for module input
);

// counter increment block
localparam      CNT_BITS = 28;              // constant for number of bits in counter in FPGA (human speed)
logic [CNT_BITS-1:0] counter;               // CNT_BITS bit counter with default FPGA reset value

// initialize signals (in simulation, or on FPGA reconfigure)
initial begin
	counter =  '0;
end

always_ff @(posedge clk_i) begin
	counter <= counter + 1'b1;
end

// gpiotest button logic block (sets LEDs based on counter bits XOR'd with
// corresponding button)
logic [5:0]     seq;    // 0 - 0x1f
assign          seq = counter[CNT_BITS-7+:6]; // use top 5 bits for gpio number
// NOTE: notation [r+:w] (r for right-most bit, w for bit width) means bits
// [r+w-1:r] e.g. [0+:8] is the same as [7:0]

always_ff @(posedge clk_i) begin
	J1_0     <= 1'b0;
	J1_1     <= 1'b0;
	J1_2     <= 1'b0;
	J1_3     <= 1'b0;
	J1_4     <= 1'b0;
	J1_5     <= 1'b0;
	J2_0     <= 1'b0;
	J2_1     <= 1'b0;
	J2_2     <= 1'b0;
	J2_3     <= 1'b0;
	J2_4     <= 1'b0;
	J2_5     <= 1'b0;
	J3_0     <= 1'b0;
	J3_1     <= 1'b0;
	J3_2     <= 1'b0;
	J3_3     <= 1'b0;
	J3_4     <= 1'b0;
	J3_5     <= 1'b0;
	J4_0     <= 1'b0;
	J4_1     <= 1'b0;
	J4_2     <= 1'b0;
	J4_3     <= 1'b0;
	J4_4     <= 1'b0;
	J4_5     <= 1'b0;
	J5_0     <= 1'b0;
	J5_1     <= 1'b0;
	J5_2     <= 1'b0;
	J5_3     <= 1'b0;
	J5_4     <= 1'b0;
	J5_5     <= 1'b0;
	J6_0     <= 1'b0;
	J6_1     <= 1'b0;
	J6_2     <= 1'b0;
	J6_3     <= 1'b0;
	J6_4     <= 1'b0;
	J6_5     <= 1'b0;
	J7_0     <= 1'b0;
	J7_1     <= 1'b0;
	J7_2     <= 1'b0;
	J7_3     <= 1'b0;
	J7_4     <= 1'b0;
	J7_5     <= 1'b0;
	J8_0     <= 1'b0;
	J8_1     <= 1'b0;
	J8_2     <= 1'b0;
	J8_3     <= 1'b0;
	J8_4     <= 1'b0;
	J8_5     <= 1'b0;

	case (seq)
		6'h00:  J1_0     <= 1'b1;
		6'h01:  J1_1     <= 1'b1;
		6'h02:  J1_2     <= 1'b1;
		6'h03:  J1_3     <= 1'b1;
		6'h04:  J1_4     <= 1'b1;
		6'h05:  J1_5     <= 1'b1;
		6'h06:  J2_0     <= 1'b1;
		6'h07:  J2_1     <= 1'b1;
		6'h08:  J2_2     <= 1'b1;
		6'h09:  J2_3     <= 1'b1;
		6'h0a:  J2_4     <= 1'b1;
		6'h0b:  J2_5     <= 1'b1;
		6'h0c:  J3_0     <= 1'b1;
		6'h0d:  J3_1     <= 1'b1;
		6'h0e:  J3_2     <= 1'b1;
		6'h0f:  J3_3     <= 1'b1;
		6'h10:  J3_4     <= 1'b1;
		6'h11:  J3_5     <= 1'b1;
		6'h12:  J4_0     <= 1'b1;
		6'h13:  J4_1     <= 1'b1;
		6'h14:  J4_2     <= 1'b1;
		6'h15:  J4_3     <= 1'b1;
		6'h16:  J4_4     <= 1'b1;
		6'h17:  J4_5     <= 1'b1;
		6'h18:  J5_0     <= 1'b1;
		6'h19:  J5_1     <= 1'b1;
		6'h1a:  J5_2     <= 1'b1;
		6'h1b:  J5_3     <= 1'b1;
		6'h1c:  J5_4     <= 1'b1;
		6'h1d:  J5_5     <= 1'b1;
		6'h1e:  J6_0     <= 1'b1;
		6'h1f:  J6_1     <= 1'b1;
		6'h20:  J6_2     <= 1'b1;
		6'h21:  J6_3     <= 1'b1;
		6'h22:  J6_4     <= 1'b1;
		6'h23:  J6_5     <= 1'b1;
		6'h24:  J7_0     <= 1'b1;
		6'h25:  J7_1     <= 1'b1;
		6'h26:  J7_2     <= 1'b1;
		6'h27:  J7_3     <= 1'b1;
		6'h28:  J7_4     <= 1'b1;
		6'h29:  J7_5     <= 1'b1;
		6'h2a:  J8_0     <= 1'b1;
		6'h2b:  J8_1     <= 1'b1;
		6'h2c:  J8_2     <= 1'b1;
		6'h2d:  J8_3     <= 1'b1;
		6'h2e:  J8_4     <= 1'b1;
		6'h2f:  J8_5     <= 1'b1;
		default:    ;
	endcase
end

endmodule
`default_nettype wire               // restore default for other modules
