module IC_8259A(
  input _CS,A0,_INTA,_WR,_RD,_SPEN,
  input [7:0] IR,
  inout [7:0] DATA,
  inout [2:0] CAS,
  output reg INT
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
  
  //Internal Wires0
  
  wire i_ocw;
  wire [1:0]command_word_num;
  wire read_write_block_wr;
  
  wire [7:0]read_write_block_data;
  reg   [7:0]cbu_read_write_block_data;
 
  reg [2:0]interrupt_block_mode;
  reg [7:0]interrupt_block_data=0;
  wire [2:0]interrupt_PRIORITY_block_mode;
  wire [7:0]interrupt_PRIORITY_block_data;
  reg CU_WRITE=0;
  reg [7:0]temp_int;
  wire cascade_ack;  
  reg [2:0] SLAVE_ADRESS;
  
 //Read Write block instance
  RW_LOGIC my_rw_block(
  .cpu_data(DATA),//io
  .RD(_RD),//i
  .WR(_WR),//i
  .A0(A0),//i
  .CS(_CS),//i
  .data_to_ctrl(read_write_block_data),//io
  .data_from_ctrl(cbu_read_write_block_data),
  .type(i_ocw),//o
  .nr(command_word_num),
  .dummy(read_write_block_wr)//o
  );
  
  
  //Interrupt block instance
  PRIORITY_BLOCK my_interrupt_block(
  .IRs(IR),//i
  .CU_MODE(interrupt_block_mode),//io
  .CU_DATA(interrupt_block_data),//io
  .CU_WRITE(CU_WRITE),
   .PRIORITY_DATA(interrupt_PRIORITY_block_data),//io
  .PRIORITY_MODE(interrupt_PRIORITY_block_mode)//io
  );
  

  //Cascade block instance
  CASCAD_BLOCK my_cascad_block(
  .CASCADE(CAS),//io
  .SLAVE_ADRESS(SLAVE_ADRESS),//i
  .ACK(cascade_ack),//o
  .SPEN(_SPEN)//i
  );
  
  always @(negedge _INTA)
  begin //add slave or master
   if(status[15]==1)//single
   begin
     CU_WRITE= CU_WRITE^1;
      interrupt_block_mode=3'b110;
      INT=1'b0;
   end
   else if(status[15]==1'b0)//cascade
   begin
     if(_SPEN==1'b1)//master
     begin
       if(status[temp_int+1]==1'b0)
       begin 
         CU_WRITE= CU_WRITE^1;
         interrupt_block_mode=3'b110;
         INT=1'b0;
       end
      else
       begin
         SLAVE_ADRESS[2:0]=temp_int;
         INT=1'b0;
       end
     end
     else
     begin
       INT=1'b0;
       if(cascade_ack == 1'b1)
         begin
           CU_WRITE= CU_WRITE^1;
           interrupt_block_mode=3'b110;
           
         end
     end
   end
  end
  
  always @( interrupt_PRIORITY_block_mode , interrupt_PRIORITY_block_data)
  begin
  if(_CS == 1'b0 )
      begin
        case(interrupt_PRIORITY_block_mode)
          3'b000://IRR
             begin
               //write IRR to rwblock
               cbu_read_write_block_data=interrupt_PRIORITY_block_data;
             end
             3'b001://ISR
             begin
             //write ISR to rwblock
               cbu_read_write_block_data=interrupt_PRIORITY_block_data;
             end
             //invalid case
             //3'b010://IMR
             //begin
             //end
             //invalid case
             //3'b011://priority
             //begin
             //end
             //invalid case
             //3'b100://INIT
             //begin
             //end
             3'b101://handeling
             begin
               cbu_read_write_block_data[7:3]=status[13:9];
               cbu_read_write_block_data[2:0]=interrupt_PRIORITY_block_data[2:0];
             end
             3'b110://ACK
             begin
               INT=1'b1;
               temp_int=interrupt_PRIORITY_block_data;
                 if(status[15]==0)//cascade
                 begin
                   if(_SPEN==1'b1)//master
                    begin
                      if(status[temp_int+1]==1'b1)
                        begin 
                         SLAVE_ADRESS[2:0]=temp_int;
                        end
                    end
                 end
             end
             //invalid case
             //3'b111://reset
             //begin
             //end
              default:;
            endcase
      end
  end
  
  always @(_CS , i_ocw , command_word_num ,read_write_block_wr)
  begin
    if(_CS == 1'b0)
      begin
        if(i_ocw ==1'b0)
          begin
           case(command_word_num)
             //ocw1
             2'b00:
             begin
               //send data to interrupt block as int mask //rw=0;mode010;data=imr
               CU_WRITE= CU_WRITE^1;
               interrupt_block_mode=3'b010;
               interrupt_block_data=read_write_block_data;
             end
             //ocw2
             2'b01:
             begin
               //send the whole ocw2 to the interrupt block 
               CU_WRITE= CU_WRITE^1;
               interrupt_block_mode=3'b011;
               interrupt_block_data=read_write_block_data;
             end
             //ocw3
             2'b10:
             begin
               if(read_write_block_data[0]==1&&read_write_block_data[1]==1)
                 begin
                   //read the isr and send it to the read write block 
                   CU_WRITE= CU_WRITE^1;
               interrupt_block_mode=3'b001;
                 end
               else if(read_write_block_data[0]==0&&read_write_block_data[1]==1)
                begin
                  //read the irr and send it to the read write block
                  CU_WRITE= CU_WRITE^1; 
               interrupt_block_mode=3'b000;
                end
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
               status[16]=read_write_block_data[0];//icw4 needed?
               status[15]=read_write_block_data[1];//single vs cascad
               status[14]=read_write_block_data[3];//lvl vs edge trigger
               // send new configuration to the interrupt block
               if(status[16]==0)
                 begin 
                   CU_WRITE= CU_WRITE^1;
                  interrupt_block_mode=3'b100;
                  interrupt_block_data[0]=1'b1;
                  interrupt_block_data[1]= status[14];
                  interrupt_block_data[2]=status[15];
                 end
             end
             //icw2
             2'b01:
             begin
                status[13:9]=read_write_block_data[7:3];//vector adress
             end
             //icw3
             2'b10:
             begin
               if(_SPEN==1'b1)//master
                 begin
                   status[8:1]=read_write_block_data[7:0];// input have slave or slave id
                 end
               else if(_SPEN==1'b0)//slave
                 begin
                   status[3:1]=read_write_block_data[2:0];
                   SLAVE_ADRESS=read_write_block_data[2:0];
                 end
             end
             //icw4
             2'b11:
             begin
               status[0]=read_write_block_data[1];//auto vs manual EOI
               // send new configuration to the interrupt block
               CU_WRITE= CU_WRITE^1;
                  interrupt_block_mode=3'b100;
                  interrupt_block_data[0]=status[0];
                  interrupt_block_data[1]= status[14];
                  interrupt_block_data[2]=status[15]; 
             end
           endcase
          end
      end 
  end
  //always @( _WR or _RD)
//    begin
//    flag_read_write_block_data=1'b0;
//    end
endmodule





`timescale 1ns/1ps  
module IC_8259A_DUT();
  
   reg _CS,A0,_INTA,_WR,_RD,_SPEN;
   reg [7:0] IR;
   wire[7:0] DATA;//io
   reg [7:0] reg_Data;
   reg Data_flag=0;
   assign DATA=Data_flag?reg_Data:8'bZ;
   
   wire[2:0] CAS;//io
    reg [2:0] reg_CAS;
   reg CAS_flag=0;
   assign CAS=CAS_flag?reg_CAS:8'bZ;
   
   wire INT;
  
  IC_8259A my_IC(_CS,A0,_INTA,_WR,_RD,_SPEN,IR,DATA,CAS,INT);
  
  initial begin
    _CS=1'b0;
    A0=1'b0;
    _INTA=1'b1;
    _WR=1'b1;
    _RD=1'b1;
    _SPEN=1'b1;
    #5;
    //icw1
    Data_flag=1;
    reg_Data=8'b00010111;
    _WR=1'b0;
    #5;
    _WR=1'b1;
    #5;
    //icw2
    Data_flag=1;
    A0=1'b1;
    reg_Data=8'b11111000;
    _WR=1'b0;
    #5;
    _WR=1'b1;
    #5;
    //icw3
    Data_flag=1;
    A0=1'b1;
    reg_Data=8'b00000000;
    _WR=1'b0;
    #5;
    _WR=1'b1;
    #5;
    //icw4
    Data_flag=1;
    A0=1'b1;
    reg_Data=8'b00000011;
    _WR=1'b0;
    #5;
    _WR=1'b1;
    #5;
    //initialization (icw4 needed,sngl mood,edg trg,start adress 11111,master/slave adress 00000000,AEOI 1)
    
    
    
    IR[7]=1'b1;
    #5;
    _INTA=1'b0;
    #5;
    _INTA=1'b1;
    #5;
    _INTA=1'b0;
    #5;
    _INTA=1'b1;
    #5;
    Data_flag=0;
    _RD=1'b0;
     #5;
    _RD=1'b1; 
    IR[7]=1'b0;
    #5;
    //handelling one interrupt at pin 7
    
    
     IR[6]=1'b1;
    #5;
    _INTA=1'b0;
    #5;
    _INTA=1'b1;
    #5;
    IR[5]=1'b1;
    #5;
    _INTA=1'b0;
    #5;
    _INTA=1'b1;
    #5;
     _INTA=1'b0;
    #5;
    _INTA=1'b1;
    #5;
      _RD=1'b0;
     #5;
    _RD=1'b1; 
    IR[5]=1'b0;
    #5;
    
    _INTA=1'b0;
    #5;
    _INTA=1'b1;
    #5;
      _RD=1'b0;
     #5;
    _RD=1'b1; 
    IR[6]=1'b0;
    #5;
    //nesting ir6 with ir5
  
  
  
  
    //icw1
    A0=1'b0;
    Data_flag=1;
    reg_Data=8'b00010111;
    _WR=1'b0;
    #5;
    _WR=1'b1;
    #5;
    //icw2
    Data_flag=1;
    A0=1'b1;
    reg_Data=8'b11111000;
    _WR=1'b0;
    #5;
    _WR=1'b1;
    #5;
    //icw3
    Data_flag=1;
    A0=1'b1;
    reg_Data=8'b00000000;
    _WR=1'b0;
    #5;
    _WR=1'b1;
    #5;
    //icw4
    Data_flag=1;
    A0=1'b1;
    reg_Data=8'b0000001;
    _WR=1'b0;
    #5;
    _WR=1'b1;
    #5;
    //initialization (icw4 needed,sngl mood,edg trg,start adress 11111,master/slave adress 00000000,AEOI 0)
    
    
    
     IR[7]=1'b1;
    #5;
    _INTA=1'b0;
    #5;
    _INTA=1'b1;
    #5;
    _INTA=1'b0;
    #5;
    _INTA=1'b1;
    #5;
    Data_flag=1;
    A0=1'b0;
    reg_Data=8'b00100000;
    _WR=1'b0;
    #5;
    _WR=1'b1;
    #5;
    Data_flag=0;
    _RD=1'b0;
     #5;
    _RD=1'b1; 
    IR[7]=1'b0;
    #5;
    //handelling one interrupt at pin 7 manual
    
    IR[6]=1'b1;//int 6
    #5;
    _INTA=1'b0;//ack
    #5;
    _INTA=1'b1;
    #5;
    IR[5]=1'b1;//int 5
    #5;
    _INTA=1'b0;//ack
    #5;
    _INTA=1'b1;
    #5;
     _INTA=1'b0;//ack
    #5;
    _INTA=1'b1;
    #5;
    Data_flag=1;//icw2
    A0=1'b0;
    reg_Data=8'b01100000;
    _WR=1'b0;
    #5;
    _WR=1'b1;
    #5;
    Data_flag=0;
      _RD=1'b0;
     #5;
    _RD=1'b1; 
    IR[5]=1'b0;
    #5;
    
    _INTA=1'b0;
    #5;
    _INTA=1'b1;
    #5;
    Data_flag=1;
    A0=1'b0;
    reg_Data=8'b01100000;
    _WR=1'b0;
    #5;
    _WR=1'b1;
    #5;
    Data_flag=0;
      _RD=1'b0;
     #5;
    _RD=1'b1; 
    IR[6]=1'b0;
    #5;
    //nesting ir6 with ir5 manual
    
    //icw1
    _SPEN=1'b0;
    A0=1'b0;
    Data_flag=1;
    reg_Data=8'b00010101;
    _WR=1'b0;
    #5;
    _WR=1'b1;
    #5;
    //icw2
    Data_flag=1;
    A0=1'b1;
    reg_Data=8'b11111000;
    _WR=1'b0;
    #5;
    _WR=1'b1;
    #5;
    //icw3
    Data_flag=1;
    A0=1'b1;
    reg_Data=8'b00000111;
    _WR=1'b0;
    #5;
    _WR=1'b1;
    #5;
    //icw4
    Data_flag=1;
    A0=1'b1;
    reg_Data=8'b0000011;
    _WR=1'b0;
    #5;
    _WR=1'b1;
    #5;
    //initialization (icw4 needed,cas mood,edg trg,start adress 11111,master/slave adress 00000000,AEOI 1)
  
   IR[7]=1'b1;
    #5;
    CAS_flag=1;
    reg_CAS[2:0]=3'b110;
    _INTA=1'b0;
    #5;
    _INTA=1'b1;
    #5;
    _INTA=1'b0;
    #5;
    _INTA=1'b1;
    #5;
     CAS_flag=1;
    reg_CAS=3'b111;
    #5;
    
    _INTA=1'b0;
    #5;
    _INTA=1'b1;
    #5;
    _INTA=1'b0;
    #5;
    _INTA=1'b1;
    #5;
    Data_flag=0;
    _RD=1'b0;
     #5;
    _RD=1'b1; 
    IR[7]=1'b0;
    #5;
    //handelling one interrupt at pin 7
    
    
    
    
    //icw1
    _SPEN=1'b1;
    A0=1'b0;
    Data_flag=1;
    reg_Data=8'b00010101;
    _WR=1'b0;
    #5;
    _WR=1'b1;
    #5;
    //icw2
    Data_flag=1;
    A0=1'b1;
    reg_Data=8'b11111000;
    _WR=1'b0;
    #5;
    _WR=1'b1;
    #5;
    //icw3
    Data_flag=1;
    A0=1'b1;
    reg_Data=8'b00000111;
    _WR=1'b0;
    #5;
    _WR=1'b1;
    #5;
    //icw4
    Data_flag=1;
    A0=1'b1;
    reg_Data=8'b0000011;
    _WR=1'b0;
    #5;
    _WR=1'b1;
    #5;
    //initialization (icw4 needed,cas mood,edg trg,start adress 11111,master/slave adress 00000000,AEOI 1)
  
  CAS_flag=0; 
   IR[1]=1'b1;
    #5;
    _INTA=1'b0;
    #5;
    _INTA=1'b1;
    #5;
    _INTA=1'b0;
    #5;
    _INTA=1'b1;
    #5;
    Data_flag=0;
    _RD=1'b0;
     #5;
    _RD=1'b1; 
    IR[7]=1'b0;
    #5;
    //handelling one interrupt at pin 7
  end
 endmodule






