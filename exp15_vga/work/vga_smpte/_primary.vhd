library verilog;
use verilog.vl_types.all;
entity vga_smpte is
    port(
        clk48m          : in     vl_logic;
        keya            : in     vl_logic;
        hs              : out    vl_logic;
        vs              : out    vl_logic;
        rgb             : out    vl_logic_vector(7 downto 0)
    );
end vga_smpte;
