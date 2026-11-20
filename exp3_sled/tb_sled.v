`timescale 1ns/1ps
module tb_sled;
  reg clk = 0;
  wire [7:0] seg, dig;
  integer i;
  sled dut(.clk48m(clk), .seg(seg), .dig(dig));
  always #10 clk = ~clk;
  initial begin
    #1;
    for (i = 0; i < 18; i = i + 1) begin
      force dut.div = 26'd47_999_999;
      @(posedge clk); #1;
      release dut.div;
      $display("cnt=%0h seg=%b dig=%b", dut.cnt, seg, dig);
      @(posedge clk);
    end
    $display("DONE");
    $finish;
  end
endmodule