library verilog;
use verilog.vl_types.all;
entity debounce16 is
    port(
        clk48m          : in     vl_logic;
        key_in          : in     vl_logic;
        key_rst         : in     vl_logic;
        seg             : out    vl_logic_vector(7 downto 0);
        dig             : out    vl_logic_vector(7 downto 0)
    );
end debounce16;
