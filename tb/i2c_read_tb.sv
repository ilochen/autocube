`timescale 1ns/100ps

module tb;
	localparam CLK = 10;
	localparam HCLK = CLK/2;
	logic clk, start, rst;
	initial clk = 0;
	always #HCLK clk = ~clk;
	logic finish,sclk,oen;
    wire sdat;
	logic sdat_in;
    logic [2:0]bytes;
	logic ack;
	logic [7:0] counter;
    logic [47:0] rgb_color;
    logic [2:0] bytes_number;
    logic [47:0] data;
    logic [7:0] read_data;
    logic reading = 0;
	assign sdat = (ack)? 1'b0: ((!reading)? 1'bz : sdat_in);
    


	I2C_READ_DATA i2c(
		// input i_clk,
        // input i_start,
        // input i_rst_n,
        // input [6:0] device_addr,
        // input [7:0] register_addr,
        // input [2:0] bytes_number, 
        // output logic [47:0] rgb_color,
        // output o_sclk,
        // output o_done,
        // inout io_sdat,
        // output logic ack_now
		.i_clk(clk),
        .i_start(start),
        .i_rst_n(rst),
        .bytes_number(bytes_number),
        .device_addr(7'b1000100),
        .register_addr(8'b10011010), 
        .rgb_color(rgb_color),
        .o_sclk(sclk),
        .o_done(finish),
        .io_sdat(sdat),
        .ack_now(ack)
	);


	
	initial begin
		counter = 7;
        bytes = 3'd6;
        bytes_number = 3'd5;
        data = 48'b100010000010110111110000111100000101101011110110;
		$fsdbDumpfile("i2c.fsdb");
		$fsdbDumpvars;
		rst = 1;
        start = 0;
		#(CLK*2);
		rst = 0;
		#(CLK*2);
		rst = 1;
		start = 1;
        #(CLK);
        start = 0;
        reading = 0;
        sdat_in = 1'bz;
        for(int i=0; i<19;i++)begin
            @(posedge sclk);
        end 
        for(int i=0; i<8;i++)begin
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
            end
            bytes -=1;
        end
        reading = 0;

	end

	initial begin
		#(500*CLK)
		$display("Too slow, abort.");
		$finish;
	end

endmodule
