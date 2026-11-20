module digital_clock(
    input clk48m,
    input enable,
    input reset,
    output [7:0] seg,
    output [7:0] dig
);
  // 1Hz 秒脉冲：48MHz / 48,000,000
  reg [25:0] div = 0;
  wire tick1 = (div == 26'd47_999_999);
  always @(posedge clk48m) div <= tick1 ? 26'd0 : div + 1'b1;

  // 实验箱按键低有效，这里取反成高有效内部信号
  wire en_n = ~enable;
  wire rst_n = ~reset;

  reg [5:0] sec = 0, min = 0, hour = 0;
  always @(posedge clk48m) begin
    if (rst_n) begin
      sec <= 0; min <= 0; hour <= 0;
    end else if (tick1 && en_n) begin
      if (sec == 59) begin
        sec <= 0;
        if (min == 59) begin min <= 0; hour <= (hour == 23) ? 6'd0 : hour + 1'b1; end
        else min <= min + 1'b1;
      end else sec <= sec + 1'b1;
    end
  end

  // 1kHz 扫描，八位：HH-MM-SS
  reg [15:0] sdiv = 0;
  wire st = (sdiv == 16'd47999);
  always @(posedge clk48m) sdiv <= st ? 16'd0 : sdiv + 1'b1;

  reg [2:0] scan = 0;
  always @(posedge clk48m) if (st) scan <= scan + 1'b1;

  // 0.5s 闪烁标志
  reg [24:0] bdiv = 0;
  reg blink = 0;
  always @(posedge clk48m) begin
    if (bdiv == 25'd23_999_999) begin
      bdiv <= 0;
      blink <= ~blink;
    end else bdiv <= bdiv + 1'b1;
  end

  reg [3:0] digit;
  reg dash, off;
  always @(*) begin
    dash = 0;
    off = 0;
    case (scan)
      3'd0: digit = sec % 10;
      3'd1: digit = sec / 10;
      3'd2: begin digit = 0; dash = 1; end
      3'd3: digit = min % 10;
      3'd4: digit = min / 10;
      3'd5: begin digit = 0; dash = 1; end
      3'd6: digit = hour % 10;
      default: digit = hour / 10;
    endcase
    // 最右一位（秒个位）每 0.5 秒灭一次
    if (scan == 3'd0 && blink) off = 1;
  end

  assign dig = ~(8'h01 << scan);
  assign seg = off ? 8'b1111_1111 : (dash ? 8'b1011_1111 : decode(digit));

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
