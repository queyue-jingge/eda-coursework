module dled(input clk48m, input key1, output [7:0] seg, output [7:0] dig);
  reg [15:0] div;
  reg [2:0] sel;
  initial begin div = 16'd0; sel = 3'd0; end
  always @(posedge clk48m) begin
    div <= div + 1'b1;
    if (div == 16'hFFFF) sel <= sel + 1'b1;
  end
  reg k0, k1;
  always @(posedge clk48m) begin
    k0 <= key1;
    k1 <= k0;
  end
  wire blank_last = ~k1;
  reg [3:0] d;
  reg off;
  always @(*) begin
    off = 0;
    case (sel)
      3'd0: begin d = 4'h6; if (blank_last) off = 1; end
      3'd1: d = 4'h5;
      3'd2: d = 4'h4;
      3'd3: d = 4'h3;
      3'd4: d = 4'h2;
      3'd5: d = 4'h1;
      default: begin d = 4'h0; off = 1; end
    endcase
  end
  assign dig = ~(8'h01 << sel);
  assign seg = off ? 8'b1111_1111 : decode(d);
  function [7:0] decode;
    input [3:0] v;
    begin
      case (v)
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
