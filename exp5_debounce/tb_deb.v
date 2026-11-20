`timescale 1ns/1ps
module tb_deb;
  reg clk = 0;
  reg key_in = 1, key_rst = 1;
  wire [7:0] seg, dig;
  integer i;

  debounce16 dut(.clk48m(clk), .key_in(key_in), .key_rst(key_rst), .seg(seg), .dig(dig));
  always #10.4167 clk = ~clk;

  initial begin
    #1000;
    // 抖动：4 个短脉冲（5ms 间隔内）
    for (i = 0; i < 4; i = i + 1) begin
      key_in = 0; key_rst = 0; #200000;
      key_in = 1; key_rst = 1; #200000;
    end
    // 稳定按下 30ms
    key_in = 0; key_rst = 0; #30000000;
    key_in = 1; key_rst = 1; #2000000;
    $display("debounced=%0d raw=%0d", dut.cnt, dut.raw);
    $finish;
  end
endmodule
