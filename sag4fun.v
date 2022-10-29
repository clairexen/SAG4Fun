//
// SAG4Fun
//
// Copyright (C) 2022 Claire Wolf <claire@clairexen.net>
//
// Permission to use, copy, modify, and/or distribute this software for any
// purpose with or without fee is hereby granted, provided that the above
// copyright notice and this permission notice appear in all copies.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
// WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
// ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
// WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
// ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
// OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//

module SAG4Fun32C (
	input ctrl_inv,
	input ctrl_msk,

	input [31:0] in_data,
	input [31:0] in_mask,

	output [31:0] out_data
);
	wire [31:0] r0_din, r0_dout, r1_dout, r2_dout, r3_dout, r4_dout;

	wire [15:0] m0_cin, m1_cin, m2_cin, m3_cin;
	wire [15:0] m0_cout, m1_cout, m2_cout, m3_cout;
	wire [15:0] m0_sout, m1_sout, m2_sout, m3_sout, m4_sout;
	wire [31:0] m0_dout, m1_dout, m2_dout, m3_dout;

	assign r0_din = in_data & (in_mask | {32{ctrl_inv | !ctrl_msk}});
	assign out_data = r4_dout & (in_mask | {32{!ctrl_inv | !ctrl_msk}});

	SAG4FunRow #(32, 4'b1011) r0 (ctrl_inv, ctrl_inv ? m4_sout : m0_sout, 16'bx, r0_din,,,  r0_dout);
	SAG4FunRow #(32, 4'b0011) r1 (ctrl_inv, ctrl_inv ? m3_sout : m1_sout, 16'bx, r0_dout,,, r1_dout);
	SAG4FunRow #(32, 4'b0011) r2 (ctrl_inv, ctrl_inv ? m2_sout : m2_sout, 16'bx, r1_dout,,, r2_dout);
	SAG4FunRow #(32, 4'b0011) r3 (ctrl_inv, ctrl_inv ? m1_sout : m3_sout, 16'bx, r2_dout,,, r3_dout);
	SAG4FunRow #(32, 4'b0001) r4 (ctrl_inv, ctrl_inv ? m0_sout : m4_sout, 16'bx, r3_dout,,, r4_dout);

	assign m0_cin = 16'b 0000_0000_0000_0001 | (m0_cout << 1);
	assign m1_cin = 16'b 0000_0001_0000_0001 | (m1_cout << 1);
	assign m2_cin = 16'b 0001_0001_0001_0001 | (m2_cout << 1);
	assign m3_cin = 16'b 0101_0101_0101_0101 | (m3_cout << 1);

	SAG4FunRow #(32, 4'b0001) m0 (1'b0, m0_sout, m0_cin, in_mask, m0_sout, m0_cout, m0_dout);
	SAG4FunRow #(32, 4'b0001) m1 (1'b0, m1_sout, m1_cin, m0_dout, m1_sout, m1_cout, m1_dout);
	SAG4FunRow #(32, 4'b0001) m2 (1'b0, m2_sout, m2_cin, m1_dout, m2_sout, m2_cout, m2_dout);
	SAG4FunRow #(32, 4'b0001) m3 (1'b0, m3_sout, m3_cin, m2_dout, m3_sout, m3_cout, m3_dout);
	SAG4FunRow #(32, 4'b0000) m4 (1'b0, m4_sout, 16'h FFFF, m3_dout, m4_sout,,);
endmodule

