module tlc549(
    input clk48m,
    input adc_data,
    output reg adc_cs,
    output reg adc_clk,
    output [7:0] seg,
    output [7:0] dig
);
  // I/O_CLOCK 200kHz（周期 5us，满足 <=1.1MHz）
  reg [7:0] cdiv = 0;
  wire tick = (cdiv == 8'd239);
  always @(posedge clk48m) cdiv <= tick ? 8'd0 : cdiv + 1'b1;

  localparam IDLE = 3'd0, CSLOW = 3'd1, BITS = 3'd2, CSHIGH = 3'd3;
  reg [2:0] st = IDLE;
  reg [4:0] wait_cnt = 0;
  reg [3:0] bitcnt = 0;
  reg [7:0] sh = 0;
  reg [7:0] value = 0;

  always @(posedge clk48m) if (tick) begin
    case (st)
      IDLE: begin
        adc_cs <= 1'b1;
        adc_clk <= 1'b0;
        wait_cnt <= 0;
        st <= CSLOW;
      end
      CSLOW: begin
        adc_cs <= 1'b0;              // CS 拉低
        if (wait_cnt >= 5'd3) begin  // >=1.4us
          wait_cnt <= 0;
          bitcnt <= 0;
          st <= BITS;
        end else wait_cnt <= wait_cnt + 1'b1;
      end
      BITS: begin
        if (adc_clk == 1'b0) begin
          adc_clk <= 1'b1;
          sh <= {sh[6:0], adc_data};
        end else begin
          adc_clk <= 1'b0;
          if (bitcnt == 4'd7) st <= CSHIGH;
          else bitcnt <= bitcnt + 1'b1;
        end
      end
      CSHIGH: begin
        adc_cs <= 1'b1;
        adc_clk <= 1'b0;
        if (wait_cnt >= 5'd7) begin   // >=17us 转换
          wait_cnt <= 0;
          value <= sh;
          st <= IDLE;
        end else wait_cnt <= wait_cnt + 1'b1;
      end
      default: st <= IDLE;
    endcase
  end

  // 1kHz 扫描，三位十进制显示 0..255
  reg [15:0] sdiv = 0;
  wire st_scan = (sdiv == 16'd47999);
  always @(posedge clk48m) sdiv <= st_scan ? 16'd0 : sdiv + 1'b1;

  reg [2:0] scan = 0;
  always @(posedge clk48m) if (st_scan) scan <= (scan == 3'd2) ? 3'd0 : scan + 1'b1;

  reg [3:0] digit;
  always @(*) begin
    case (scan)
      3'd0: digit = value % 10;
      3'd1: digit = (value / 10) % 10;
      default: digit = (value / 100) % 10;
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
