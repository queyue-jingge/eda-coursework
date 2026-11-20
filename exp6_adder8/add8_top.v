module add8_top(
    input clk48m,
    input [5:1] key,
    output led_cin,
    output led_cout,
    output [6:1] no_use_led,
    output [7:0] seg,
    output [7:0] dig
);
  // 200Hz 消抖采样
  reg [17:0] ddiv = 0;
  wire dtick = (ddiv == 18'd239999);
  always @(posedge clk48m) ddiv <= dtick ? 18'd0 : ddiv + 1'b1;

  reg [2:0] s1 = 3'b111, s2 = 3'b111, s3 = 3'b111;
  always @(posedge clk48m) if (dtick) begin
    s1 <= key[3:1];
    s2 <= s1;
    s3 <= s2;
  end
  wire [2:0] kout = ~(s1 & s2 & s3);   // 按下为 1

  reg [1:0] kd = 0;
  reg [3:0] a = 0, b = 0;
  always @(posedge clk48m) begin
    kd <= kout[1:0];
    if (kout[0] && !kd[0]) a <= a + 1'b1;      // KEY1 加数 A +1
    if (kout[1] && !kd[1]) b <= b + 1'b1;      // KEY2 加数 B +1
    if (kout[2]) begin a <= 0; b <= 0; end     // KEY3 清零
  end

  wire [4:0] sum = {1'b0, a} + {1'b0, b} + {4'b0, key[4] ? 1'b0 : 1'b1};
  assign led_cin = ~key[4];        // KEY4 作为进位输入
  assign led_cout = sum[4];
  assign no_use_led = {sum[4], a[1], a[0], b[1], b[0], sum[3]};

  // 四位扫描：A、B、和低、和高
  reg [15:0] sdiv = 0;
  wire stick = (sdiv == 16'd11999);
  always @(posedge clk48m) sdiv <= stick ? 16'd0 : sdiv + 1'b1;
  reg [1:0] scan = 0;
  always @(posedge clk48m) if (stick) scan <= scan + 1'b1;

  reg [3:0] dval;
  always @(*) begin
    case (scan)
      2'd0: dval = a;
      2'd1: dval = b;
      2'd2: dval = sum[3:0];
      default: dval = {3'b000, sum[4]};
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
        4'hA: decode = 8'b1000_1000;
        4'hB: decode = 8'b1000_0011;
        4'hC: decode = 8'b1100_0110;
        4'hD: decode = 8'b1010_0001;
        4'hE: decode = 8'b1000_0110;
        default: decode = 8'b1000_1110;
      endcase
    end
  endfunction
endmodule
