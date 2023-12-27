library verilog;
use verilog.vl_types.all;
entity RW_LOGIC is
    port(
        cpu_data        : inout  vl_logic_vector(7 downto 0);
        RD              : in     vl_logic;
        WR              : in     vl_logic;
        A0              : in     vl_logic;
        CS              : in     vl_logic;
        ctrl_data       : inout  vl_logic_vector(7 downto 0);
        RW              : out    vl_logic;
        \type\          : out    vl_logic;
        nr              : out    vl_logic_vector(1 downto 0);
        rst             : out    vl_logic;
        ctrl_ready_to_write: in     vl_logic
    );
end RW_LOGIC;
