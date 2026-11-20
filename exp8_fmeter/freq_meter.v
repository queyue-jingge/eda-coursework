module freq_meter(
    input clk48m,
    input f_in,
    output [7:0] seg,
    output [7:0] dig,
    output reg motor_a,
    output reg motor_b,
    output reg load,
    output cout
);
  // 1 秒闸门
  reg [25:0] gate = 0;
  wire gate_end = (gate == 26'd47_999_999);
  always @(posedge clk48m) gate <= gate_end ? 0 : gate + 1;

  reg f_d = 0;
  reg [31:0] cnt = 0;
  reg [31:0] value = 0;
  always @(posedge clk48m) begin
    f_d <= f_in;
    if (f_in && !f_d) cnt <= cnt + 1;
    if (gate_end) begin
      value <= cnt;
      cnt <= 0;
    end
  end
  assign cout = gate_end;   // 闸门结束给一个进位脉冲

  // 电机控制占位：正转
  always @(posedge clk48m) begin
    motor_a <= 1'b1;
    motor_b <= 1'b0;
    load <= gate_end;      // 每秒一个 load 脉冲
  end

  // 8 位十进制显示
  reg [2:0] scan = 0;
  reg [16:0] sdiv = 0;
  wire st = (sdiv == 17'd119999);   // 400Hz 扫描
  always @(posedge clk48m) begin
    sdiv <= st ? 0 : sdiv + 1;
    if (st) scan <= scan + 1;
  end

  reg [3:0] digit;
  always @(*) begin
    case (scan)
      0: digit = value % 10;
      1: digit = (value / 10) % 10;
      2: digit = (value / 100) % 10;
      3: digit = (value / 1000) % 10;
      4: digit = (value / 10000) % 10;
      5: digit = (value / 100000) % 10;
      6: digit = (value / 1000000) % 10;
      default: digit = (value / 10000000) % 10;
    endcase
  end

  assign dig = ~(8'h01 << scan);
  assign seg = decode(digit);

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
