`timescale 1ns/100ps

module tb;
	localparam CLK = 10;
	localparam HCLK = CLK/2;
	logic clk, start_cal, rst;
	initial clk = 0;
	always #HCLK clk = ~clk;
	logic finish,sclk,sdat,oen;
	wire sdat_in;
	logic ack;
	logic [7:0] counter;

	assign sdat_in = (ack)? 1'b0: 1'bz;
	


	I2cInitializer i2c(
		// .i_clk(clk),
		// .i_rst_n(rst),
		// .i_start(start_cal),
		// .o_finished(finish),
		// .o_sclk(sclk),
		// .o_sdat(sdat),
		// .o_oen(oen)
		.i_rst_n(rst),
		.i_clk(clk),
		.bytes_number(2),
		.register_addr(8'b10010011),
		.device_addr(7'b1000100),
		.i_data_in(16'b0011001100111111),
		.i_start(start_cal),
		.o_finished(finish),
		.o_sclk(sclk),
		.io_sdat(sdat_in),
		.ack_now(ack)
	);
// module I2cInitializer (
// 	input i_rst_n,
// 	input i_clk, 
//     input [2:0] bytes_number,
//     input [7:0] register_addr,
//     input [6:0] device_addr,
//     input [15:0] i_data_in,
// 	input i_start,
// 	output o_finished,
// 	output o_sclk,
// 	inout io_sdat,
//     output logic ack_now
// 	 // you are outputing (you are not outputing only when you are "ack"ing.)
// );
	
	
	initial begin
		counter = 1;
		$fsdbDumpfile("i2c.fsdb");
		$fsdbDumpvars;
		rst = 1;
		#(CLK*2);
		rst = 0;
		#(CLK*2);
		rst = 1;
		clk = 0;
		start_cal = 1;
		#(CLK)
		start_cal = 0;
		#(CLK*1000);
		$finish;
	end

	initial begin
		#(500000*CLK)
		$display("Too slow, abort.");
		$finish;
	end

endmodule
