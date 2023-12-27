`timescale 1ns/1ns

module IN_SERVICE_tb;

  // Declare signals for the testbench
  reg [7:0] tb_chosen;
  reg [2:0] tb_MODE;
  reg tb_AEOI;
  reg [2:0] tb_OCW2_priority;
  reg tb_RST;
  wire [7:0] tb_ISR;
  
  // Instantiate the module to be tested
  IN_SERVICE dut (
    .chosen(tb_chosen),
    .MODE(tb_MODE),
    .AEOI(tb_AEOI),
    .OCW2_priority(tb_OCW2_priority),
    .RST(tb_RST),
    .ISR(tb_ISR)
  );

  // Initial stimulus values
  initial begin
    // Reset initial values
    tb_chosen = 8'b00000000; // Set initial chosen value
    tb_MODE = 3'b000; // Set initial MODE value
    tb_AEOI = 0; // Set initial AEOI value
    tb_OCW2_priority = 3'b000; // Set initial OCW2_priority value
    tb_RST = 0; // No reset initially

    // Apply some test cases

    // Case 1: MODE = 3'b110, ISR = ISR | chosen
    tb_MODE = 3'b110;
    tb_chosen = 8'b10101010;
    #10; // Wait for a few simulation cycles

    // Case 2: MODE = 3'b101, AEOI = 1, ISR = ISR & ~chosen
    tb_MODE = 3'b101;
    tb_AEOI = 1;
    tb_chosen = 8'b01010101;
    #10; // Wait for a few simulation cycles
    
    // Case 3: MODE = 3'b101, AEOI = 0, OCW2_priority = 3'b101, ISR = ISR & ~chosen
    tb_MODE = 3'b101;
    tb_AEOI = 0;
    tb_OCW2_priority = 3'b000;
    tb_chosen = 8'b11111111;
    #10; // Wait for a few simulation cycles

    // Case 4: MODE = 3'b101, AEOI = 0, OCW2_priority = 3'b001, ISR = ISR & ~chosen
    tb_MODE = 3'b101;
    tb_AEOI = 0;
    tb_OCW2_priority = 3'b001;
    tb_chosen = 8'b11001100;
    #10; // Wait for a few simulation cycles

    // Case 5: MODE = 3'b101, AEOI = 0, OCW2_priority = 3'b101, ISR = ISR & ~chosen
    tb_MODE = 3'b101;
    tb_AEOI = 0;
    tb_OCW2_priority = 3'b101;
    tb_chosen = 8'b00100000;
    #10; // Wait for a few simulation cycles

    // Case 6: RST = 1, ISR = 8'b0
    tb_RST = 1;
    #10; // Wait for a few simulation cycles

    // Add more test cases if needed

    // End simulation
    $finish;
  end

  // Display outputs during simulation
  always @(tb_ISR) begin
    $display("MODE = %b, AEOI = %b, OCW2_priority = %b, RST = %b, chosen = %b, ISR = %b", tb_MODE, tb_AEOI, tb_OCW2_priority, tb_RST, tb_chosen, tb_ISR);
  end

endmodule


