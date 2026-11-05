`timescale 1ns/10ps
`define CYCLE 5.0
`define HCYCLE (`CYCLE/2)
`define MAX_CYCLE 50000000

module test_alg();

    //input
    logic clk, rst_n, start_alg, done_m, start_sd;
    logic [2:0] state [0:47];
    logic [2:0] init_state [0:47];

    //output
    logic done_alg, done_sd, o_finish;
    logic [2:0] o_face;
    logic [3:0] move_combo [0:31];
    integer i;
    reg [255:0] golden;

    reg [2:0] check[0:5];
    reg wrong;

    integer correct_num;
    integer incorrect_num;

    Algorithm alg(
        .i_clk(clk),
        .i_rst_n(rst_n),
        .i_start(start_alg),
        .i_c_state(state),
        .i_SD_done(done_sd),
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
    // initial begin
        // $readmemb("init_state.txt", init_state);
        // for(int i=0; i<32;i++)begin
        //     $display("%d ", init_state[i]);
        // end
        // create your own init_state.txt
    // end
    // initial begin
        
    // end
    //reset at the start
    // initial begin
        
    // end

    initial begin
                
    end
    reg[255:0] filename;
    // start after 3 cycles
    initial begin
        incorrect_num = 0;
        correct_num = 0;
        for (int j = 1 ;j < 3001; j++)
        begin
            rst_n = 1;
            #(`CYCLE * 1.25);    rst_n = 0;
            #(`CYCLE * 1);      rst_n = 1;
            wrong = 0;
            $sformat(filename, "../input/init_state_%0d.txt", j);
            $readmemb(filename, init_state);
            $write("Given state:");
            
            
            i = 0;
            start_alg = 0;  
            start_sd = 0 ;
            //done_s = 0;
            done_m = 0;
            #(`CYCLE * 2.5);
            start_sd = 1;
                // wait for sd to finish
            #(`CYCLE);
            while(!done_sd) begin
                #(`CYCLE);
            end
            start_sd = 0;
            for(int i=0; i<48;i++) begin
                $write("%d",state[i]);
            end
            $display("");
            while(!o_finish) begin
                // start state detemination
                // $display("running iteration %d", i);
                 start_sd = 1;
                // wait for sd to finish
                #(`CYCLE);
                while(!done_sd) begin
                    #(`CYCLE);
                end
                start_sd = 0;
                // start alogorithm
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
            //$display("escaped");
            start_sd = 1;
                // wait for sd to finish
            #(`CYCLE);
            while(!done_sd) begin
                #(`CYCLE);
            end
            start_sd = 0;
            #(`CYCLE * 10);
            for(i = 0; i < 6; i++) begin
                check[i] = state[i];
            end
            
            for(i = 6; i < 48; i = i + 6)begin
                for(int k = 0; k < 6; k++) begin
                    if(check[k] != state[i + k]) begin
                        //$display("Oh no");
                        wrong = 1;
                    end
                end
            end
            $write("final state:");
            for(int i=0; i<48;i++) begin
                $write("%d ", state[i]);
            end
            if(wrong) begin
                $display("test %d wrong", j);
                incorrect_num = incorrect_num + 1;
            end else begin
                $display("test %d correct", j);
                correct_num = correct_num + 1;
            end
             
        end
        $display("correct num = %d, incorrect_num = %d", correct_num, incorrect_num);
    end
    
    initial begin //max time limit
        #(`MAX_CYCLE);
        $finish;
    end



endmodule