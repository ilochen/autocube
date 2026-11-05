`timescale 1ns/10ps
`define CYCLE 5.0
`define HCYCLE (`CYCLE/2)
`define MAX_CYCLE 1100000

module test_dd();

    //input
    logic clk, rst_n, start_dd, done_ls;

    //output
    logic ack, done_dd, en_1, en_2, en_3, en_4, en_5, en_6, dir, step;
    logic [3:0] move_queue [0:255];
    integer j;

    Driver_Decoder dd(
        .i_clk(clk),//2k
        .i_rst_n(rst_n),
        .i_start(start_dd),
        .i_move_queue(move_queue),
        .i_ls_done(done_ls),
        .o_ack(ack),
        .o_en_1(en_1), //white
        .o_en_2(en_2), //green
        .o_en_3(en_3), //red
        .o_en_4(en_4), //blue
        .o_en_5(en_5), //orange
        .o_en_6(en_6), //yellow
        .o_dir(dir),
        .o_step(step),
        .o_done(done_dd)
    );

    initial begin
        $fsdbDumpfile("rdd.fsdb");
        $fsdbDumpvars(0, "+mda");
    end

    // create clock
    initial clk = 1;
    always #(`HCYCLE) clk = ~clk;

    //reset at the start
    initial begin
        rst_n = 1;
        #(`CYCLE * 1.25);    rst_n = 0;
        #(`CYCLE * 1);      rst_n = 1;
    end

    // start after 3 cycles
    initial begin
        j = 0;
        start_dd = 0 ;
        for (j =0 ;j < 256 ; j++) begin
            move_queue[j] = 4'd0;
        end
        j = 0;
        //done_s = 0;
        //done_m = 0;
         #(`CYCLE * 2.5);
        start_dd = 1;
        while(j < 24) begin
            
            
            #(`CYCLE * 1);
            start_dd = 0;
            while(!done_dd) begin
                #(`CYCLE * 1);
            end
            #(`CYCLE * 1);
            done_ls = 1;
            while(!ack) begin
                #(`CYCLE * 1);
            end
            done_ls = 0;
            j++;
        end
    end
    
    initial begin //max time limit
        #(`MAX_CYCLE);
        $finish;
    end
endmodule