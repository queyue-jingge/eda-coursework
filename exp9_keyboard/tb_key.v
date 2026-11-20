`timescale 1ns/1ps
module tb_key;
  reg clk = 0;
  reg [7:0] key = 8'b1111_1110;
  wire buzzer;
  wire [7:0] seg, dig;
  integer edges = 0;
  time t0, t1;

  keyboard dut(.clk48m(clk), .key(key), .buzzer(buzzer), .seg(seg), .dig(dig));
  always #10.4167 clk = ~clk;
  always @(posedge buzzer) edges = edges + 1;

  initial begin
    #1000000;
    edges = 0; t0 = $time;
    #200000000;    // 200ms
    t1 = $time;
    $display("note1 edges=%0d freq=%0dHz", edges, edges * 1000000000 / (t1 - t0));
    $finish;
  end
endmodule
