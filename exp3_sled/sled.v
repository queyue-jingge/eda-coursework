module sled(input clk48m, output [7:0] seg, output [7:0] dig);
  reg [25:0] div;
  reg [4:0] cnt;
  initial begin div = 26'd0; cnt = 5'd0; end
  always @(posedge clk48m) begin
    if (div == 26'd47_999_999) begin
      div <= 26'd0;
      if (cnt == 5'd18) cnt <= 5'd0;
      else cnt <= cnt + 1'b1;
    end else begin
      div <= div + 1'b1;
    end
  end
  assign dig = 8'h00;
  assign seg = (cnt == 5'd16) ? 8'b1000_1001 :
               (cnt == 5'd17) ? 8'b1000_1100 :
               (cnt == 5'd18) ? 8'b1111_1111 :
               decode(cnt[3:0]);
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
