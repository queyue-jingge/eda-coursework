module siggen(
    input clk48m,
    input [1:0] wave_sel,   // 0 正弦 1 方波 2 三角 3 锯齿
    output reg [9:0] dac
);
  // 256 点表，256kHz 步进 -> 1kHz 波形
  reg [9:0] sdiv = 0;
  wire stick = (sdiv == 10'd187);
  always @(posedge clk48m) sdiv <= stick ? 10'd0 : sdiv + 1'b1;

  reg [7:0] addr = 0;
  always @(posedge clk48m) if (stick) addr <= addr + 1'b1;

  reg [9:0] sine [0:255];
  initial $readmemh("sine10.hex", sine);

  always @(*) begin
    case (wave_sel)
      2'd0: dac = sine[addr];
      2'd1: dac = (addr < 8'd128) ? 10'd1023 : 10'd0;
      2'd2: dac = (addr < 8'd128) ? ({2'b00, addr} << 3) : (10'd1023 - ({2'b00, addr} << 3));
      default: dac = {2'b00, addr} << 2;
    endcase
  end
endmodule
