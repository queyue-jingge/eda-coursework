`timescale 1ns/1ps
module tb_led1616;
  reg clk = 0;
  wire str, sclk, d_out;
  integer sclk_cnt = 0;
  integer str_cnt = 0;
  reg [31:0] cap = 0;
  integer i;

  led1616 dut(.clk48m(clk), .str(str), .sclk(sclk), .d_out(d_out));
  always #10.4167 clk = ~clk;   // ~48MHz

  always @(posedge sclk) begin
    sclk_cnt <= sclk_cnt + 1;
    cap <= {cap[30:0], d_out};
  end

  always @(posedge str) begin
    str_cnt <= str_cnt + 1;
    if (str_cnt < 3) begin
      $display("STR#%0d sclk_in_frame=%0d captured=%08X", str_cnt, sclk_cnt, cap);
    end
    sclk_cnt <= 0;
  end

  initial begin
    #3_000_000;   // 3ms
    $display("frames=%0d", str_cnt);
    $display("DONE");
    $finish;
  end
endmodule
