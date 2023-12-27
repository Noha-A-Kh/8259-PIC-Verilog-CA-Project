`timescale 1ns/1ns

module INTERRUPT_REQUEST_tb;

  // Declare signals for the testbench
  reg [7:0] tb_requests;
  reg [2:0] tb_MODE;
  reg tb_edge_or_level_triggered;
  reg [7:0] tb_chosen;
  reg tb_RST;
  wire [7:0] tb_IRR;
  
  // Instantiate the module to be tested
  INTERRUPT_REQUEST dut (
    .requests(tb_requests),
    .MODE(tb_MODE),
    .edge_or_level_triggered(tb_edge_or_level_triggered),
    .chosen(tb_chosen),
    .RST(tb_RST),
    .IRR(tb_IRR)
  );

  // Initial stimulus values
  initial begin
    // Reset initial values
    tb_requests = 8'b00000000; // Set initial requests value
    tb_MODE = 3'b000; // Set initial MODE value
    tb_edge_or_level_triggered = 0; // Set initial edge_or_level_triggered value
    tb_chosen = 8'b00000000; // Set initial chosen value
    tb_RST = 0; // No reset initially

    // Apply some test cases

    // Case 1: edge_or_level_triggered = 1, IRR = requests
    tb_edge_or_level_triggered = 1;
    tb_requests = 8'b10101010;
    #10; // Wait for a few simulation cycles

    // Case 2: edge_or_level_triggered = 0, IRR = requests
//     tb_edge_or_level_triggered = 0;
    tb_requests = 8'b11001100;
    #10; // Wait for a few simulation cycles

    // Case 3: MODE = 3'b110, IRR = IRR & ~chosen
    tb_MODE = 3'b110;
    tb_chosen = 8'b10000000;
    #10; // Wait for a few simulation cycles

    // Case 4: RST = 1, IRR = 8'b0
    tb_RST = 1;
    #10; // Wait for a few simulation cycles

    // Add more test cases if needed

    // End simulation
    $finish;
  end

  // Display outputs during simulation
  always @(tb_IRR) begin
    $display("MODE = %b, edge_or_level_triggered = %b, RST = %b, chosen = %b, requests = %b, IRR = %b", tb_MODE, tb_edge_or_level_triggered, tb_RST, tb_chosen, tb_requests, tb_IRR);
  end

endmodule

