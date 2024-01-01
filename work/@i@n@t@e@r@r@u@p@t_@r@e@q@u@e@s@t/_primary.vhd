library verilog;
use verilog.vl_types.all;
entity INTERRUPT_REQUEST is
    port(
        IRs             : in     vl_logic_vector(7 downto 0);
        edge_or_level_triggered: in     vl_logic;
        RST             : in     vl_logic;
        status          : in     vl_logic_vector(15 downto 0);
        chosen          : in     vl_logic_vector(7 downto 0);
        IMR             : in     vl_logic_vector(7 downto 0);
        ISR             : in     vl_logic_vector(7 downto 0);
        IRR             : out    vl_logic_vector(7 downto 0)
    );
end INTERRUPT_REQUEST;
