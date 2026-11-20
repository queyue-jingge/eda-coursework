`timescale 1ns/1ps
module tb_full;
  reg a, b, c;
  wire co, so;
  full_adder dut(.a(a), .b(b), .c(c), .co(co), .so(so));
  integer i;
  initial begin
    for (i = 0; i < 8; i = i + 1) begin
      {a, b, c} = i[2:0];
      #10;
      $display("%b%b%b -> co=%b so=%b sum=%0d", a, b, c, co, so, co * 2 + so);
    end
    $finish;
  end
endmodule
