module State_Preparer (
    input i_clk,
    input i_rst_n,
    input i_ls_done,
    input i_corner_color,
    input i_edge_color,

    output o_done,
    output o_finished,
    output [2:0] o_c_state [0:47]
);
    logic [2:0] c_state_w [0:47];
    logic [2:0] c_state_r [0:47];
    logic [4:0] count_w, count_r;
    logic done_w, done_r;
    logic finished_w, finished_r;
    logic prev_ls_done_w, prev_ls_done_r;
    integer i;

    assign o_done = done_r;
    assign o_c_state = c_state_r;
    assign o_finished = finished_r;
    always_comb begin
        c_state_w = c_state_r;
        count_w = count_r;
        done_w = done_r;
        finished_w = finished_r;
        prev_ls_done_w = i_ls_done;
        if (i_ls_done && !prev_ls_done_r) begin
            done_w = 1;
            case (count_r)
                5'd0:  begin
                    c_state_w[12] = i_corner_color;
                    c_state_w[36] = i_edge_color;
                    count_w = count_r + 1;
                end
                5'd1: begin
                    c_state_w[6] = i_corner_color;
                    c_state_w[30] = i_edge_color;
                    count_w = count_r + 1;
                end
                5'd2: begin
                    c_state_w[0] = i_corner_color;
                    c_state_w[24] = i_edge_color;
                    count_w = count_r + 1;
                end
                5'd3: begin
                    c_state_w[18] = i_corner_color;
                    c_state_w[42] = i_edge_color;
                    count_w = count_r + 1;
                end
                5'd4: begin
                    c_state_w[13] = i_corner_color;
                    c_state_w[37] = i_edge_color;
                    count_w = count_r + 1;
                end
                5'd5: begin
                    c_state_w[7] = i_corner_color;
                    c_state_w[31] = i_edge_color;
                    count_w = count_r + 1;
                end
                5'd6: begin
                    c_state_w[1] = i_corner_color;
                    c_state_w[25] = i_edge_color;
                    count_w = count_r + 1;
                end
                5'd7:begin
                    c_state_w[19] = i_corner_color;
                    c_state_w[43] = i_edge_color;
                    count_w = count_r + 1;
                end
                5'd8:begin
                    c_state_w[14] = i_corner_color;
                    c_state_w[38] = i_edge_color;
                    count_w = count_r + 1;
                end
                5'd9:begin
                    c_state_w[8] = i_corner_color;
                    c_state_w[32] = i_edge_color;
                    count_w = count_r + 1;
                end
                5'd10: begin
                    c_state_w[2] = i_corner_color;
                    c_state_w[26] = i_edge_color;
                    count_w = count_r + 1;
                end
                5'd11: begin
                    c_state_w[20] = i_corner_color;
                    c_state_w[44] = i_edge_color;
                    count_w = count_r + 1;
                end
                5'd12: begin
                    c_state_w[15] = i_corner_color;
                    c_state_w[39] = i_edge_color;
                    count_w = count_r + 1;
                end
                5'd13: begin
                    c_state_w[9] = i_corner_color;
                    c_state_w[33] = i_edge_color;
                    count_w = count_r + 1;
                end
                5'd14: begin
                    c_state_w[3] = i_corner_color;
                    c_state_w[27] = i_edge_color;
                    count_w = count_r + 1;
                end
                5'd15: begin
                    c_state_w[21] = i_corner_color;
                    c_state_w[45] = i_edge_color;
                    count_w = count_r + 1;
                end
                5'd16: begin
                    c_state_w[16] = i_corner_color;
                    c_state_w[40] = i_edge_color;
                    count_w = count_r + 1;
                end
                5'd17: begin
                    c_state_w[10] = i_corner_color;
                    c_state_w[34] = i_edge_color;
                    count_w = count_r + 1;
                end
                5'd18: begin
                    c_state_w[4] = i_corner_color;
                    c_state_w[28] = i_edge_color;
                    count_w = count_r + 1;
                end
                5'd19: begin
                    c_state_w[22] = i_corner_color;
                    c_state_w[46] = i_edge_color;
                    count_w = count_r + 1;
                end
                5'd20: begin
                    c_state_w[17] = i_corner_color;
                    c_state_w[41] = i_edge_color;
                    count_w = count_r + 1;
                end
                5'd21: begin
                    c_state_w[11] = i_corner_color;
                    c_state_w[35] = i_edge_color;
                    count_w = count_r + 1;
                end
                5'd22: begin
                    c_state_w[5] = i_corner_color;
                    c_state_w[29] = i_edge_color;
                    count_w = count_r + 1;
                end
                5'd23: begin
                    c_state_w[23] = i_corner_color;
                    c_state_w[47] = i_edge_color;
                    count_w = count_r + 1;
                    finished_w = 1;
                end
                default: begin
                    c_state_w = c_state_r;
                end
            endcase
        end
        else begin
            done_w = 0;
        end
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            for (i = 0; i < 48 ; i++) begin
                c_state_r[i] <= c_state_w[i]; 
            end
            done_r <= 0;
            count_r <= 0;
            finished_r <= 0;
            prev_ls_done_r <= 0;
        end
        else begin
            c_state_r <= c_state_w;
            done_r <= done_w;
            count_r <= count_w;
            finished_r <= finished_w;
            prev_ls_done_r <= prev_ls_done_w;
        end
    end
endmodule