module SAG4Fun64C (
	input ctrl_inv,
	input ctrl_msk,

	input [63:0] in_data,
	input [63:0] in_mask,

	output [63:0] out_data
);
	wire [63:0] r0_din, r0_dout, r1_dout, r2_dout, r3_dout, r4_dout, r5_dout;

	wire [31:0] m0_cin, m1_cin, m2_cin, m3_cin, m4_cin;
	wire [31:0] m0_cout, m1_cout, m2_cout, m3_cout, m4_cout;
	wire [31:0] m0_sout, m1_sout, m2_sout, m3_sout, m4_sout, m5_sout;
	wire [63:0] m0_dout, m1_dout, m2_dout, m3_dout, m4_dout;

	assign r0_din = in_data & (in_mask | {64{ctrl_inv | !ctrl_msk}});
	assign out_data = r5_dout & (in_mask | {64{!ctrl_inv | !ctrl_msk}});

	SAG4FunRow #(64, 4'b1011) r0 (ctrl_inv, ctrl_inv ? m5_sout : m0_sout, 32'bx, r0_din,,,  r0_dout);
	SAG4FunRow #(64, 4'b0011) r1 (ctrl_inv, ctrl_inv ? m4_sout : m1_sout, 32'bx, r0_dout,,, r1_dout);
	SAG4FunRow #(64, 4'b0011) r2 (ctrl_inv, ctrl_inv ? m3_sout : m2_sout, 32'bx, r1_dout,,, r2_dout);
	SAG4FunRow #(64, 4'b0011) r3 (ctrl_inv, ctrl_inv ? m2_sout : m3_sout, 32'bx, r2_dout,,, r3_dout);
	SAG4FunRow #(64, 4'b0011) r4 (ctrl_inv, ctrl_inv ? m1_sout : m4_sout, 32'bx, r3_dout,,, r4_dout);
	SAG4FunRow #(64, 4'b0001) r5 (ctrl_inv, ctrl_inv ? m0_sout : m5_sout, 32'bx, r4_dout,,, r5_dout);

	assign m0_cin = 32'b 0000_0000_0000_0000_0000_0000_0000_0001 | (m0_cout << 1);
	assign m1_cin = 32'b 0000_0000_0000_0001_0000_0000_0000_0001 | (m1_cout << 1);
	assign m2_cin = 32'b 0000_0001_0000_0001_0000_0001_0000_0001 | (m2_cout << 1);
	assign m3_cin = 32'b 0001_0001_0001_0001_0001_0001_0001_0001 | (m3_cout << 1);
	assign m4_cin = 32'b 0101_0101_0101_0101_0101_0101_0101_0101 | (m4_cout << 1);

	SAG4FunRow #(64, 4'b0001) m0 (1'b0, m0_sout, m0_cin, in_mask, m0_sout, m0_cout, m0_dout);
	SAG4FunRow #(64, 4'b0001) m1 (1'b0, m1_sout, m1_cin, m0_dout, m1_sout, m1_cout, m1_dout);
	SAG4FunRow #(64, 4'b0001) m2 (1'b0, m2_sout, m2_cin, m1_dout, m2_sout, m2_cout, m2_dout);
	SAG4FunRow #(64, 4'b0001) m3 (1'b0, m3_sout, m3_cin, m2_dout, m3_sout, m3_cout, m3_dout);
	SAG4FunRow #(64, 4'b0001) m4 (1'b0, m4_sout, m4_cin, m3_dout, m4_sout, m4_cout, m4_dout);
	SAG4FunRow #(64, 4'b0000) m5 (1'b0, m5_sout, 32'h FFFF_FFFF, m4_dout, m5_sout,,);
endmodule

module SAG4Fun32S (
	input clock,
	input reset,

	input  ctrl_inv,
	input  ctrl_msk,
	input  ctrl_ldm,
	input  ctrl_start,
	output ctrl_ready,

	input  [31:0] in_data,
	output [31:0] out_data
);
	reg saved_inv, saved_msk, saved_ldm;

	wire cfg_inv = ctrl_start ? ctrl_inv : saved_inv;
	wire cfg_msk = ctrl_start ? ctrl_msk : saved_msk;
	wire cfg_ldm = ctrl_start ? ctrl_ldm : saved_ldm;

	wire  [15:0] row_sin, row_sout;
	wire  [15:0] row_cin, row_cout;
	wire  [31:0] row_din, row_dout;

	SAG4FunRow #(32) row (cfg_inv, row_sin, row_cin, row_din, row_sout, row_cout, row_dout);

	reg [15:0] swapcfg [0:4];
	reg [31:0] data;
	reg [2:0] state;

	wire [15:0] carry_mask = ctrl_start ||
			state == 0 ? 16'b 0000_0000_0000_0001 :
			state == 1 ? 16'b 0000_0001_0000_0001 :
			state == 2 ? 16'b 0001_0001_0001_0001 :
			state == 3 ? 16'b 0101_0101_0101_0101 :
			16'h FFFF;

	wire [2:0] index = (ctrl_start || state == 5) ? 0 : state;
	wire [2:0] swapcfgidx = cfg_inv ? 4-index : index;

	assign row_sin = cfg_ldm ? row_sout : swapcfg[swapcfgidx];
	assign row_cin = carry_mask | (row_cout << 1);
	assign row_din = index == 0 ? in_data : data;

	always @(posedge clock) begin
		if (state != 0 && state != 5)
			state <= state + 1;
		if (state == 5)
			state <= 0;
		if (ctrl_start) begin
			state <= 1;
			saved_inv <= ctrl_inv;
			saved_msk <= ctrl_msk;
			saved_ldm <= ctrl_ldm;
		end
		if (reset)
			state <= 0;
		if (cfg_ldm)
			swapcfg[ctrl_start ? 0 : state] <= row_sout;
		data <= row_dout;
	end

	assign ctrl_ready = state == 5;
	assign out_data = ctrl_ready ? data : 'bx;
endmodule

