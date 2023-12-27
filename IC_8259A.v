module IC_8259A(
  input _CS,A0,_INTA,_WR,_RD,_SPEN,
  input [7:0] IR,
  inout [7:0] DATA,
  inout [2:0] CAS,
  output INT
);
  /*
  icw4 needed -> 16
  sngl/cas -> 15
  lvl/edg trig -> 14
  start adress -> [13:9]
   mater/slave adress-> [8:1]
  AEOI -> 0
  */
  
  //Control unit status register
  reg [16:0] status;
  
  //Internal Wires
  
  wire i_ocw;
  wire [1:0]command_word_num;
  wire read_write_block_wr;
  wire [7:0]read_write_block_data;
  wire interrupt_block_wr;
  wire [2:0]interrupt_block_mode;
  wire [7:0]interrupt_block_data;
  wire cascade_ack;  
    
 //Read Write block instance
  RW_LOGIC my_rw_block(
  .CS(_CS),
  .I_OCW(i_ocw),
  .NUM(command_word_num),
  .WRITE(read_write_block_wr),
  .DATA(read_write_block_data)
  );
  
  //Interrupt block instance
  INTERRUPT_BLOCK my_interrupt_block(
  .WRITE(interrupt_block_wr),
  .MODE(interrupt_block_mode),
  .DATA(interrupt_block_data)
  );
  

  //Cascade block instance
  CASCAD_BLOCK my_cascad_block(
  .CASCADE(CAS),
  .SLAVE_ADRESS(status[3:1]),
  .ACK(cascade_ack),
  .SPEN(_SPEN)
  );
  
  
  always @(_CS or i_ocw or command_word_num or read_write_block_wr)
  begin
    if(_CS == 1'b0)
      begin
        if(i_ocw ==1'b0)
          begin
           case(command_word_num)
             //ocw1
             2'b00:
             begin
               //send data to interrupt block as int mask 
             end
             //ocw2
             2'b01:
             begin
               //send the whole ocw2 to the interrupt block 
             end
             //ocw3
             2'b10:
             begin
               //read the isr or irr and send it to the read write block 
             end
             default:;
           endcase
          end
        else
          begin
            case(command_word_num)
              //icw1
             2'b00:
             begin
               status[16]=read_write_block_data[0];
               status[15]=read_write_block_data[1];
               status[14]=read_write_block_data[3];
               // send new configuration to the interrupt block
             end
             //icw2
             2'b01:
             begin
                status[13:9]=read_write_block_data[7:3];
             end
             //icw3
             2'b10:
             begin
               status[8:1]=read_write_block_data[7:0]; 
             end
             //icw4
             2'b11:
             begin
               status[0]=read_write_block_data[1];
               // send new configuration to the interrupt block 
             end
           endcase
          end
      end 
  end
endmodule