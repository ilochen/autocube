`timescale 1ns/10ps
`define CYCLE 10.0
`define HCYCLE (`CYCLE/2)
`define MAX_CYCLE 10000

module test_alg();

    //input
    logic clk, rst_n, start_alg, done_m, start_sd, done_dd;
    logic [2:0] state [0:47];
    logic [2:0] init_state [0:47];

    //output
    logic done_alg, done_sd, o_finish;
    logic [2:0] o_face;
    logic [3:0] move_combo [0:31];
    integer i;

    Algorithm alg(
        .i_clk(clk),
        .i_rst_n(rst_n),
        .i_start(start_alg),
        .i_c_state(state),
        .i_SD_done(done_sd),
        .i_dd_done(done_dd),
        .i_Motor_done(done_m),
        .o_face(o_face),
        .o_done(done_alg),
        .o_finish(o_finish),
        .o_move_combo(move_combo)
    );

    State_Determination sd(
        .i_clk(clk),
        .i_rst_n(rst_n),
        .i_start(start_sd),
        .i_move_combo(move_combo),
        .i_init_c_state(init_state),
        .i_alg_done(done_alg),
        .o_done(done_sd),
        .o_next_c_state(state)
    );

    initial begin
        $fsdbDumpfile("alg.fsdb");
        $fsdbDumpvars(0, "+mda");
    end

    // create clock
    initial clk = 1;
    always #(`HCYCLE) clk = ~clk;

    //cube state initialization
    initial begin
        $readmemb("./input/init_state_2.txt", init_state);
        // for(int i=0; i<32;i++)begin
        //     $display("%d ", init_state[i]);
        // end
        // create your own init_state.txt
    end

    //reset at the start
    initial begin
                rst_n = 1;
                #(`CYCLE * 1.25);    rst_n = 0;
                #(`CYCLE * 1);      rst_n = 1;
    end

    // start after 3 cycles
    initial begin
        i = 0;
        start_alg = 0;
        start_sd = 0 ;
        done_dd = 0;
        //done_s = 0;
        done_m = 0;
        #(`CYCLE * 77);
        while(!o_finish) begin
            // start state detemination
            start_sd = 1;
            // wait for sd to finish
            #(`CYCLE);
            while(!done_sd) begin
                #(`CYCLE);
            end
            start_sd = 0;
            done_dd = 1;
            #(`CYCLE);
            done_dd = 0;
            //start alogorithm
            start_alg = 1;
            done_m = 1;
            // wait for alg to finish
            while(!done_alg) begin
                #(`CYCLE);
            end
            done_m = 0;
            start_alg = 0;
            i = i+1;
        end
        start_sd = 1;
            // wait for sd to finish
        #(`CYCLE);
        while(!done_sd) begin
            #(`CYCLE);
        end
        start_sd = 0;
    end
    
    initial begin //max time limit
        #(`MAX_CYCLE);
        $finish;
    end



endmodule