module SAG4Fun64S (
	input clock,
	input reset,

	input  ctrl_inv,
	input  ctrl_msk,
	input  ctrl_ldm,
	input  ctrl_start,
	output ctrl_ready,

	input  [63:0] in_data,
	output [63:0] out_data
);
	reg saved_inv, saved_msk, saved_ldm;

	wire cfg_inv = ctrl_start ? ctrl_inv : saved_inv;
	wire cfg_msk = ctrl_start ? ctrl_msk : saved_msk;
	wire cfg_ldm = ctrl_start ? ctrl_ldm : saved_ldm;

	wire  [31:0] row_sin, row_sout;
	wire  [31:0] row_cin, row_cout;
	wire  [63:0] row_din, row_dout;

	SAG4FunRow #(64) row (cfg_inv, row_sin, row_cin, row_din, row_sout, row_cout, row_dout);

	reg [31:0] swapcfg [0:5];
	reg [63:0] data;
	reg [2:0] state;

	wire [31:0] carry_mask = ctrl_start ||
			state == 0 ? 32'b 0000_0000_0000_0000_0000_0000_0000_0001 :
			state == 1 ? 32'b 0000_0000_0000_0001_0000_0000_0000_0001 :
			state == 2 ? 32'b 0000_0001_0000_0001_0000_0001_0000_0001 :
			state == 3 ? 32'b 0001_0001_0001_0001_0001_0001_0001_0001 :
			state == 4 ? 32'b 0101_0101_0101_0101_0101_0101_0101_0101 :
			32'h FFFF_FFFF;

	wire [2:0] index = (ctrl_start || state == 6) ? 0 : state;
	wire [2:0] swapcfgidx = cfg_inv ? 5-index : index;

	assign row_sin = cfg_ldm ? row_sout : swapcfg[swapcfgidx];
	assign row_cin = carry_mask | (row_cout << 1);
	assign row_din = index == 0 ? in_data : data;

	always @(posedge clock) begin
		if (state != 0 && state != 6)
			state <= state + 1;
		if (state == 6)
			state <= 0;
		if (ctrl_start) begin
			state <= 1;
			saved_inv <= ctrl_inv;
			saved_msk <= ctrl_msk;
			saved_ldm <= ctrl_ldm;
		end
		if (reset)
			state <= 0;
		if (cfg_ldm)
			swapcfg[ctrl_start ? 0 : state] <= row_sout;
		data <= row_dout;
	end

	assign ctrl_ready = state == 6;
	assign out_data = ctrl_ready ? data : 'bx;
endmodule

module SAG4Fun64F (
	input clock,
	input reset,

	input  ctrl_inv,
	input  ctrl_msk,
	input  ctrl_ldm,
	input  ctrl_start,
	output ctrl_ready,

	input  [63:0] in_data,
	output [63:0] out_data
);
	reg saved_inv, saved_msk, saved_ldm;

	wire cfg_inv = ctrl_start ? ctrl_inv : saved_inv;
	wire cfg_msk = ctrl_start ? ctrl_msk : saved_msk;
	wire cfg_ldm = ctrl_start ? ctrl_ldm : saved_ldm;

	wire  [31:0] r1_sin, r1_sout, r2_sin, r2_sout;
	wire  [31:0] r1_cin, r1_cout, r2_cin, r2_cout;
	wire  [63:0] r1_din, r1_dout, r2_dout;

	SAG4FunRow #(64) r1 (cfg_inv, r1_sin, r1_cin, r1_din, r1_sout, r1_cout, r1_dout);
	SAG4FunRow #(64) r2 (cfg_inv, r2_sin, r2_cin, r1_dout, r2_sout, r2_cout, r2_dout);

	reg [63:0] swapcfg [0:5];
	reg [63:0] data;
	reg [1:0] state;

	wire [63:0] carry_mask = ctrl_start ||
			state == 0 ?  {32'b 0000_0000_0000_0001_0000_0000_0000_0001, 32'b 0000_0000_0000_0000_0000_0000_0000_0001} :
			state == 1 ?  {32'b 0001_0001_0001_0001_0001_0001_0001_0001, 32'b 0000_0001_0000_0001_0000_0001_0000_0001} :
			{32'h FFFF_FFFF, 32'b 0101_0101_0101_0101_0101_0101_0101_0101};

	wire [2:0] index = (ctrl_start || state == 3) ? 0 : state;
	wire [2:0] swapcfgidx = cfg_inv ? 2-index : index;
	wire [63:0] swapcfg_out = swapcfg[swapcfgidx];

	assign r1_sin = cfg_ldm ? r1_sout : (cfg_inv ? swapcfg_out[63:32] : swapcfg_out[31:0]);
	assign r2_sin = cfg_ldm ? r2_sout : (cfg_inv ? swapcfg_out[31:0] : swapcfg_out[63:32]);
	assign r1_cin = (cfg_inv ? carry_mask[63:32] : carry_mask[31:0]) | (r1_cout << 1);
	assign r2_cin = (cfg_inv ? carry_mask[31:0] : carry_mask[63:32]) | (r2_cout << 1);
	assign r1_din = index == 0 ? in_data : data;

	always @(posedge clock) begin
		if (state != 0 && state != 3)
			state <= state + 1;
		if (state == 3)
			state <= 0;
		if (ctrl_start) begin
			state <= 1;
			saved_inv <= ctrl_inv;
			saved_msk <= ctrl_msk;
			saved_ldm <= ctrl_ldm;
		end
		if (reset)
			state <= 0;
		if (cfg_ldm)
			swapcfg[ctrl_start ? 0 : state] <= {r2_sout, r1_sout};
		data <= r2_dout;
	end

	assign ctrl_ready = state == 3;
	assign out_data = ctrl_ready ? data : 'bx;
