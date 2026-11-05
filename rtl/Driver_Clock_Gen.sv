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