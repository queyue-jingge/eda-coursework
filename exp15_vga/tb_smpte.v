`timescale 1ns/1ps
module tb_smpte;
  reg clk = 0;
  reg keya = 1;
  wire hs, vs;
  wire [7:0] rgb;
  integer i;

  vga_smpte dut(.clk48m(clk), .keya(keya), .hs(hs), .vs(vs), .rgb(rgb));
  always #10.4167 clk = ~clk;

  task sample(input [9:0] h, input [9:0] v);
    begin
      force dut.hcnt = h;
      force dut.vcnt = v;
      #100;
      $display("h=%0d v=%0d rgb=%08b", h, v, rgb);
      release dut.hcnt;
      release dut.vcnt;
    end
  endtask

  initial begin
    #100;
    sample(50, 100);    // ci=0 灰
    sample(120, 100);   // ci=1 黄
    sample(200, 100);   // ci=2 青
    sample(400, 100);   // ci=5 红
    sample(600, 100);   // ci=7 深灰
    for (i = 0; i < 4; i = i + 1) begin
      keya = 0; #30000000; keya = 1; #30000000;   // 30ms，够 200Hz 采样
    end
    sample(50, 100);
    $display("mode after 4 presses = %0d", dut.mode);
    $finish;
  end
endmodule
