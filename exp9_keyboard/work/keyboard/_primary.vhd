library verilog;
use verilog.vl_types.all;
entity keyboard is
    port(
        clk48m          : in     vl_logic;
        key             : in     vl_logic_vector(7 downto 0);
        buzzer          : out    vl_logic;
        seg             : out    vl_logic_vector(7 downto 0);
        dig             : out    vl_logic_vector(7 downto 0)
    );
end keyboard;
