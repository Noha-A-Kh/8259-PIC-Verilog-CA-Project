`timescale 1ns / 1ps
module tb_cascade_block();
  reg [2:0] SLAVE_ADRESS;  // Testbench input: slave ID
  reg SPEN;               // Testbench input: slave enable signal
  wire ACK;               // Testbench output: acknowledgment
  reg flag=0;
  reg[2:0]Cas_reg;
  wire [2:0] CASCADE;      // Testbench inout: cascaded bus

  // Instantiate the module
  CASCADE_BLOCK cascade_block_inst (
    .SLAVE_ADRESS(SLAVE_ADRESS),
    .SPEN(SPEN),
    .ACK(ACK),
    .CASCADE(CASCADE)
  );
 assign CASCADE=flag?Cas_reg:3'bzzz;
  // Initializations
  initial begin
    // Test scenario 1: SLAVE mode, matching ID
    SLAVE_ADRESS = 3'b010;  // Set slave ID
    SPEN = 0;               // Enable SLAVE mode
    flag=1;
    Cas_reg = 3'b010;       // Set CASCADE
    #10 $display("Test 1: SLAVE mode, Matching ID -> ACK = %b", ACK);

    // Test scenario 2: SLAVE mode, non-matching ID
    SLAVE_ADRESS = 3'b001;  // Set different slave ID
    SPEN = 0;               // Enable SLAVE mode
    #10 $display("Test 2: SLAVE mode, Non-matching ID -> ACK = %b", ACK);

    // Test scenario 3: MASTER mode, choosing a slave
    flag=0;
    SLAVE_ADRESS = 3'b111;  // Set chosen slave ID
    SPEN = 1;               // Enable MASTER mode
    #10 $display("Test 3: MASTER mode, Choosing a slave -> ACK = %b", CASCADE);

    #10 ; // Finish simulation
  end

 
endmodule
