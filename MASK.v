module MASK (
  input [2:0] MODE,
  input [7:0] DATA,
  input RST,
  inout [7:0] IMR
);

  reg [7:0] IMR_temp;
  always @(*)
    begin
      if (MODE == 3'b010)
        IMR_temp = DATA;
    end

  always @(RST)
    begin
      if(RST)
        IMR_temp = 8'b0;
    end
    
    assign IMR = IMR_temp;
endmodule