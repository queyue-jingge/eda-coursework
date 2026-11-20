library verilog;
use verilog.vl_types.all;
entity h_adder is
    port(
        a               : in     vl_logic;
        b               : in     vl_logic;
        so              : out    vl_logic;
        co              : out    vl_logic
    );
end h_adder;
