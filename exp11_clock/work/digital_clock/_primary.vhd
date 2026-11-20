library verilog;
use verilog.vl_types.all;
entity digital_clock is
    port(
        clk48m          : in     vl_logic;
        enable          : in     vl_logic;
        reset           : in     vl_logic;
        seg             : out    vl_logic_vector(7 downto 0);
        dig             : out    vl_logic_vector(7 downto 0)
    );
end digital_clock;
