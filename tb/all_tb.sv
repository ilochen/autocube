`timescale 1ns/10ps
`define CYCLE 10000.0
`define HCYCLE_2K (`CYCLE/2)
`define HCYCLE_100K (`CYCLE/20)
`define HCYCLE_12M (`CYCLE/200)
`define MAX_CYCLE 100000000
`define TOP_CYCLE 100.0

module test_all();

    //input
    logic clk_12m, clk_2k, clk_100k, rst_n, start;

    //ls
    logic sclk_1, sclk_2;
    wire sdat_1, sdat_2;
    logic [47:0] data;
    logic [7:0] flag;
    logic [2:0] bytes;
	logic reading,writing;
    logic sdat_in;
    logic [7:0] counter;
    logic [7:0]  flag_data;
	logic [7:0] read_data;
    logic done;
	integer k;

    //output
    logic en_1, en_2, en_3, en_4, en_5, en_6, dir, step;
    logic [4:0] state;
    integer i;
    Top DUT(
    .i_clk_12m(clk_12m),
    .i_clk_2k(clk_2k),
    .i_clk_100k(clk_100k),
    .i_rst_n(rst_n),
    .i_start(start),
    .io_LS_1_sdat(sdat_1),
    .io_LS_2_sdat(sdat_2),
    .o_LS_1_sclk(sclk_1),
    .o_LS_2_sclk(sclk_2),

    .o_ack_read_1(ack_read_1),
    .o_ack_write_1(ack_write_1),
    .o_ack_read_2(ack_read_2),
    .o_ack_write_2(ack_write_2),
    
    .o_top_state(state),
    //motor
    .o_M_1_en(en_1), // maybe we can integrate step and dir as a pin and control merely by en
    .o_M_2_en(en_2),
    .o_M_3_en(en_3),
    .o_M_4_en(en_4),
    .o_M_5_en(en_5),
    .o_M_6_en(en_6),
    .o_M_step(step),
    .o_M_dir(dir)
);

    initial begin
        $fsdbDumpfile("all.fsdb");
        $fsdbDumpvars(0, "+mda");
    end

    // create clock
    initial clk_12m = 1;
    always #(`HCYCLE_12M) clk_12m = ~clk_12m;
    initial clk_2k = 1;
    always #(`HCYCLE_2K) clk_2k = ~clk_2k;
    initial clk_100k = 1;
    always #(`HCYCLE_100K) clk_100k = ~clk_100k;

    assign sdat_1 = ((ack_write_1) )? 1'b0: (((!reading) || ack_read_1)? 1'bz : sdat_in);
    assign sdat_2 = ((ack_write_2) )? 1'b0: (((!reading) || ack_read_2)? 1'bz : sdat_in);

    //reset at the start
    initial begin
        data = 48'b100010000010110111110000111100000101101011110110;
		flag = 8'b01101010;
        bytes = 3'd6;
		reading = 0;
        start = 0;
        rst_n = 1;
        #(`TOP_CYCLE * 1.25);    rst_n = 0;
        #(`TOP_CYCLE * 1);      rst_n = 1;
        for(int i=0;i<37;i++)begin // setup
			@(posedge sclk_1);
		end

        start = 1; //rdd to s_stupid
        #(`TOP_CYCLE * 2.5);
        start = 0;

        for ( k = 0; k < 24; k++) begin
			data += 1;
			bytes = 3'd6;
			reading = 0;

			for(int i=0; i<19; i++)begin
				@(posedge sclk_1);
			end
			counter = 7;
			reading = 0;
			for(int i=0; i<9; i++)begin
				@(posedge sclk_1);
				if(i!=8)begin
					sdat_in = 1'bz;
					read_data[counter] = sdat_1;
					counter -=1;
				end
				else begin
				end
			end
			counter = 7;
			for(int i=0; i<10;i++)begin
				@(posedge sclk_1);
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
				@(posedge sclk_1);
			end 
			for(int i=0; i<7;i++)begin
				counter = 7;
				for(int j=0; j<9;j++)begin
					@(posedge sclk_1);
					if(i!=0 && j <=7)begin
						reading = 1;
						sdat_in = data[bytes*8+counter];
						counter -= 1;
					end
					if( i==0 )begin
						sdat_in = 1'bz;
						read_data[counter] = sdat_1;
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
    end

    // start after 3 cycles
    initial begin
        while (state != 5'b00111) begin
            #(`TOP_CYCLE * 1);
        end
        start = 1;
        #(`TOP_CYCLE * 2.5);
        start = 0;
    end
    
    initial begin //max time limit
        #(`MAX_CYCLE);
        $finish;
    end



endmodule