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

module testbench;
`ifdef TYPE_32
	localparam integer N = 32;
	`define TYPE_C_MODULE SAG4Fun32C
	`define TYPE_S_MODULE SAG4Fun32S
	localparam [N-1:0] test_din = 32'b 10110011001110001001111000111001;
	localparam [N-1:0] test_msk = 32'b 01101001000010101110101001110101;
	localparam [N-1:0] test_sag = 32'b 01001100110010110101101001101101;
	localparam [N-1:0] test_isg = 32'b 01000011110011111000001111100011;
`else
	localparam integer N = 64;
	`define TYPE_C_MODULE SAG4Fun64C
	`define TYPE_S_MODULE SAG4Fun64S
	`define TYPE_F_MODULE SAG4Fun64F
	localparam [N-1:0] test_din = 64'b 0011010110101111001111001111100010100000111001011110010110000010;
	localparam [N-1:0] test_msk = 64'b 0110010000101100000000001011111000110100100010101001011010010000;
	localparam [N-1:0] test_sag = 64'b 0100001011110110000101001111001100110010011111111100100100101010;
	localparam [N-1:0] test_isg = 64'b 0110010010010100011111000111110111010001111110010010100011001100;
`endif

	reg  clock;
	reg  reset;
	reg  error = 0;

	reg  ctrl_inv;
	reg  ctrl_msk;
	reg  ctrl_ldm;

	reg  ctrl_start;
	wire ctrl_ready;

	reg  [N-1:0] in_data;
	reg  [N-1:0] in_mask;
	wire [N-1:0] out_data;

	wire test_sag_ok = out_data === test_sag;
	wire test_isg_ok = out_data === test_isg;

`ifdef TYPE_C
	assign ctrl_ready = 1;
	`TYPE_C_MODULE uut (
		.ctrl_inv (ctrl_inv),
		.ctrl_msk (ctrl_msk),
		.in_data  (in_data ),
		.in_mask  (in_mask ),
		.out_data (out_data)
	);
`else
`ifdef TYPE_S
	`TYPE_S_MODULE uut (
`else
	`TYPE_F_MODULE uut (
`endif
		.clock (clock),
		.reset (reset),

		.ctrl_inv (ctrl_inv),
		.ctrl_msk (ctrl_msk),
		.ctrl_ldm (ctrl_ldm),

		.ctrl_start (ctrl_start),
		.ctrl_ready (ctrl_ready),

		.in_data  (in_data ),
		.out_data (out_data)
	);
`endif

	initial begin
		if ($test$plusargs("vcd")) begin
			$dumpfile("testbench.vcd");
			$dumpvars(0, testbench);
		end

		#5 clock = 0;
		forever #5 clock = ~clock;
	end


	initial begin
		$display("in_data  = %b", test_din);
		$display("in_mask  = %b", test_msk);

`ifdef TYPE_C
		ctrl_inv <= 0;
		ctrl_msk <= 0;
		in_data <= test_din;
		in_mask <= test_msk;
`else
		reset <= 1;
		ctrl_inv <= 0;
		ctrl_msk <= 0;
		ctrl_ldm <= 1;
		ctrl_start <= 0;
		in_data <= test_msk;
		@(posedge clock);

		reset <= 0;
		ctrl_start <= 1;
		@(posedge clock);

		ctrl_start <= 0;
		ctrl_inv <= 'bx;
		ctrl_msk <= 'bx;
		ctrl_ldm <= 'bx;
		in_data <= 'bx;
		@(posedge clock);
`ifdef TYPE_S
		@(posedge clock);
		@(posedge clock);
		@(posedge clock);
`endif
`ifdef TYPE_64
		@(posedge clock);
`endif

		ctrl_inv <= 0;
		ctrl_msk <= 0;
		ctrl_ldm <= 0;
		ctrl_start <= 1;
		in_data <= test_din;
		@(posedge clock);

		ctrl_start <= 0;
		ctrl_inv <= 'bx;
		ctrl_msk <= 'bx;
		ctrl_ldm <= 'bx;
		in_data <= 'bx;
		@(posedge clock);
`ifdef TYPE_S
		@(posedge clock);
		@(posedge clock);
		@(posedge clock);
`endif
`ifdef TYPE_64
		@(posedge clock);
`endif

		ctrl_inv <= 1;
		ctrl_msk <= 0;
		ctrl_ldm <= 0;
		ctrl_start <= 1;
		in_data <= test_din;
`endif

		#1 $display("SAG:");
		$display("expected = %b", test_sag);
		$display("out_data = %b %s", out_data, test_sag_ok ? "OK" : "ERROR");
		error = error || !test_sag_ok;
		@(posedge clock);

`ifdef TYPE_C
		ctrl_inv <= 1;
`else
		ctrl_start <= 0;
		ctrl_inv <= 'bx;
		ctrl_msk <= 'bx;
		ctrl_ldm <= 'bx;
		in_data <= 'bx;
		@(posedge clock);
`ifdef TYPE_S
		@(posedge clock);
		@(posedge clock);
		@(posedge clock);
`endif
`ifdef TYPE_64
		@(posedge clock);
`endif
`endif

		#1 $display("ISG:");
		$display("expected = %b", test_isg);
		$display("out_data = %b %s", out_data, test_isg_ok ? "OK" : "ERROR");
		error = error || !test_isg_ok;
		@(posedge clock);

		#2 if (!error) $finish;
		$display("TESTBENCH FAILED WITH ERROR!");
		$stop;
	end
endmodule
