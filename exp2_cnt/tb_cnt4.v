`timescale 1ns/1ps
module tb_cnt4;
  reg clk = 0;
  reg clr = 0;
  reg en = 0;
  wire [3:0] q;
  wire carry;
  integer i;

  cnt4 dut(.clk(clk), .clr(clr), .en(en), .q(q), .carry(carry));

  always #20 clk = ~clk;   // 40ns 周期

  initial begin
    clr = 1; en = 0;
    @(posedge clk); #1;
    if (q !== 4'd0) $display("FAIL clear: q=%0d", q);
    clr = 0; en = 1;
    for (i = 0; i < 12; i = i + 1) begin
      @(posedge clk); #1;
      $display("t=%0t q=%0d carry=%b", $time, q, carry);
    end
    en = 0;
    @(posedge clk); #1;
    $display("after disable q=%0d", q);
    $display("DONE");
    $finish;
  end
endmodule
