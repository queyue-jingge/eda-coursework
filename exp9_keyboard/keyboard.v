module keyboard(
    input clk48m,
    input [7:0] key,
    output reg buzzer,
    output [7:0] seg,
    output [7:0] dig
);
  wire high = ~key[7];              // key8 按下为低，选中高音
  reg [16:0] load;                  // 17 位计数器预置数
  reg [3:0] note;

  always @(*) begin
    load = 17'h1FFFF;               // 全 1 = 不响
    note = 4'hf;
    if (!key[0]) begin load = high ? 17'd108138 : 17'd85205; note = 4'h1; end
    else if (!key[1]) begin load = high ? 17'd110641 : 17'd90209; note = 4'h2; end
    else if (!key[2]) begin load = high ? 17'd112870 : 17'd94667; note = 4'h3; end
    else if (!key[3]) begin load = high ? 17'd113891 : 17'd96711; note = 4'h4; end
    else if (!key[4]) begin load = high ? 17'd115766 : 17'd100459; note = 4'h5; end
    else if (!key[5]) begin load = high ? 17'd117436 : 17'd103799; note = 4'h6; end
    else if (!key[6]) begin load = high ? 17'd118923 : 17'd106775; note = 4'h7; end
  end

  wire silent = (load == 17'h1FFFF);

  reg [16:0] cnt = 0;
  initial buzzer = 1'b0;

  always @(posedge clk48m) begin
    if (silent) begin
      cnt <= 17'h1FFFF;
      buzzer <= 1'b0;
    end else if (cnt >= 17'h1FFFF) begin
      cnt <= load;                  // 计满 2^17 后重装预置数
      buzzer <= ~buzzer;            // 进位翻转，1:1 方波
    end else cnt <= cnt + 1'b1;
  end

  // 两位扫描：右位显示音符，高音时左位显示 H
  reg [16:0] sdiv = 0;
  wire stick = (sdiv == 17'd23999);
  always @(posedge clk48m) sdiv <= stick ? 17'd0 : sdiv + 1'b1;
  reg flag = 0;
  always @(posedge clk48m) if (stick) flag <= ~flag;

  assign dig = (high && flag) ? 8'hfd : 8'hfe;
  reg [7:0] seg_r;
  always @(*) begin
    if (high && flag) seg_r = 8'b1000_1001;   // H
    else seg_r = decode(note);
  end
  assign seg = seg_r;

  function [7:0] decode;
    input [3:0] d;
    begin
      case (d)
        4'h1: decode = 8'b1111_1001;
        4'h2: decode = 8'b1010_0100;
        4'h3: decode = 8'b1011_0000;
        4'h4: decode = 8'b1001_1001;
        4'h5: decode = 8'b1001_0010;
        4'h6: decode = 8'b1000_0010;
        4'h7: decode = 8'b1111_1000;
        default: decode = 8'b1111_1111;
      endcase
    end
  endfunction
endmodule
