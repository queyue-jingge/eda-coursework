module dds(
    input clk48m,
    input [1:0] f_sel,
    output [7:0] dac
);
  // 32 位相位累加器，取高 8 位查正弦表
  reg [31:0] acc = 0;
  reg [31:0] fcw;
  always @(*) begin
    // 48MHz / 2^32 * fcw = fout  =>  fcw = fout * 2^32 / 48e6
    case (f_sel)
      2'd0: fcw = 32'd89478;    // 约 1kHz
      2'd1: fcw = 32'd178956;   // 约 2kHz
      2'd2: fcw = 32'd447392;   // 约 5kHz
      default: fcw = 32'd894784; // 约 10kHz
    endcase
  end
  always @(posedge clk48m) acc <= acc + fcw;

  reg [7:0] sine [0:255];
  initial $readmemh("sine.hex", sine);

  assign dac = sine[acc[31:24]];
endmodule
