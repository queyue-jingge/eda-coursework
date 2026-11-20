library verilog;
use verilog.vl_types.all;
entity cnt4 is
    port(
        clk             : in     vl_logic;
        clr             : in     vl_logic;
        en              : in     vl_logic;
        q               : out    vl_logic_vector(3 downto 0);
        carry           : out    vl_logic
    );
end cnt4;
