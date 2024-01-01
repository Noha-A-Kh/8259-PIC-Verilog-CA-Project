library verilog;
use verilog.vl_types.all;
entity CASCAD_BLOCK is
    port(
        SLAVE_ADRESS    : in     vl_logic_vector(2 downto 0);
        SPEN            : in     vl_logic;
        ACK             : out    vl_logic;
        CASCADE         : inout  vl_logic_vector(2 downto 0)
    );
end CASCAD_BLOCK;
