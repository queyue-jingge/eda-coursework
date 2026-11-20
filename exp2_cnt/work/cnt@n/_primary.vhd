library verilog;
use verilog.vl_types.all;
entity cntN is
    generic(
        N               : integer := 10;
        W               : integer := 4
    );
    port(
        clk             : in     vl_logic;
        clr             : in     vl_logic;
        en              : in     vl_logic;
        q               : out    vl_logic_vector;
        carry           : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of N : constant is 1;
    attribute mti_svvh_generic_type of W : constant is 1;
end cntN;
