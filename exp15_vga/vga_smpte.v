module vga_smpte(
    input clk48m,
    input keya,          // 低有效，按一下切一种模式
    output hs,
    output vs,
    output [7:0] rgb
);
  // 48MHz / 2 = 24MHz 像素时钟
  reg clk25 = 0;
  always @(posedge clk48m) clk25 <= ~clk25;

  reg [9:0] hcnt = 0;
  reg [9:0] vcnt = 0;
  always @(posedge clk25) begin
    if (hcnt == 10'd799) begin
      hcnt <= 10'd0;
      if (vcnt == 10'd524) vcnt <= 10'd0;
      else vcnt <= vcnt + 1'b1;
    end else hcnt <= hcnt + 1'b1;
  end

  assign hs = ~((hcnt >= 10'd656) && (hcnt <= 10'd751));
  assign vs = ~((vcnt >= 10'd490) && (vcnt <= 10'd491));
  wire active = (hcnt < 10'd640) && (vcnt < 10'd480);

  // KEYA 消抖：200Hz 采样（48M/240000），三次相与为低
  reg [17:0] kdiv = 0;
  wire ktick = (kdiv == 18'd239999);
  always @(posedge clk48m) kdiv <= ktick ? 18'd0 : kdiv + 1'b1;

  reg k0 = 1, k1 = 1, k2 = 1;
  always @(posedge clk48m) if (ktick) begin
    k0 <= keya; k1 <= k0; k2 <= k1;
  end
  wire kpressed = ~(k0 & k1 & k2);

  reg [1:0] mode = 0;
  reg kd = 0;
  always @(posedge clk48m) begin
    kd <= kpressed;
    if (kd && !kpressed) mode <= mode + 1'b1;
  end

  // 八条彩条颜色，用组合函数直接出，不建数组
  function [7:0] color;
    input [2:0] i;
    begin
      case (i)
        3'd0: color = 8'b100_100_10; // 灰
        3'd1: color = 8'b111_111_00; // 黄
        3'd2: color = 8'b000_111_11; // 青
        3'd3: color = 8'b000_111_00; // 绿
        3'd4: color = 8'b111_000_11; // 品红
        3'd5: color = 8'b111_000_00; // 红
        3'd6: color = 8'b000_000_11; // 蓝
        default: color = 8'b010_010_01; // 深灰
      endcase
    end
  endfunction

  wire [2:0] ci = hcnt / 10'd80;     // 0..7
  wire [2:0] ri = vcnt / 10'd60;     // 0..7
  wire chk = ((hcnt / 10'd80) ^ (vcnt / 10'd60)) & 1;

  reg [7:0] c;
  always @(*) begin
    case (mode)
      2'd0: c = color(ci);                       // 竖彩条 8×80
      2'd1: c = color(ri);                       // 横彩条 8×60
      2'd2: c = chk ? 8'b111_111_11 : 8'b000_000_00;
      default: c = chk ? 8'b000_000_00 : 8'b111_111_11;
    endcase
  end

  assign rgb = active ? c : 8'b0;
endmodule
