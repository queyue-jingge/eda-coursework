module led1616(
    input clk48m,
    output reg str,
    output reg sclk,
    output reg d_out
);
  // 60kHz 状态机
  reg [9:0] div = 0;
  wire tick = (div == 10'd799);
  always @(posedge clk48m) div <= tick ? 10'd0 : div + 1'b1;

  // 4Hz 滚动：0.25 秒偏移一列
  reg [23:0] sdiv = 0;
  reg [5:0] offset = 0;
  always @(posedge clk48m) begin
    if (sdiv == 24'd11_999_999) begin
      sdiv <= 0;
      offset <= offset + 1'b1;   // 64 列自动回绕
    end else sdiv <= sdiv + 1'b1;
  end

  // 64 列字模 ROM（四字各 16 列）
  reg [15:0] rom [0:63];
  initial $readmemh("rom64.hex", rom);

  reg [3:0] col = 0;
  reg [5:0] bitc = 0;
  reg [31:0] sh;
  wire [5:0] addr = offset + {2'b00, col};
  wire [15:0] row = rom[addr];

  always @(posedge clk48m) if (tick) begin
    if (bitc == 0) begin
      str <= 1'b0;
      sclk <= 1'b0;
      sh <= {row, (16'h0001 << col)};   // 列选高有效试验
      bitc <= 6'd1;
    end else if (bitc <= 6'd32) begin
      if (!sclk) begin
        d_out <= sh[31];
        sh <= {sh[30:0], 1'b0};
        sclk <= 1'b1;
      end else begin
        sclk <= 1'b0;
        bitc <= bitc + 1'b1;
      end
    end else begin
      str <= 1'b1;     // 锁存
      bitc <= 6'd0;
      col <= col + 1'b1;
    end
  end

  initial begin
    str = 0; sclk = 0; d_out = 0;
  end
endmodule
