module INTERRUPT_BLOCK(
  input [7:0] requests,
  inout WRITE,            //1 -> write to cpu
                          //0 -> read from cpu
  inout [2:0] MODE,
  inout [7:0] DATA
  );
  
  //internal wires
  reg AEOI,
      edge_or_level_triggered,
      RST,
      priority_mode,                         //1-> fully nested || 0->rotate
      write_temp;
  reg [2:0] OCW2_priority,                   //command or mode from ocw2 (bits 5, 6, 7)
            OCW2_level,                      //ir level to be acted upon
            mode_temp;
  reg [7:0] chosen;                          //chosen ir level from priority resolver
  wire [7:0] IRR, ISR, IMR;
  reg [7:0] maskedIRR, rotatedMaskedIRR;
  reg [7:0] data_temp, IMR_temp;
  
  MASK mask_register (.MODE(MODE), .DATA(DATA), .RST(RST), .IMR(IMR));
  INTERRUPT_REQUEST request_register (.requests(requests),
                                      .edge_or_level_triggered(edge_or_level_triggered),
                                      .chosen(chosen), .RST(RST), .IRR(IRR));
  IN_SERVICE in_service_register (.chosen(chosen), .MODE(MODE),.AEOI(AEOI),
                                  .OCW2_priority(OCW2_priority), .RST(RST), .ISR(ISR));

  always @(IRR, IMR)
  begin
    rotatedMaskedIRR = IRR & ~IMR; 
  end
  
  always @(chosen)
  begin
    mode_temp = 3'b011;
    write_temp = 0;
    data_temp = chosen; 
  end
  

                                  
  always @(*)
  begin
    
    case(MODE)
      
      
      3'b000:                            //mode = IRR
      begin
        if(WRITE) data_temp = IRR;       //write irr to cpu
        //else IRR = DATA;            //read irr from cpu
      end
      
      3'b001:                            //mode = ISR
      begin                                     
        if(WRITE) data_temp = ISR;       //write ISR to CPU
        //else ISR = DATA;                //read ISR from CPU
      end
      
      3'b010:                            //mode = IMR
      begin
        if(WRITE) data_temp = IMR;       //write IMR to CPU
        else IMR_temp = DATA;                 //read IMR from CPU
      end
      
      3'b011:                             //mode = OCW2 (priority)
      begin
        OCW2_priority = DATA[7:5];
        OCW2_level = DATA[2:0];
        if (OCW2_priority == 3'b101 || OCW2_priority == 3'b100)
          priority_mode = 1;                                      //Rotation mode
        else if (OCW2_priority == 3'b001 || OCW2_priority == 3'b000)
          priority_mode = 0;                                       //Fully Nested mode
      end
      
      3'b100:                             //ICWs
      begin
        AEOI = DATA[0];                   //AEOI mode
        edge_or_level_triggered = DATA[1];//Edge or Level triggered modes
      end
      
      3'b101:                             //handling (second INTA)
      begin
        data_temp = chosen;
      end
      
      3'b110:                             //ack (first INTA)
      ;
      
      3'b111:
      begin     
        RST = 1;                          //RESET
      end
      
    endcase
  end
  
  //always block for priority
  always @(IRR, ISR, priority_mode)
  begin
    case(priority_mode)
      
      1'b1:                               //Fully Nested mode
      begin
        maskedIRR = IRR & ~IMR;
        if (maskedIRR[0] == 1)
          chosen = chosen & 1;
        else if (maskedIRR[1] == 1)
          chosen = chosen & 2;
        else if (maskedIRR[2] == 1)
          chosen = chosen & 4;
        else if (maskedIRR[3] == 1)
          chosen = chosen & 8;
        else if (maskedIRR[4] == 1)
          chosen = chosen & 16;
        else if (maskedIRR[5] == 1)
          chosen = chosen & 32;
        else if (maskedIRR[6] == 1)
          chosen = chosen & 64;
        else if (maskedIRR[7] == 1)
          chosen = chosen & 128;
        end
        
        1'b0:                               //Rotation mode
        begin
          if (rotatedMaskedIRR[0] == 1)
          begin
            chosen = chosen & 1;
            rotatedMaskedIRR = IRR>>1 | IRR<<7;
          end
          else if (rotatedMaskedIRR[1] == 1)
          begin
            chosen = chosen & 2;
            rotatedMaskedIRR = IRR>>2 | IRR<<6;
          end
          else if (rotatedMaskedIRR[2] == 1)
          begin
            chosen = chosen & 4;
            rotatedMaskedIRR = IRR>>3 | IRR<<5;
          end
          else if (rotatedMaskedIRR[3] == 1)
          begin
            chosen = chosen & 8;
            rotatedMaskedIRR = IRR>>4 | IRR<<4;
          end
          else if (rotatedMaskedIRR[4] == 1)
          begin
            chosen = chosen & 16;
            rotatedMaskedIRR = IRR>>5 | IRR<<3;
          end
          else if (rotatedMaskedIRR[5] == 1)
          begin
            chosen = chosen & 32;
            rotatedMaskedIRR = IRR>>6 | IRR<<2;
          end
          else if (rotatedMaskedIRR[6] == 1)
          begin
            chosen = chosen & 64;
            rotatedMaskedIRR = IRR>>7 | IRR<<1;
          end
          else if (rotatedMaskedIRR[7] == 1)
          begin
            chosen = chosen & 128;
            rotatedMaskedIRR = IRR;
          end
        end
    endcase
  end
          
    assign DATA = data_temp;
    assign MODE = mode_temp;
    assign WRITE = write_temp;
    
    assign IMR = IMR_temp;


endmodule
                                      
