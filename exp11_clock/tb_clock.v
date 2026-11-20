`timescale 1ns/1ps
module tb_clock;
  reg clk = 0;
  reg enable = 0;   // 按键低有效：0=按下=走时
  reg reset = 1;    // 1=松开
  wire [7:0] seg, dig;
  integer i;

  digital_clock dut(.clk48m(clk), .enable(enable), .reset(reset), .seg(seg), .dig(dig));
  always #10.4167 clk = ~clk;

  task tick;
    begin
      force dut.div = 26'd47_999_999;
      @(posedge clk); #1;
      release dut.div;
      @(posedge clk); #1;
    end
  endtask

  initial begin
    #100;
    reset = 0; tick; reset = 1;   // 按下清零
    $display("after reset %0d:%0d:%0d", dut.hour, dut.min, dut.sec);
    for (i = 0; i < 62; i = i + 1) tick;
    $display("after 62 ticks %0d:%0d:%0d", dut.hour, dut.min, dut.sec);
    for (i = 0; i < 3600; i = i + 1) tick;
    $display("after +3600 ticks %0d:%0d:%0d", dut.hour, dut.min, dut.sec);
    $display("DONE");
    $finish;
  end
endmodule
