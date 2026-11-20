module tlc5620(
    input clk48m,
    output reg dac_load,
    output reg dac_clk,
    output reg dac_data,
    output dac_ldac
);
  assign dac_ldac = 1'b0;   // 一直允许更新

  // 状态机 2MHz，DA_CLK 由状态机翻转得到 1MHz（TLC5620 上限 1MHz）
  reg [5:0] cdiv = 0;
  wire tick = (cdiv == 6'd23);
  always @(posedge clk48m) cdiv <= tick ? 6'd0 : cdiv + 1'b1;

  // 64 点正弦，1kHz 输出 -> 64k 点/秒，48M/64k = 750
  reg [9:0] sdiv = 0;
  wire stick = (sdiv == 10'd749);
  always @(posedge clk48m) sdiv <= stick ? 10'd0 : sdiv + 1'b1;

  reg [5:0] addr = 0;
  always @(posedge clk48m) if (stick) addr <= addr + 1'b1;

  reg [7:0] sine [0:63];
  initial $readmemh("sine64.hex", sine);
  wire [7:0] dval = sine[addr];

  // 11 位帧：通道 00 + RNG 0 + 8 位数据
  localparam S_IDLE = 3'd0, S_SHIFT = 3'd1, S_LOW = 3'd2, S_GAP = 3'd3, S_WAIT = 3'd4;
  reg [2:0] st = S_IDLE;
  reg [3:0] bitcnt = 0;
  reg [10:0] frame;
  reg [2:0] waitc = 0;

  always @(posedge clk48m) if (tick) begin
    case (st)
      S_IDLE: begin
        dac_load <= 1'b1;
        dac_clk <= 1'b0;
        frame <= {2'b00, 1'b0, dval};
        bitcnt <= 4'd10;
        st <= S_SHIFT;
      end
      S_SHIFT: begin
        dac_clk <= 1'b1;              // 上升沿放数据
        dac_data <= frame[10];
        frame <= {frame[9:0], 1'b0};
        st <= S_LOW;
      end
      S_LOW: begin
        dac_clk <= 1'b0;              // 下降沿 DAC 锁存
        if (bitcnt == 0) begin
          waitc <= 0;
          st <= S_GAP;                // 最后一个下降沿后再等 >=50ns
        end else begin
          bitcnt <= bitcnt - 1'b1;
          st <= S_SHIFT;
        end
      end
      S_GAP: begin
        if (waitc >= 3'd3) begin       // 3us
          dac_load <= 1'b0;            // 低电平锁存 >=250ns
          waitc <= 0;
          st <= S_WAIT;
        end else waitc <= waitc + 1'b1;
      end
      S_WAIT: begin
        if (waitc >= 3'd7) begin       // 7us
          dac_load <= 1'b1;
          st <= S_IDLE;
        end else waitc <= waitc + 1'b1;
      end
      default: st <= S_IDLE;
    endcase
  end

  initial begin
    dac_load = 1'b1;
    dac_clk = 1'b0;
    dac_data = 1'b0;
  end
endmodule
