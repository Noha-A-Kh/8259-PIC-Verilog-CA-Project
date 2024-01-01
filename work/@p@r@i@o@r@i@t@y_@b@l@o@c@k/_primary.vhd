library verilog;
use verilog.vl_types.all;
entity PRIORITY_BLOCK is
    port(
        IRs             : in     vl_logic_vector(7 downto 0);
        CU_MODE         : in     vl_logic_vector(2 downto 0);
        CU_DATA         : in     vl_logic_vector(7 downto 0);
        CU_WRITE        : in     vl_logic;
        PRIORITY_DATA   : out    vl_logic_vector(7 downto 0);
        PRIORITY_MODE   : out    vl_logic_vector(2 downto 0)
    );
end PRIORITY_BLOCK;
