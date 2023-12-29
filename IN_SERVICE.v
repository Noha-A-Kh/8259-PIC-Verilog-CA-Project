module IN_SERVICE(
  input [7:0] chosen,
  input [2:0] MODE,
  input AEOI,
  input [2:0] OCW2_priority,
  input RST,
  output [7:0] ISR
  );
  
  reg [7:0] ISR_temp;
  
//   initial
//   begin
//     ISR = 8'b0;
//   end

  always @(*)
  begin
    if (MODE == 3'b110)                   //first ack (ACK)
      ISR_temp = ISR_temp | chosen;                 //set
      
    else if (MODE == 3'b101)              //second ack (HANDLING)
    begin
      if(AEOI)                            //Automatic eoi mode
        begin
          ISR_temp = ISR_temp & ~chosen;            //reset  
        end
      else                                //manual eoi mode
        begin
          if (OCW2_priority == 3'b001 || OCW2_priority == 3'b101)   //check for eoi command
            ISR_temp = ISR_temp & ~chosen;          //reset 
        end
      end
  end
  
  always @(RST)
  begin
    if (RST)
      ISR_temp = 8'b0;
  end
  
  assign ISR = ISR_temp;
  
  
endmodule
  
  
