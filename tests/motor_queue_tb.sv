module motor_queue_tb;
  bit clk, rst_n, motor_start, driver_done;
  logic [3:0] moves[0:31], queue[0:255];
  logic done;
  always #5 clk = ~clk;
  motor dut (.clk(clk), .rst_n(rst_n), .motor_start(motor_start),
             .i_dd_done(driver_done), .color(3'd1), .m_s(moves),
             .motor_done(done), .move_queue(queue));
  initial begin : run
    foreach (moves[i]) moves[i]=0;
    moves[0]=4'h2; // Front clockwise on green.
    moves[1]=4'h1; // Rotate reference frame; emits no physical word.
    moves[2]=4'h3; // Front counterclockwise on red.
    repeat (2) @(negedge clk);
    rst_n=1;
    motor_start=1;
    @(negedge clk); motor_start=0;
    repeat (12) begin
      @(negedge clk);
      if (done) begin
        if (queue[0] !== 4'b0010 || queue[1] !== 4'b1011 || queue[2] !== 0)
          $fatal(1,"Unexpected motor words %h %h %h",queue[0],queue[1],queue[2]);
        $display("PASS: front turns select motors 2 and 3; view change emits no motor word");
        $finish;
        disable run;
      end
    end
    $fatal(1,"No motor_done");
  end
endmodule
