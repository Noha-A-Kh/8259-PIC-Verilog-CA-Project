module INTERRUPT_BLOCK_tb;

  // Instantiate the INTERRUPT_BLOCK module
  reg [7:0] requests;
  reg WRITE; 
  reg [2:0] MODE;
  reg [7:0] DATA;

  wire [7:0] Requests = requests ;
  
  wire write = WRITE; 
  wire [2:0]mode =  MODE;
  wire [7:0]data =  DATA;
  
  // Instantiate the DUT
  INTERRUPT_BLOCK dut (
    .requests(Requests),
    .WRITE(write),
    .MODE(mode),
    .DATA(data)
  );

  // Clock generation
  reg clk;
  
  // Stimulus generation
  initial begin
    clk = 0;
    requests = 8'hFF; // Example value for requests
    
    // Apply different scenarios to inout ports
    #10; // Wait for a few clock cycles before changing values
    
    // Change values of inout ports
    WRITE = 1; // Example value for WRITE
    MODE = 3'b010; // Example value for MODE
    DATA = 8'h0F; // Example value for DATA
    
    #10; // Simulate for a few clock cycles

    // Add more stimuli or scenarios as needed...
  end

  always #5 clk = ~clk; // Generate a clock with 5 time units period

  // Test scenarios
  initial begin
    // Test Case 1
    requests = 8'b11001010;
    MODE = 3'b001;
    WRITE = 1;
    DATA = 8'b10101010;
    #100; // Run for 100 time units

    // Test Case 2
    requests = 8'b00010011;
    MODE = 3'b010;
    WRITE = 0;
    DATA = 8'b11001100;
    #100; // Run for 100 time units

    // Test Case 3
    requests = 8'b11111111;
    MODE = 3'b000;
    WRITE = 1;
    DATA = 8'b01010101;
    #100; // Run for 100 time units

    // Test Case 4
    requests = 8'b11000000;
    MODE = 3'b011;
    WRITE = 1;
    DATA = 8'b00110011;
    #100; // Run for 100 time units

    // Add more test cases here...

    $finish; // End simulation
  end
  initial begin
    $monitor("At time %t, WRITE = %b, MODE = %b, DATA = %b, REQUESTS = %b", $time, WRITE, MODE, DATA, requests);    // Add any additional monitoring as needed
  end

endmodule