endmodule

module SAG4FunRow #(
	parameter integer XLEN = 32,
	parameter [3:0] SHFLPOS = 4'b1001
) (
	input  ctrl_unshuffle,

	input  [XLEN/2-1:0] in_swap,
	input  [XLEN/2-1:0] in_carry,
	input  [  XLEN-1:0] in_data,

	output [XLEN/2-1:0] out_swap,
	output [XLEN/2-1:0] out_carry,
	output [  XLEN-1:0] out_data
);
	wire [  XLEN-1:0] cells_in;
	wire [  XLEN-1:0] cells_out;

	function [XLEN-1:0] split;
		input [XLEN-1:0] in;
		if (XLEN == 32) split = {in[31], in[29], in[27], in[25], in[23],
			in[21], in[19], in[17], in[15], in[13], in[11], in[9], in[7],
			in[5], in[3], in[1], in[30], in[28], in[26], in[24], in[22],
			in[20], in[18], in[16], in[14], in[12], in[10], in[8], in[6],
			in[4], in[2], in[0]};
		else split = {in[63], in[61], in[59], in[57], in[55], in[53],
			in[51], in[49], in[47], in[45], in[43], in[41], in[39], in[37],
			in[35], in[33], in[31], in[29], in[27], in[25], in[23], in[21],
			in[19], in[17], in[15], in[13], in[11], in[9], in[7], in[5],
			in[3], in[1], in[62], in[60], in[58], in[56], in[54], in[52],
			in[50], in[48], in[46], in[44], in[42], in[40], in[38], in[36],
			in[34], in[32], in[30], in[28], in[26], in[24], in[22], in[20],
			in[18], in[16], in[14], in[12], in[10], in[8], in[6], in[4],
			in[2], in[0]};
	endfunction

	function [XLEN-1:0] merge;
		input [XLEN-1:0] in;
		if (XLEN == 32) merge = {in[31], in[15], in[30], in[14], in[29],
			in[13], in[28], in[12], in[27], in[11], in[26], in[10], in[25],
			in[9], in[24], in[8], in[23], in[7], in[22], in[6], in[21],
			in[5], in[20], in[4], in[19], in[3], in[18], in[2], in[17],
			in[1], in[16], in[0]};
		else merge = {in[63], in[31], in[62], in[30], in[61], in[29],
			in[60], in[28], in[59], in[27], in[58], in[26], in[57], in[25],
			in[56], in[24], in[55], in[23], in[54], in[22], in[53], in[21],
			in[52], in[20], in[51], in[19], in[50], in[18], in[49], in[17],
			in[48], in[16], in[47], in[15], in[46], in[14], in[45], in[13],
			in[44], in[12], in[43], in[11], in[42], in[10], in[41], in[9],
			in[40], in[8], in[39], in[7], in[38], in[6], in[37], in[5],
			in[36], in[4], in[35], in[3], in[34], in[2], in[33], in[1],
			in[32], in[0]};
	endfunction

	assign cells_in = ctrl_unshuffle ? (SHFLPOS[3] ? merge(in_data) : in_data) : (SHFLPOS[2] ? split(in_data) : in_data);
	assign out_data = ctrl_unshuffle ? (SHFLPOS[1] ? merge(cells_out) : cells_out) : (SHFLPOS[0] ? split(cells_out) : cells_out);

	SAG4FunCell cells [XLEN/2-1:0] (
		.in_swap   (in_swap  ),
		.in_carry  (in_carry ),
		.in_data   (cells_in ),
		.out_swap  (out_swap ),
		.out_carry (out_carry),
		.out_data  (cells_out)
	);
endmodule

module SAG4FunCell (
	input in_swap,
	input in_carry,
	input [1:0] in_data,

	output out_swap,
	output out_carry,
	output [1:0] out_data
);
	assign out_swap = in_carry ^ in_data[0];
	assign out_carry = out_swap ^ in_data[1];
	assign out_data = {in_data[!in_swap], in_data[in_swap]};
endmodule
