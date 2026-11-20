module debounce16(
    input clk48m,
    input key_in,      // 消抖通道
    input key_rst,     // 不消抖对比通道
    output [7:0] seg,
    output [7:0] dig
);
  // 200Hz 采样：48MHz / 240000
  reg [17:0] div = 0;
  wire tick = (div == 18'd239999);
  always @(posedge clk48m) div <= tick ? 18'd0 : div + 1'b1;

  // 消抖通道：连续三次为低
  reg s0 = 1, s1 = 1, s2 = 1;
  always @(posedge clk48m) if (tick) begin
    s0 <= key_in;
    s1 <= s0;
    s2 <= s1;
  end
  // 三次采样相或：只有连续三次都为低（0|0|0）才输出低，才算一次按下
  wire key_out = s0 | s1 | s2;

  reg [3:0] cnt = 0;
  reg key_d = 1;
  always @(posedge clk48m) begin
    key_d <= key_out;
    if (key_d && !key_out) cnt <= cnt + 1'b1;
  end

  // 不消抖通道：直接对原始电平计下降沿
  reg raw_d = 1;
  reg [3:0] raw = 0;
  always @(posedge clk48m) begin
    raw_d <= key_rst;
    if (raw_d && !key_rst) raw <= raw + 1'b1;
  end

  // 四位扫描：右两位消抖值，左两位原始值
  reg [15:0] sdiv = 0;
  wire st = (sdiv == 16'd47999);
  always @(posedge clk48m) sdiv <= st ? 16'd0 : sdiv + 1'b1;
  reg [1:0] scan = 0;
  always @(posedge clk48m) if (st) scan <= scan + 1'b1;

  reg [3:0] dval;
  always @(*) begin
    case (scan)
      2'd0: dval = cnt % 10;
      2'd1: dval = cnt / 10;
      2'd2: dval = raw % 10;
      default: dval = raw / 10;
    endcase
  end

  assign dig = ~(8'h01 << scan);
  assign seg = decode(dval);

  function [7:0] decode;
    input [3:0] d;
    begin
      case (d)
        4'h0: decode = 8'b1100_0000;
        4'h1: decode = 8'b1111_1001;
        4'h2: decode = 8'b1010_0100;
        4'h3: decode = 8'b1011_0000;
        4'h4: decode = 8'b1001_1001;
        4'h5: decode = 8'b1001_0010;
        4'h6: decode = 8'b1000_0010;
        4'h7: decode = 8'b1111_1000;
        4'h8: decode = 8'b1000_0000;
        4'h9: decode = 8'b1001_0000;
        default: decode = 8'b1111_1111;
      endcase
    end
  endfunction
endmodule
