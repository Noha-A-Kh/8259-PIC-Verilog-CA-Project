library verilog;
use verilog.vl_types.all;
entity IC_8259A is
    port(
        \_CS\           : in     vl_logic;
        A0              : in     vl_logic;
        \_INTA\         : in     vl_logic;
        \_WR\           : in     vl_logic;
        \_RD\           : in     vl_logic;
        \_SPEN\         : in     vl_logic;
        IR              : in     vl_logic_vector(7 downto 0);
        DATA            : inout  vl_logic_vector(7 downto 0);
        CAS             : inout  vl_logic_vector(2 downto 0);
        INT             : out    vl_logic
    );
end IC_8259A;
