library verilog;
use verilog.vl_types.all;
entity led1616 is
    port(
        clk48m          : in     vl_logic;
        str             : out    vl_logic;
        sclk            : out    vl_logic;
        d_out           : out    vl_logic
    );
end led1616;
