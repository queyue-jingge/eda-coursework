`timescale 1ns/1ps
module tb_img;
  reg clk = 0;
  wire hs, vs;
  wire [7:0] rgb;
  vga_image dut(.clk48m(clk), .hs(hs), .vs(vs), .rgb(rgb));
  always #10.4167 clk = ~clk;

  task sample(input [9:0] h, input [9:0] v);
    begin
      force dut.hcnt = h;
      force dut.vcnt = v;
      #100;
      $display("h=%0d v=%0d rgb=%02X", h, v, rgb);
      release dut.hcnt;
      release dut.vcnt;
    end
  endtask

  initial begin
    #100;
    sample(0, 0);
    sample(10, 10);
    sample(320, 240);
    sample(635, 475);
    $display("DONE");
    $finish;
  end
endmodule
