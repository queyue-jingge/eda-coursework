module modulation(
    input clk48m,
    input [1:0] mode,        // 00 ASK, 01 FSK, 10 PSK, 11 直通 m 序列
    output dac_out,
    output m_out
);
  // 码元速率约 10kHz
  reg [12:0] bdiv = 0;
  wire btick = (bdiv == 13'd4799);
  always @(posedge clk48m) bdiv <= btick ? 13'd0 : bdiv + 1'b1;

  // 8 位 m 序列
  reg [7:0] lfsr = 8'hA5;
  always @(posedge clk48m) if (btick)
    lfsr <= {lfsr[6:0], lfsr[7] ^ lfsr[5] ^ lfsr[4] ^ lfsr[3]};
  wire m = lfsr[7];
  assign m_out = m;

  // DDS 相位累加器，载波由最高位取方波
  reg [31:0] acc = 0;
  wire [31:0] fcw = m ? 32'd178956971 : 32'd89478485;   // 2MHz / 1MHz
  always @(posedge clk48m) acc <= acc + fcw;
  wire carrier = acc[31];

  assign dac_out = (mode == 2'd0) ? (carrier & m) :
                   (mode == 2'd1) ? carrier :
                   (mode == 2'd2) ? (carrier ^ m) : m;
endmodule
