`timescale 1ns / 1ns  // Adjust the timescale as needed

module MASK_tb;

  // Parameters
  parameter CLK_PERIOD = 10; // Clock period in time units
  
  // Signals
  reg [2:0] mode;
  reg [7:0] data;
  reg rst;
  wire [7:0] imr;
  
  // Instantiate the MASK module
  MASK m1 (
    .MODE(mode),
    .DATA(data),
    .RST(rst),
    .IMR(imr)
  );

  // Clock generation
  reg clk;
  always #((CLK_PERIOD/2)) clk = ~clk;

  // Initial block for testbench setup
  initial begin
    // Initialize signals
    mode = 3'b010;
    data = 8'hAA;
    rst = 0;
    
    // Apply reset
    #5 rst = 1;
    
    // Test scenario
    #5 data = 8'h55; // Set data
    #5 rst = 0; // De-assert reset
    #10; // Wait for a few clock cycles
    
    // Add more test scenarios as needed
    
    // Finish simulation
    #10 $finish;
  end

  // Always block for clock generation
  always #1 clk = ~clk;

  // Clock the design
  always #1 @(posedge clk) begin
    // Add any required clocked logic here
  end

  // Monitor signals
  initial begin
    $monitor("Time = %0t: mode = %b, data = %h, rst = %b, imr = %h", $time, mode, data, rst, imr);
    // Add any additional monitoring as needed
  end

endmodule
