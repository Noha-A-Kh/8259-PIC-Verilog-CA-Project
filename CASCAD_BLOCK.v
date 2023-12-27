module CASCADE_BLOCK (
  input wire [2:0] SLAVE_ADRESS,  // Input wire for slave ID
  input wire SPEN,           // Input wire for slave enable signal
  output reg ACK,              // Output register for acknowledgment
  inout [2:0] CASCADE     // Inout wire for the cascaded bus
);

  reg [2:0] slave_chosen;      //Register to store the chosen slave ID

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
    
    // Check if in MASTER mode
    if (SPEN == 1) begin
      slave_chosen = SLAVE_ADRESS;  // Store the chosen slave ID
    end  
  end

  // Assign CASCADE based on the mode
  assign CASCADE = (SPEN == 1) ? slave_chosen : 3'bZ; 
endmodule
