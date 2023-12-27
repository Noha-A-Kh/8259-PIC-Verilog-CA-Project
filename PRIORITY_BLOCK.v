module PRIORITY_BLOCK(
  input [7:0] IRs,
  inout WRITE,            //1 -> write to cpu
  //0 -> read from cpu
  inout [2:0] MODE,
  inout [7:0] DATA
);

  //internal wires
  reg AEOI,
  edge_or_level_triggered,
  RST = 1'b0,
  priority_mode,                              //1-> fully nested || 0->rotate
  DATA_flag,
  WRITE_flag,
  MODE_flag;


  reg [2:0] OCW2_priority,                   //command or mode from ocw2 (bits 5, 6, 7)
  //OCW2_level,                                //ir level to be acted upon
  mode_temp;

  reg [3:0] chosen_index;
  reg [7:0] chosen;                          //chosen ir level from priority resolver
  wire [7:0] IRR, ISR, IMR;
  reg [7:0] rotatedIRR;
  reg [7:0] data_temp, IMR_temp;
  reg [7:0] ISR_temp;


  reg [15:0] status = 16'b0;

  /**********************************MODULES INSTANTIAITIONS**********************************/

  MASK mask_register (.MODE(MODE), .DATA(DATA), .RST(RST), .IMR(IMR));

  INTERRUPT_REQUEST request_register (.IRs(IRs),
                                      .edge_or_level_triggered(edge_or_level_triggered),
                                      .RST(RST), .status(status),
                                      .chosen(chosen), .IMR(IMR),
                                      .ISR(ISR), .IRR(IRR));

  IN_SERVICE in_service_register (.chosen(chosen),.AEOI(AEOI), .status(status),
                                  .chosen_index(chosen_index),
                                  .OCW2_priority(OCW2_priority), 
                                  .RST(RST), .ISR(ISR));

  always @(posedge IRR)
    begin
      //send ack to control logic
      DATA_flag = 1;
      WRITE_flag = 1;
      MODE_flag = 1;
      mode_temp = 3'b110;
      data_temp = (chosen_index-1) / 2; 

    end


  always @(chosen)
    begin
      DATA_flag = 1;
      WRITE_flag = 1;
      MODE_flag = 1;
      mode_temp = 3'b110;
      data_temp = chosen; 
    end



  always @(MODE, DATA)
    begin

      DATA_flag = 0;
      WRITE_flag = 0;
      MODE_flag = 0;

      case(MODE)


        3'b000:                             //mode = IRR
          begin
            if(WRITE)
              begin
                DATA_flag = 1;
                WRITE_flag = 1;
                MODE_flag = 1;
                data_temp = IRR;            //write irr to cpu
                mode_temp = 3'b000;
              end
          end

        3'b001:                             //mode = ISR
          begin                                     
            if(WRITE) 
              begin
                DATA_flag = 1;
                WRITE_flag = 1;
                MODE_flag = 1;
                mode_temp = 3'b001;
                data_temp = ISR;             //write ISR to CPU
              end
          end

        3'b010:                              //mode = IMR
          begin
            if(WRITE)
              begin
                IMR_temp = DATA;             //read IMR from CPU
              end

          end

        3'b011:                              //mode = OCW2 (priority)
          begin
            OCW2_priority = DATA[7:5];
            //OCW2_level = DATA[2:0];
            if (OCW2_priority == 3'b101 || OCW2_priority == 3'b100)
              priority_mode = 1;   
              //Rotation mode
            else if (OCW2_priority == 3'b001 || OCW2_priority == 3'b000)
              priority_mode = 0;
              //Fully Nested mode                                       
          end

        3'b100:                                         //ICWs
          begin
            AEOI = DATA[0];                             //AEOI mode
            edge_or_level_triggered = DATA[1];          //Edge or Level triggered modes
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
                  ISR_temp = ISR_temp | chosen;
                  
                end

              2'b01:                                    //ACK1
                begin
                  if(AEOI)                              //automtaic eoi
                    begin
                      status[chosen_index] = 1'b0;
                      status[chosen_index - 1] = 1'b0;
                      ISR_temp = ISR_temp & ~chosen;

                      //send handling mode 
                      DATA_flag = 1;
                      WRITE_flag = 1;
                      MODE_flag = 1;
                      mode_temp = 3'b101;
                      data_temp = chosen; 
                    end
                  else                                   //manual eoi (waiting for eoi)
                    begin
                      status[chosen_index] = 1'b1;
                      status[chosen_index - 1] = 1'b0;
                    end
                end

              2'b10:                                    //ACK2
                begin
                  if((OCW2_priority == 3'b001 && priority_mode == 1) ||
                    //non specific eoi command + fully nested mode
                     (OCW2_priority == 101 && priority_mode == 0))
                    //rotate on non specific eoi command + rotation mode
                    begin
                      status[chosen_index] = 1'b0;
                      status[chosen_index - 1] = 1'b0;
                      ISR_temp = ISR_temp & 
                      ~chosen;
                    end
                end

              2'b11:                                    //ACK2 + EOI //reserved
                begin
                end
            endcase

          end

        3'b111:
          begin     
            RST = ~RST;                          //Toggle RESET
          end

      endcase
    end

  //always block for priority
  always @(IRR, ISR)
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
    end

  always @(negedge ISR[0], negedge ISR[1],
           negedge ISR[2], negedge ISR[3],
           negedge ISR[4], negedge ISR[5],
           negedge ISR[6], negedge ISR[7])
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



always @(RST)
  begin
      ISR_temp = 8'b0;
  end



  assign DATA = DATA_flag ? data_temp : 8'bz;
  assign WRITE = WRITE_flag ? 1'b0 : 1'bz;
  assign MODE = MODE_flag ? mode_temp : 3'bz;

  assign IMR = IMR_temp;
  assign ISR = ISR_temp;


endmodule




