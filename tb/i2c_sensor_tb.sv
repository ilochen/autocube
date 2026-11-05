`timescale 1ns/100ps

module tb;
	localparam CLK = 10;
	localparam HCLK = CLK/2;
	logic clk, start_cal, rst;
	initial clk = 0;
	always #HCLK clk = ~clk;
	logic finish,sclk,oen;
	logic sdat_in;
	logic ack;
	wire sdat;
	logic [7:0] counter;
    logic [2:0] rgb_color;
	logic [47:0] data;
	logic [7:0]  flag_data;
	logic [7:0] read_data;
	logic [2:0] bytes;
	logic reading,writing;
	logic [7:0] flag;
 	logic ack_read,ack_write;
	assign sdat = ((ack_write ) )? 1'b0: (((!reading) || ack_read)? 1'bz : sdat_in);
	logic done;
	integer k;
	
    I2Csensor sensor(
        .i_clk(clk),
        .i_rst_n(rst),
        .i_start(start_cal),
        .o_rgb_color(rgb_color),
        .o_done(done),
        .o_sclk(sclk),
		.o_ack_read(ack_read),
		.o_ack_write(ack_write),
        .i_ack(ack),
        .io_sdat(sdat)
    );

// module I2Csensor (
//     input i_clk,
//     input i_rst_n,
//     input i_start,
//     output [2:0] o_rgb_color,  // The color
//     output o_done,
//     output o_sclk,
//     input i_ack,
//     inout io_sdat
// );

	
	
	initial begin
		data = 48'b100010000010110111110000111100000101101011110110;
		flag = 8'b01101010;
		bytes = 3'd6;
		reading = 0;
		start_cal = 0;
		$fsdbDumpfile("sensor.fsdb");
		$fsdbDumpvars;
		rst = 1;
		#(CLK*2);
		rst = 0;
		#(CLK*2);
		rst = 1;
		clk = 0;
		ack = 1;
		#(CLK);
		for(int i=0;i<37;i++)begin // setup
			@(posedge sclk);
		end
		for ( k = 0; k < 48; k++) begin
			data += 1;
			bytes = 3'd6;
			reading = 0;
			
			start_cal = 0;
			#(CLK*8);
			start_cal = 1;
			#(CLK);
			start_cal = 0;
			for(int i=0; i<19; i++)begin
				@(posedge sclk);
			end
			counter = 7;
			reading = 0;
			for(int i=0; i<9; i++)begin
				@(posedge sclk);
				if(i!=8)begin
					sdat_in = 1'bz;
					read_data[counter] = sdat;
					counter -=1;
				end
				else begin
				end
			end
			counter = 7;
			for(int i=0; i<10;i++)begin
				@(posedge sclk);
				reading = 1;
				if(i!=9 && i!=8)begin
					
					sdat_in = flag[counter];
					counter -=1;
				end
				if( i == 8)begin
					reading = 0;
				end
			end
			reading = 0;
			for(int i=0; i<19;i++)begin
				@(posedge sclk);
			end 
			for(int i=0; i<7;i++)begin
				counter = 7;
				for(int j=0; j<9;j++)begin
					@(posedge sclk);
					if(i!=0 && j <=7)begin
						reading = 1;
						sdat_in = data[bytes*8+counter];
						counter -= 1;
					end
					if( i==0 )begin
						sdat_in = 1'bz;
						read_data[counter] = sdat;
						counter -=1;
					end
					if( i>0)begin
						reading = 1;
					end
					if(j == 8)begin
						reading = 0;
					end
				end
				bytes -=1;
			end
		end
		ack = 0;
		$finish;
	end

	initial begin
		#(5000*CLK)
		$display("Too slow, abort.");
		$finish;
	end

endmodule
