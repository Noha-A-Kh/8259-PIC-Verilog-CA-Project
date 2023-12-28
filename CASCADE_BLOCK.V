module CASCADE_BLOCK (
  input wire [2:0] SLAVE_ADRESS,  // Input wire for slave ID
  input wire SPEN,                // Input wire for slave enable signal
  output reg ACK,                  // Output register for acknowledgment
  inout wire [2:0] CASCADE          // Inout wire for the cascaded bus
);

  reg [2:0] slave_chosen;      // Register to store the chosen slave ID

  always @* begin
    // Check if in SLAVE mode and if the ID matches CAS
    if (SPEN == 0) begin
      if (SLAVE_ADRESS == CASCADE) begin 
        ACK = 1'b1;  
      end
      else begin
        ACK = 1'b0;  
      end
    end
  end
  
  // Assign CASCADE based on the mode
assign CASCADE=SPEN?SLAVE_ADRESS:3'bzzz;
endmodule