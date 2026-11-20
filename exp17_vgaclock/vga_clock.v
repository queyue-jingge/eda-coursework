module vga_clock(
    input clk48m,
    input enable,      // 按键低有效：按住走时
    input reset,       // 按键低有效：按住清零
    output hs,
    output vs,
    output [7:0] rgb
);
  reg clk25 = 0;
  always @(posedge clk48m) clk25 <= ~clk25;

  reg [9:0] hcnt = 0, vcnt = 0;
  always @(posedge clk25) begin
    if (hcnt == 10'd799) begin
      hcnt <= 0;
      if (vcnt == 10'd524) vcnt <= 0; else vcnt <= vcnt + 1'b1;
    end else hcnt <= hcnt + 1'b1;
  end
  assign hs = ~((hcnt >= 10'd656) && (hcnt <= 10'd751));
  assign vs = ~((vcnt >= 10'd490) && (vcnt <= 10'd491));
  wire active = (hcnt < 10'd640) && (vcnt < 10'd480);

  // 1Hz 计时：像素时钟 24MHz
  reg [25:0] div = 0;
  wire tick = (div == 26'd23_999_999);
  always @(posedge clk25) div <= tick ? 0 : div + 1'b1;

  wire en_n = ~enable;
  wire rst_n = ~reset;

  reg [5:0] sec = 0, min = 0, hour = 0;
  always @(posedge clk25) begin
    if (rst_n) begin
      sec <= 0; min <= 0; hour <= 0;
    end else if (tick && en_n) begin
      if (sec == 59) begin
        sec <= 0;
        if (min == 59) begin min <= 0; hour <= (hour == 23) ? 0 : hour + 1; end
        else min <= min + 1;
      end else sec <= sec + 1;
    end
  end

  // 六个数字：HH MM SS，每个 60x100，间距 20，起点 x=60，y=180
  wire [9:0] rel_x = (hcnt >= 10'd60) ? (hcnt - 10'd60) : 10'd1023;
  wire [9:0] rel_y = (vcnt >= 10'd180) ? (vcnt - 10'd180) : 10'd1023;
  wire [11:0] pos = rel_x / 10'd80;
  wire [9:0] dx = rel_x % 10'd80;
  wire inside = (rel_y < 10'd100) && (pos < 6) && (dx < 10'd60);

  reg [3:0] dval;
  always @(*) begin
    case (pos)
      0: dval = hour / 10;
      1: dval = hour % 10;
      2: dval = min / 10;
      3: dval = min % 10;
      4: dval = sec / 10;
      default: dval = sec % 10;
    endcase
  end

  // 两个冒号：HH:MM:SS，各两个 12x12 点
  wire colon = ((hcnt >= 10'd202 && hcnt < 10'd214) || (hcnt >= 10'd362 && hcnt < 10'd374)) &&
               ((vcnt >= 10'd206 && vcnt < 10'd218) || (vcnt >= 10'd242 && vcnt < 10'd254));

  function seg_lit;
    input [3:0] d;
    input [9:0] x;
    input [9:0] y;
    begin
      seg_lit = 0;
      if (y < 10'd12 && x >= 10'd6 && x < 10'd54) seg_lit = 1;
      if (x >= 10'd48 && x < 10'd60 && y >= 10'd6 && y < 10'd50) seg_lit = 1;
      if (x >= 10'd48 && x < 10'd60 && y >= 10'd50 && y < 10'd94) seg_lit = 1;
      if (y >= 10'd88 && y < 10'd100 && x >= 10'd6 && x < 10'd54) seg_lit = 1;
      if (x >= 10'd0 && x < 10'd12 && y >= 10'd50 && y < 10'd94) seg_lit = 1;
      if (x >= 10'd0 && x < 10'd12 && y >= 10'd6 && y < 10'd50) seg_lit = 1;
      if (y >= 10'd44 && y < 10'd56 && x >= 10'd6 && x < 10'd54) seg_lit = 1;
      case (d)
        4'h0: if (y >= 10'd44 && y < 10'd56) seg_lit = 0;
        4'h1: if ((y < 10'd12) || (y >= 10'd88) || (x < 10'd48)) seg_lit = 0;
        4'h2: if ((x < 10'd12 && y >= 10'd50) || (x >= 10'd48 && y < 10'd50)) seg_lit = 0;
        4'h3: if ((x < 10'd48 && (y < 10'd12 || y >= 10'd88)) || (x >= 10'd48 && y < 10'd6)) seg_lit = 0;
        4'h4: if ((y < 10'd6) || (y >= 10'd88) || (x < 10'd12 && y >= 10'd50)) seg_lit = 0;
        4'h5: if ((x < 10'd12 && y < 10'd50) || (x >= 10'd48 && y >= 10'd50)) seg_lit = 0;
        4'h6: if (x >= 10'd48 && y < 10'd50) seg_lit = 0;
        4'h7: if ((y >= 10'd56) || (x < 10'd48)) seg_lit = 0;
        4'h8: ;
        4'h9: if (x < 10'd12 && y >= 10'd50) seg_lit = 0;
        default: seg_lit = 0;
      endcase
    end
  endfunction

  wire lit = seg_lit(dval, dx, rel_y);
  assign rgb = active ? (((inside && lit) || colon) ? 8'b111_111_11 : 8'b000_000_11) : 8'b0;
endmodule
