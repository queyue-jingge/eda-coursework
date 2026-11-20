
module music_player(
    input clk48m,
    output reg buzzer,
    output [7:0] seg,
    output [7:0] dig
);
  reg [9:0] note_idx = 0;
  reg [15:0] rom [0:339];
  initial $readmemh("music_rom.hex", rom);
  reg [9:0] addr_r = 0;
  always @(posedge clk48m) addr_r <= note_idx;
  reg [15:0] cur = 0;
  always @(posedge clk48m) cur <= rom[addr_r];
  wire [5:0] pitch = cur[13:8];
  wire [7:0] dur = cur[7:0];
  reg [31:0] div_target;
  always @(*) begin
    case (pitch)
      6'd0: div_target = 32'd0;
      6'd1: div_target = 32'd72928;
      6'd2: div_target = 32'd68836;
      6'd3: div_target = 32'd64979;
      6'd4: div_target = 32'd61339;
      6'd5: div_target = 32'd57901;
      6'd6: div_target = 32'd54658;
      6'd7: div_target = 32'd51594;
      6'd8: div_target = 32'd48695;
      6'd9: div_target = 32'd45964;
      6'd10: div_target = 32'd43387;
      6'd11: div_target = 32'd40955;
      6'd12: div_target = 32'd38657;
      6'd13: div_target = 32'd36487;
      6'd14: div_target = 32'd34438;
      6'd15: div_target = 32'd32506;
      6'd16: div_target = 32'd30685;
      6'd17: div_target = 32'd28964;
      6'd18: div_target = 32'd27340;
      6'd19: div_target = 32'd25808;
      6'd20: div_target = 32'd24361;
      6'd21: div_target = 32'd22995;
      6'd22: div_target = 32'd21706;
      6'd23: div_target = 32'd20490;
      6'd24: div_target = 32'd19342;
      6'd25: div_target = 32'd18257;
      6'd26: div_target = 32'd17233;
      6'd27: div_target = 32'd16266;
      6'd28: div_target = 32'd15354;
      6'd29: div_target = 32'd14494;
      6'd30: div_target = 32'd13682;
      6'd31: div_target = 32'd12916;
      6'd32: div_target = 32'd12192;
      6'd33: div_target = 32'd11509;
      6'd34: div_target = 32'd10864;
      6'd35: div_target = 32'd10253;
      default: div_target = 32'd9679;
    endcase
  end
  reg [31:0] cnt = 0;
  always @(posedge clk48m) begin
    if (div_target == 0) begin
      cnt <= 0;
      buzzer <= 1'b0;
    end else if (cnt >= div_target - 1) begin
      cnt <= 0;
      buzzer <= ~buzzer;
    end else cnt <= cnt + 1'b1;
  end
  localparam DUR16 = 32'd5_217_384;
  reg [31:0] dur_cnt = 0;
  always @(posedge clk48m) begin
    if (dur_cnt >= DUR16 * dur - 1) begin
      dur_cnt <= 0;
      if (note_idx == 10'd339) note_idx <= 0;
      else note_idx <= note_idx + 1'b1;
    end else dur_cnt <= dur_cnt + 1'b1;
  end
  reg [9:0] sdiv = 0;
  wire stick = (sdiv == 10'd479);
  always @(posedge clk48m) sdiv <= stick ? 10'd0 : sdiv + 1'b1;
  reg flag = 0;
  always @(posedge clk48m) if (stick) flag <= ~flag;
  wire [5:0] pv = pitch;
  assign dig = flag ? 8'hfd : 8'hfe;
  assign seg = decode(flag ? (pv / 10) : (pv % 10));
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
    dur_cnt = 0;
    buzzer = 0;
  end
endmodule
