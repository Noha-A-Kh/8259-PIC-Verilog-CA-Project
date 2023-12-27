module RW_LOGIC(cpu_data , RD, WR, A0,CS, 
                internal_bus_data, type , nr);

  /*inputs and inouts from CPU to this block*/
  inout tri[7:0] cpu_data;  
  input RD,WR,A0,CS;

  /*inputs and inouts on the internal bus*/ 
  inout tri[7:0] internal_bus_data;
  output reg type;
  //output  Ack;
  output reg[1:0] nr;
  //input ctrl_ready_to_write;


  /*internal flags to be modified later : tmr inshAllah :)*/ 
  //reg ICW1_F , ICW2_F, ICW3_F, ICW4_F, OCW1_F , OCW2_F , OCW3_F;
  reg ICW4_exists = 0;
  reg [1:0] count = 2'b00;

  /*internal connectors for using the inout ports*/
  wire[7:0] wire_connector1;
  wire[7:0] wire_connector2;

  /*in case of write cycle, assign the data coming from the 
   cpu to the data going to the control logic */
  assign wire_connector1 = ~WR? cpu_data : 8'bX;
  assign internal_bus_data = ~WR ? wire_connector1 : 8'bZ;

  /*in case of a read cycle, the control logic should alert 
   that it's ready now to write the required content to you 
   so you can pass it to the data bus buffer*/
  assign wire_connector2 = ~RD ? internal_bus_data : 8'bX;
  assign cpu_data = ~RD ? wire_connector2 : 8'bZ;
  
  //assign Ack = ctrl_ready_to_write? 1:0; 
  
  
  /*write cycle*/ 
  always @(negedge WR)
    begin 
      ////////////////////////////////////////////////////////// if #CS is Low
      if(~CS)
        begin
          //////////////////////////////// begin of case
          case(count)
            ///////////// count = 0
            2'b00: 
              begin 
                if(A0 == 0 & cpu_data[4] ==1)  //case of ICW1
                  begin
                    //ICW1_F =1;
                    //RW = 1;
                    type = 1;
                    nr = 2'b00;
                    ICW4_exists = cpu_data[0];
                    count = 2'b01;
                    //send to ctrl unit
                  end

                else if(A0==0 & cpu_data[3]==0)  //case of ocw2
                  begin
                    //OCW2_F =1;
                    //RW=1;
                    type = 0;
                    nr = 2'b01;
                  end
                else if(A0 ==0 & cpu_data[3]==1) //case of ocw3
                  begin
                    //OCW3_F=1;
                    //RW=1;
                    type=0;
                    nr=22'b10;
                  end  
                else if(A0 == 1)  //case of ocw1
                  begin
                    //OCW1_F =1;
                    //RW = 1;
                    type = 0;
                    nr = 2'b00;
                  end
              end 
            /////////////////// count =1
            2'b01:
              begin
                if(A0 ==1)  //case of icw2
                  begin
                    //ICW2_F =1;
                    //RW=1;
                    type=1;
                    nr=2'b01;
                    count = 2'b10;
                  end
              end
            //////////////////// count =2
            2'b10:
              begin
                if(A0 ==1) //case of icw3
                  begin
                    //ICW3_F =1;
                    //RW=1;
                    type=1;
                    nr=2'b10;
                  end

                if(ICW4_exists) count = 2'b11;
                else count = 2'b00;

              end
            ///////////////////// count =3
            2'b11:
              begin
                if(A0 ==1)
                  begin
                    //ICW4_F =1;
                    //RW=1;
                    type=1;
                    nr=2'b11;
                    count = 2'b00;
                  end
              end
            ////////////////////////////////////// end of case
          endcase
        end
      ///////////////////////////////////////////////////// if #CS is High 

    end 

 /*
 //read cycle
  always @(negedge RD)
    begin
      if(~CS)
        RW=0;
    end */ 
endmodule




