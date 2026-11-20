module freq_div(
    input clk48m,
    input [4:1] key,
    output reg buzzer,
    output [7:0] seg,
    output [7:0] dig
);
  // 200Hz 采样，三次相或消抖
  reg [17:0] ddiv = 0;
  wire dtick = (ddiv == 18'd239999);
  always @(posedge clk48m) ddiv <= dtick ? 18'd0 : ddiv + 1'b1;

  reg [4:0] s0 = 5'h1f, s1 = 5'h1f, s2 = 5'h1f;
  always @(posedge clk48m) if (dtick) begin
    s0 <= {key, 1'b1}; s1 <= s0; s2 <= s1;
  end
  wire [4:0] kd = s0 | s1 | s2;   // 低有效

  reg [23:0] target = 24'd240000;
  always @(*) begin
    case (kd)
      5'b11101: target = 24'd24_000;   // key1
      5'b11011: target = 24'd48_000;   // key2
      5'b10111: target = 24'd96_000;   // key3
      5'b01111: target = 24'd192_000;  // key4
      default:  target = 24'd240000;
    endcase
  end

  // pulse 预置式计数器：计满后重装 0，翻转输出
  reg [23:0] cnt = 0;
  always @(posedge clk48m) begin
    if (cnt >= target - 1) begin
      cnt <= 0;
      buzzer <= ~buzzer;
    end else cnt <= cnt + 1'b1;
  end

  // 两位显示分频系数（单位 kHz）
  reg [15:0] sdiv = 0;
  wire stick = (sdiv == 16'd23999);
  always @(posedge clk48m) sdiv <= stick ? 16'd0 : sdiv + 1'b1;
  reg [1:0] scan = 0;
  always @(posedge clk48m) if (stick) scan <= scan + 1'b1;

  wire [23:0] khz = target / 24'd1000;
  reg [3:0] dv;
  always @(*) begin
    case (scan)
      2'd0: dv = khz % 10;
      2'd1: dv = (khz / 10) % 10;
      default: dv = (khz / 100) % 10;
    endcase
  end
  assign dig = ~(8'h01 << scan);
  assign seg = decode(dv);

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

  initial begin
    cnt = 0;
    buzzer = 0;
  end
endmodule
