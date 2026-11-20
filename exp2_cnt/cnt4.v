module cntN #(parameter N = 10, parameter W = 4) (
    input clk,
    input clr,
    input en,
    output reg [W-1:0] q,
    output carry
);
  assign carry = en && (q == N-1);
  always @(posedge clk) begin
    if (clr) q <= {W{1'b0}};
    else if (en) begin
      if (q == N-1) q <= {W{1'b0}};
      else q <= q + 1'b1;
    end
  end
endmodule
module cnt4(input clk, input clr, input en, output [3:0] q, output carry);
  cntN #(.N(10), .W(4)) u (.clk(clk), .clr(clr), .en(en), .q(q), .carry(carry));
endmodule
