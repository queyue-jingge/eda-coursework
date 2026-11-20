`timescale 1ns/1ps
module tb_dled;
  reg clk = 0;
  wire [7:0] seg, dig;
  reg [2:0] prev;
  integer i;
  dled dut(.clk48m(clk), .seg(seg), .dig(dig));
  always #10 clk = ~clk;

  initial begin
    #1;
    for (i = 0; i < 10; i = i + 1) begin
      prev = dut.sel;
      wait (dut.sel !== prev);
      #100;
      $display("sel=%0d dig=%b seg=%b", dut.sel, dig, seg);
    end
    $display("DONE");
    $finish;
  end
endmodule
