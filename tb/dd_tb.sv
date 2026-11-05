`timescale 1ns/10ps
`define CYCLE 10.0
`define HCYCLE (`CYCLE/2)
`define MAX_CYCLE 100000

module test_dd();

    //input
    logic clk, rst_n, start_dd;
    logic [3:0] move_queue[0:255];

    //output
    logic done_dd, en_1, en_2, en_3, en_4, en_5, en_6, dir, step;
    logic o_clk;
    integer i;
    Driver_Clock_Gen ddgen(
        .i_clk(clk),
        .i_rst_n(rst_n),
        .o_clk(o_clk)
    );
    Driver_Decoder dd01 (
        .i_clk(o_clk),
        .i_rst_n(rst_n),
        .i_start(start_dd),
        .i_move_queue(move_queue),
    
        .o_en_1(en_1), //whit
        .o_en_2(en_2), //green
        .o_en_3(en_3), //red
        .o_en_4(en_4), //blue
        .o_en_5(en_5), //orange
        .o_en_6(en_6), //yellow
        .o_dir(dir),
        .o_step(step),
        .o_done(dd_done)
    );

    initial begin
        $fsdbDumpfile("dd.fsdb");
        $fsdbDumpvars(0, "+mda");
    end

    // create clock
    initial clk = 1;
    always #(`HCYCLE) clk = ~clk;

    //cube state initialization
    initial begin
        $readmemb("output/output_2.txt", move_queue);
    end

    //reset at the start
    initial begin
                rst_n = 1;
                #(`CYCLE * 1.25);    rst_n = 0;
                #(`CYCLE * 1);      rst_n = 1;
    end

    // start after 3 cycles
    initial begin
        start_dd = 0;
        #(`CYCLE * 2.5);
        start_dd = 1;
        #(`CYCLE * 10);
        start_dd = 0;
    end
    
    initial begin //max time limit
        #(`MAX_CYCLE);
        $finish;
    end



endmodule