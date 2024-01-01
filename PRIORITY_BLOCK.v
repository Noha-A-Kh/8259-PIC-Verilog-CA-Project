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
  
  reg [7:0] IRR_temp = 8'b0;
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
  
  /******/
  always @(posedge IRs[0])
  begin
    if (edge_or_level_triggered == 0)                  //Edge Triggered
      IRR_temp[0] = IRR_temp[0] | IRs[0];  
  end
  
    always @(posedge IRs[1])
  begin
    if (edge_or_level_triggered == 0)                  //Edge Triggered
      IRR_temp[1] = IRR_temp[1] | IRs[1];  
  end
  
  
    always @(posedge IRs[2])
  begin
    if (edge_or_level_triggered == 0)                  //Edge Triggered
      IRR_temp[2] = IRR_temp[2] | IRs[2];  
  end
  
  
    always @(posedge IRs[3])
  begin
    if (edge_or_level_triggered == 0)                  //Edge Triggered
      IRR_temp[3] = IRR_temp[3] | IRs[3];  
  end
  
  
    always @(posedge IRs[4])
  begin
    if (edge_or_level_triggered == 0)                  //Edge Triggered
      IRR_temp[4] = IRR_temp[4] | IRs[4];  
  end
  
    always @(posedge IRs[5])
  begin
    if (edge_or_level_triggered == 0)                  //Edge Triggered
      IRR_temp[5] = IRR_temp[5] | IRs[5];  
  end
  
    always @(posedge IRs[6])
  begin
    if (edge_or_level_triggered == 0)                  //Edge Triggered
      IRR_temp[6] = IRR_temp[6] | IRs[6];  
  end
  
  always @(posedge IRs[7])
  begin
    if (edge_or_level_triggered == 0)                  //Edge Triggered
      IRR_temp[7] = IRR_temp[7] | IRs[7];  
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


module PRIORITY_BLOCK(
  input [7:0] IRs,

  input [2:0] CU_MODE,
  input [7:0] CU_DATA,
  input CU_WRITE,
  
  output[7:0] PRIORITY_DATA,
  output[2:0] PRIORITY_MODE
);

  //internal wires
  reg AEOI,
  edge_or_level_triggered,
  RST,
  priority_mode = 1;
                                //1-> fully nested || 0->rotate  


  reg EOICommand;                    //command or mode from ocw2 (bits 5, 6, 7)                              //ir level to be acted upon
  reg [3:0] chosen_index;
  reg [7:0] chosen;                  //chosen ir level from priority resolver
  wire [7:0] IRR;
  reg [7:0] rotatedIRR;
  reg [7:0] IMR = 8'b0;
  reg [7:0] ISR = 8'b0;


  reg [15:0] status = 16'b0;
  
  reg [7:0] data = 8'b0;
  reg [2:0] mode = 3'b0;
  
  assign PRIORITY_DATA = data;
  assign PRIORITY_MODE = mode;
  
  //
  /**MODULES INSTANTIAITIONS**/


  INTERRUPT_REQUEST request_register (.IRs(IRs),
                                      .edge_or_level_triggered(edge_or_level_triggered),
                                      .RST(RST), .status(status),
                                      .chosen(chosen), .IMR(IMR),
                                      .ISR(ISR), .IRR(IRR));



  


/*  always @(chosen)
    begin
      mode = 3'b110;
      data = (chosen_index-1) /2; 
    end*/
    


always @(posedge EOICommand)
begin
  if(status[chosen_index] == 1 && status[chosen_index-1] == 0)
  begin
  status[chosen_index] = 1'b0;
  status[chosen_index - 1] = 1'b0;
  ISR = ISR & ~chosen;
 // EOICommand = 0;
  end
end

  always @(CU_MODE, CU_DATA, CU_WRITE)
    begin
      EOICommand = 0;
      case(CU_MODE)


        3'b000:                             //mode = IRR
          begin
                data = IRR;            //write irr to cpu
                mode = 3'b000;
          end

        3'b001:                             //mode = ISR
          begin                                     

                mode = 3'b001;
                data = ISR;             //write ISR to CPU
          end

        3'b010:                              //mode = IMR
          begin
                IMR = CU_DATA;             //read IMR from CPU
          end

        3'b011:                              //mode = OCW2 (priority)
          begin

          if(CU_DATA[7] == 1)
            begin 
              priority_mode = 0;
            end  
            else if(CU_DATA[7] ==0)
            begin 
              priority_mode = 1;
            end
            if(CU_DATA[5] == 1)
            begin
              EOICommand = 1;
            end                            
          end
        3'b100:                                         //ICWs
          begin
            ISR = 8'b0;
            IMR = 8'b0;
            status = 16'b0;
            data = 8'b0;
            mode = 3'b0;
            AEOI = CU_DATA[0];                             //AEOI mode
            edge_or_level_triggered = CU_DATA[1];    
               //Edge or Level triggered modes
                 
            
          end

        3'b101:                                         //handling (reserved for sending)
          begin
          end 

        3'b110:                                         //ACKNOWLEDGE (INTA)
          begin

              
            case({status[chosen_index], status[chosen_index-1]})
              2'b00:                                    //interrupt offline
                begin
                  status[chosen_index] = 1'b0;
                  status[chosen_index - 1] = 1'b1;
                  ISR = ISR | chosen;        
                end
              2'b01:                                    //ACK1
                begin
                      //send handling mode 
                      mode = 3'b101;
                      data = (chosen_index-1) / 2; 
                  if(AEOI)                              //automtaic eoi
                    begin
                      ISR = ISR & ~chosen;
                      status[chosen_index] = 1'b0;
                      status[chosen_index - 1] = 1'b0;
                    end
                  else                                   //manual eoi (waiting for eoi)
                    begin
                      status[chosen_index] = 1'b1;
                      status[chosen_index - 1] = 1'b0;
                    end
                end

              2'b10:                                    //ACK2 and waiting for end of interrupt
                begin
                    begin
                    end
                end

              2'b11:                                    //reserved
                begin
                end
            endcase
          end

        3'b111:
          begin     
              RST = ~RST;
                          //Toggle RESET
          end

      endcase
    end
