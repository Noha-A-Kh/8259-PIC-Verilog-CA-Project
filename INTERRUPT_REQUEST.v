module INTERRUPT_REQUEST(
  input [7:0] requests,
  input [2:0] MODE,
  input edge_or_level_triggered,
  input [7:0] chosen,
  input RST,
  output [7:0] IRR
);

  reg [7:0] IRR_temp;

  always @(requests)
  begin
    if(edge_or_level_triggered == 1'b1)  //level triggered
    begin
    IRR_temp = requests;
    end
  end
  
  always @(posedge requests)
  begin
    if(edge_or_level_triggered == 1'b0)  //edge triggered
    begin 
      IRR_temp = requests;
    end
  end
  
  always @(chosen, MODE)
  begin
    if (MODE == 3'b110)
      IRR_temp = IRR_temp & ~chosen;
  end
  
  always @(*)
  begin
    if (RST)
      IRR_temp = 8'b0;
  end
  
  assign IRR = IRR_temp;


endmodule

