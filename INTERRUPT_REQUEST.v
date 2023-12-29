module INTERRUPT_REQUEST(
  input [7:0] IRs,
  input edge_or_level_triggered,
  input RST,
  input [15:0] status,
  input [7:0] chosen,
  input [7:0] IMR,
  input [7:0] ISR,
  output [7:0] IRR
);
  
  reg [7:0] IRR_temp;
  assign IRR = (IRR_temp & (~IMR));
  
//1st pin
  always @(negedge ISR[0],
           posedge IRs[0])
  begin
    
    if(edge_or_level_triggered == 1)                  //Level Triggered
    begin      
      if (IRs[0] != 0)
        IRR_temp[0] = IRs[0];
    end
  end
  
always @(negedge ISR[1],
         posedge IRs[1])
  begin
    
    if(edge_or_level_triggered == 1)                  //Level Triggered
    begin      
      if (IRs[1] != 0)
        IRR_temp[1] = IRs[1];
    end
  end
  
always @(negedge ISR[2],
         posedge IRs[2])
  begin
    if(edge_or_level_triggered == 1)                  //Level Triggered
    begin      
      if (IRs[2] != 0)
        IRR_temp[2] = IRs[2];
    end
  end
  
  always @(negedge ISR[3],
           posedge IRs[3])
  begin
    if(edge_or_level_triggered == 1)                  //Level Triggered
    begin      
      if (IRs[3] != 0)
        IRR_temp[3] = IRs[3];
    end
  end
  
  always @(negedge ISR[4],
           posedge IRs[4])
  begin
    if(edge_or_level_triggered == 1)                  //Level Triggered
    begin      
      if (IRs[4] != 0)
        IRR_temp[4] = IRs[4];
    end
  end
  
  always @(negedge ISR[5],
           posedge IRs[5])
  begin
    if(edge_or_level_triggered == 1)                  //Level Triggered
    begin      
      if (IRs[5] != 0)
        IRR_temp[5] = IRs[5];
    end
  end
  
    always @(negedge ISR[6],
           posedge IRs[6])
  begin
    if(edge_or_level_triggered == 1)                  //Level Triggered
    begin      
      if (IRs[6] != 0)
        IRR_temp[6] = IRs[6];
    end
  end
  
    always @(negedge ISR[7],
           posedge IRs[7])
  begin
    if(edge_or_level_triggered == 1)                  //Level Triggered
    begin      
      if (IRs[7] != 0)
        IRR_temp[7] = IRs[7];
    end
  end
  
  /****************************************/
  always @(IRs)
  begin
    if (edge_or_level_triggered == 0)                  //Edge Triggered
      IRR_temp = IRs;  
  end
  
  always @(status)                                  //for reseting the sent IR
  begin                                   
      IRR_temp = IRR_temp & ~chosen;
  end
  
  always @(RST)
  begin
      IRR_temp = 8'b0;
  end
  
  
  

endmodule