/*always @(posedge ISR[0], posedge ISR[1],
           posedge ISR[2], posedge ISR[3],
           posedge ISR[4], posedge ISR[5],
           posedge ISR[6], posedge ISR[7])
begin
  EOICommand = 0;
end*/
  //always block for priority
  always @( IRR, ISR,posedge EOICommand)
    begin
      if(priority_mode == 1)              //Fully Nested mode
        begin

          if (IRR[0] == 1 | ISR[0] == 1)
            begin
              chosen = 1;
              chosen_index = (0 * 2) + 1;
            end
          else if (IRR[1] == 1 | ISR[1] == 1)
            begin
              chosen = 2;
              chosen_index = (1 * 2) + 1;
            end
          else if (IRR[2] == 1 | ISR[2] == 1)
            begin
              chosen = 4;
              chosen_index = (2 * 2) + 1;
            end
          else if (IRR[3] == 1 | ISR[3] == 1)
            begin
              chosen = 8;
              chosen_index = (3 * 2) + 1;
            end
          else if (IRR[4] == 1 | ISR[4] == 1)
            begin
              chosen = 16;
              chosen_index = (4 * 2) + 1;
            end
          else if (IRR[5] == 1 | ISR[5] == 1)
            begin
              chosen = 32;
              chosen_index = (5 * 2) + 1;
            end
          else if (IRR[6] == 1 | ISR[6] == 1)
            begin
              chosen = 64;
              chosen_index = (6 * 2) + 1;
            end
          else if (IRR[7] == 1 | ISR[7] == 1)
            begin
              chosen = 128;
              chosen_index = (7 * 2) + 1;
            end
        end
      else
        begin 
          if (rotatedIRR[0] == 1)
            begin
              chosen = 1;
              chosen_index = (0 * 2) + 1;
            end
          else if (rotatedIRR[1] == 1)
            begin
              chosen = 2;
              chosen_index = (1 * 2) + 1;
            end
          else if (rotatedIRR[2] == 1)
            begin
              chosen = 4;
              chosen_index = (2 * 2) + 1;            
            end
          else if (rotatedIRR[3] == 1)
            begin
              chosen = 8;
              chosen_index = (3 * 2) + 1;             
            end
          else if (rotatedIRR[4] == 1)
            begin
              chosen = 16;
              chosen_index = (4 * 2) + 1;
            end
          else if (rotatedIRR[5] == 1)
            begin
              chosen = 32;
              chosen_index = (5 * 2) + 1;
            end
          else if (rotatedIRR[6] == 1)
            begin
              chosen = 64;
              chosen_index = (6 * 2) + 1;              
            end
          else if (rotatedIRR[7] == 1)
            begin
              chosen = 128;
              chosen_index = (7 * 2) + 1;
            end
        end
    end

  always @(negedge ISR[0], negedge ISR[1],
           negedge ISR[2], negedge ISR[3],
           negedge ISR[4], negedge ISR[5],
           negedge ISR[6], negedge ISR[7],posedge EOICommand)
    begin
      if (priority_mode == 0)                         //Rotation mode
        begin
          if (rotatedIRR[0] == 1)
            begin
              chosen = 1;
              chosen_index = (0 * 2) + 1;
              rotatedIRR = IRR>>1 | IRR<<7;
            end
          else if (rotatedIRR[1] == 1)
            begin
              chosen = 2;
              chosen_index = (1 * 2) + 1;
              rotatedIRR = IRR>>2 | IRR<<6;
            end
          else if (rotatedIRR[2] == 1)
            begin
              chosen = 4;
              chosen_index = (2 * 2) + 1;
              rotatedIRR = IRR>>3 | IRR<<5;
            end
          else if (rotatedIRR[3] == 1)
            begin
              chosen = 8;
              chosen_index = (3 * 2) + 1;
              rotatedIRR = IRR>>4 | IRR<<4;
            end
          else if (rotatedIRR[4] == 1)
            begin
              chosen = 16;
              chosen_index = (4 * 2) + 1;
              rotatedIRR = IRR>>5 | IRR<<3;
            end
          else if (rotatedIRR[5] == 1)
            begin
              chosen = 32;
              chosen_index = (5 * 2) + 1;
              rotatedIRR = IRR>>6 | IRR<<2;
            end
          else if (rotatedIRR[6] == 1)
            begin
              chosen = 64;
              chosen_index = (6 * 2) + 1;
              rotatedIRR = IRR>>7 | IRR<<1;
            end
          else if (rotatedIRR[7] == 1)
            begin
              chosen = 128;
              chosen_index = (7 * 2) + 1;
              rotatedIRR = IRR;
            end
        end
    end
     always @(posedge IRR[0],
           posedge IRR[1],
           posedge IRR[2],
           posedge IRR[3],
           posedge IRR[4],
           posedge IRR[5],
           posedge IRR[6],
           posedge IRR[7])
    begin
      mode= 3'b110;
      data = (chosen_index - 1) / 2; 

    end
 
endmodule
