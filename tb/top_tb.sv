`timescale 1ns/10ps
`define CYCLE 5.0
`define HCYCLE (`CYCLE/2)
`define MAX_CYCLE 5000000
`define CASE_NUMBER 1

module test_alg();

    typedef enum {
        S_INIT,
        S_SOLVE,
        S_IDLE, // press a key to start solving
        S_ROTATE, // motor work
        S_DONE
    } State;
    // input driver
    logic clk, clk_2k, clk_100k, rst_n, start, start_s;
    logic [2:0] init_state [0:47];

    //output monitor
    State state_out;
    logic [3:0] move_queue[0:255];
    logic [2:0] final_state[0:47];

    // answer checking
    logic [2:0] check[0:5];
    logic wrong;
    integer correct_num;
    integer incorrect_num;

    // file parsing
    string filename, outputname;

    integer i , j , f; 

    Top DUT(
        .i_clk_12m(clk), //5*10^7
        .i_clk_2k(clk_2k),
        .i_clk_100k(clk_100k), //10^5
        .i_rst_n(rst_n), //key[0]
        .i_start(start), //key[1] // useless
        .i_start_s(start_s),
        //.init_c_state(init_state),
        //sensor
        // input [7:0] r_edge,
        // input [7:0] g_edge,
        // input [7:0] b_edge,
        // input [7:0] r_corner,
        // input [7:0] g_corner,
        // input [7:0] b_corner,
        // inout sda,
        // inout scl,

        //motor
        .M_1_en(), // maybe we can integrate step and dir as a pin and control merely by en
        .M_2_en(),
        .M_3_en(),
        .M_4_en(),
        .M_5_en(),
        .M_6_en(),
        .M_step(),
        .M_dir(),

        .state(state_out),
        .move_queue(move_queue),
        .final_state(final_state)
    );

    initial begin
        $fsdbDumpfile("top.fsdb");
        $fsdbDumpvars(0, "+mda");
    end

    // create clock
    initial clk = 1;
    always #(`HCYCLE) clk = ~clk;

    // create 2k clock
    initial clk_2k = 1;
    always #(`HCYCLE * 6) clk_2k = ~clk_2k;

     // create 100k clock
    initial clk_100k = 1;
    always #(`HCYCLE * 120) clk_100k = ~clk_100k;



    // test all input cases from 1 to CASE_NUMBER
    initial begin
        incorrect_num = 0;
        correct_num = 0;
        for (int j = 1 ;j < ((`CASE_NUMBER) + 1) ; j++) begin
            // read input
            $sformat(filename, "input/init_state_%0d.txt", j);
            $readmemb(filename, init_state);
            $write("Loaded input %d  ", j);
            //create output file
            $sformat(outputname, "output/output_%0d.txt", j);
            f = $fopen(outputname, "w");
            //reset
            wrong = 0;
            rst_n = 1;
            #(`CYCLE * 1.25);    rst_n = 0;
            #(`CYCLE * 1);      rst_n = 1;


            #(`CYCLE * 23);
            //initialization
            // do nothing ???
            start_s = 1;
            #(`CYCLE * 1);
            start_s = 0;
            

            #(`CYCLE * 10);
            start = 1;
            #(`CYCLE * 500);
            start = 0;


            
            //wait for algorithm to finish
            $write("begin testing %d  ",j );
            while(state_out != S_IDLE) begin
                #(`CYCLE);
                //$display(state_out);
            end
            $write("begin rotating %d  ",j );
            //begin rotating cube
            start = 1;
            #(`CYCLE * 1000);
            start = 0;
            while(state_out != S_DONE) begin
                #(`CYCLE);
                //$display(state_out);
            end



            // answer checking
            for(i = 0; i < 6; i++) begin
                check[i] = final_state[i];
            end
            for(i = 6; i < 48; i = i + 6)begin
                for(int k = 0; k < 6; k++) begin
                    if(check[k] != final_state[i + k]) begin
                        //$display("Oh no");
                        wrong = 1;
                    end
                end
            end
            if(wrong) begin
                $display("test %d wrong", j);
                incorrect_num = incorrect_num + 1;
            end else begin
                $display("test %d correct", j);
                correct_num = correct_num + 1;
            end

            // write to output file
            for (i = 0; i<256; i=i+1) begin
                $fwrite(f,"%b\n",move_queue[i]);
            end
            $fclose(f);

        end
        $display("correct num = %d, incorrect_num = %d", correct_num, incorrect_num);
        $finish;
    end
        

    initial begin //max time limit
        #(`MAX_CYCLE);
        $finish;
    end


endmodule