module Driver_Decoder (
    input i_clk,
    input i_rst_n,
    input i_start,
    input [3:0] i_move_queue[0:255],
    
    output o_en_1, //whit
    output o_en_2, //green
    output o_en_3, //red
    output o_en_4, //blue
    output o_en_5, //orange
    output o_en_6, //yellow
    output o_dir,
    output o_step,
    output o_done
);

//declaration

parameter S_IDLE = 2'd0;  
parameter S_PROC = 2'd1;
parameter S_WAIT = 2'd2;

logic [3:0] current_move;
logic [5:0] step_count_w, step_count_r;
logic [7:0] move_count_w, move_count_r;
logic done_w, done_r;
// logic step_w, step_r;
logic [1:0] state_w, state_r;

assign current_move = (state_r == S_PROC) ? i_move_queue[move_count_r] : 4'b0000;
assign o_dir = current_move[3];
assign o_step = i_clk;
assign o_en_1 = (current_move[2:0] == 3'd1) ? 0 : 1;
assign o_en_2 = (current_move[2:0] == 3'd2) ? 0 : 1;
assign o_en_3 = (current_move[2:0] == 3'd3) ? 0 : 1;
assign o_en_4 = (current_move[2:0] == 3'd4) ? 0 : 1;
assign o_en_5 = (current_move[2:0] == 3'd5) ? 0 : 1;
assign o_en_6 = (current_move[2:0] == 3'd6) ? 0 : 1;


always_comb begin
    state_w = state_r;
    step_count_w = step_count_r;
    done_w = done_r;
    move_count_w = move_count_r;
    case (state_r)
        S_IDLE: begin
            done_w = 0;
            if (i_start) begin
                state_w = S_PROC;
                step_count_w = 0;
                move_count_w = 0;
            end
        end 
        S_PROC: begin
            if (step_count_r == 49) begin
                state_w = S_WAIT;
                step_count_w = 0;
                move_count_w = move_count_r + 1;
                if (i_move_queue[move_count_r + 1][3:0] == 4'b0000) begin
                    state_w = S_IDLE;
                    done_w = 1;
                end
            end
            else begin
                step_count_w = step_count_r + 1;
                
            end
        end
        S_WAIT:begin
            if(step_count_r == 49)begin
                state_w = S_PROC;
                step_count_w = 0;
            end
            else  begin
                step_count_w = step_count_r+1;
            end
        end
    endcase
end

always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if (!i_rst_n) begin
        state_r <= S_IDLE;
        move_count_r <= 0;
        step_count_r <= 0;
        done_r = 0;
    end
    else begin
        state_r <= state_w;
        move_count_r <= move_count_w;
        step_count_r <= step_count_w;
        done_r <= done_w;
    end
end
endmodule

module Driver_Clock_Gen (
    input i_clk,//2k
    input i_rst_n,

    output o_clk//200
);
    logic [3:0] count_w, count_r;
    logic clk_w, clk_r;

    assign o_clk = clk_r;

    always_comb begin
        count_w = count_r + 1;
        clk_w = clk_r;
        if (count_r == 9) begin
            clk_w = !clk_r;
            count_w = 0;
        end
    end
    
    always_ff @( posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            count_r <= 0;
            clk_r <= 0;
        end
        else begin
            count_r <= count_w;
            clk_r <= clk_w;
        end
    end
endmodule