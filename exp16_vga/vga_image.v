module vga_image(
    input clk48m,
    output hs,
    output vs,
    output [7:0] rgb
);
  // 48MHz 门控出 25MHz 等效像素节拍：每 48 个时钟放行 25 个
  reg [5:0] acc = 0;
  reg en25 = 0;
  always @(posedge clk48m) begin
    if (acc + 6'd25 >= 6'd48) begin
      acc <= acc + 6'd25 - 6'd48;
      en25 <= 1'b1;
    end else begin
      acc <= acc + 6'd25;
      en25 <= 1'b0;
    end
  end

  reg [9:0] hcnt = 0;
  reg [9:0] vcnt = 0;
  always @(posedge clk48m) if (en25) begin
    if (hcnt == 10'd799) begin
      hcnt <= 10'd0;
      if (vcnt == 10'd524) vcnt <= 10'd0;
      else vcnt <= vcnt + 1'b1;
    end else hcnt <= hcnt + 1'b1;
  end

  assign hs = ~((hcnt >= 10'd656) && (hcnt <= 10'd751));
  assign vs = ~((vcnt >= 10'd490) && (vcnt <= 10'd491));
  wire active = (hcnt < 10'd640) && (vcnt < 10'd480);

  // 128x64 原图，横向 5 倍、纵向 7.5 倍
  wire [9:0] x = hcnt / 10'd5;
  wire [15:0] yv = (vcnt * 16'd64) / 16'd480;
  wire [6:0] y = yv[6:0];
  wire [13:0] addr = {y, 7'b0} + x;

  reg [13:0] addr_r = 0;
  always @(posedge clk48m) if (en25) addr_r <= addr;

  reg [7:0] rom [0:8191];
  initial $readmemh("miku64.hex", rom);

  reg [7:0] pix = 0;
  always @(posedge clk48m) if (en25) pix <= rom[addr_r];

  // 行首两个像素是流水线预取，屏蔽掉避免读到上一行末尾
  assign rgb = (active && hcnt >= 10'd2) ? pix : 8'b0000_0000;
endmodule
