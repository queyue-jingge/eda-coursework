module test_led(
    input clk48m,
    output reg str,
    output reg sclk,
    output reg d_out
);
  // 60kHz 状态机
  reg [9:0] div = 0;
  wire tick = (div == 10'd799);
  always @(posedge clk48m) div <= tick ? 10'd0 : div + 1'b1;

  reg [3:0] col = 0;
  reg [5:0] bitc = 0;
  reg [31:0] sh;

  always @(posedge clk48m) if (tick) begin
    if (bitc == 0) begin
      str <= 1'b0;
      sclk <= 1'b0;
      sh <= {16'hFFFF, ~(16'h0001 << col)};  // 所有行亮，只选一列
      bitc <= 6'd1;
    end else if (bitc <= 6'd32) begin
      if (!sclk) begin
        d_out <= sh[31];
        sh <= {sh[30:0], 1'b0};
        sclk <= 1'b1;
      end else begin
        sclk <= 1'b0;
        bitc <= bitc + 1'b1;
      end
    end else begin
      str <= 1'b1;      // 锁存
      bitc <= 6'd0;
      col <= col + 1'b1;
    end
  end

  initial begin
    str = 0; sclk = 0; d_out = 0;
  end
endmodule
