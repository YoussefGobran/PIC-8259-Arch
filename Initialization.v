module Initiate(
input [7:0] D,
input CS,
input WR,
input A,
input SP,
output reg SNGL,
output reg LTIM,
output reg [4:0]VectorAdress,
output reg [7:0] CascadedPorts,
output reg [2:0] ID,
output reg AEOI,
output reg [7:0] IMR,
output reg [3:0] IntLevel,
output reg [3:0] ControlBits,
output reg [1:0]ReadRegister


);
reg flag=0;
reg ICW4;
always@(negedge WR)begin

  if (!CS && !WR)begin
    
     if(D[4] && !A)begin //ICW1
        AEOI<=0;
        flag=1;
        if(D[0])begin ICW4<=1;  end
        else begin ICW4<=0; flag=flag+1;end
        if(D[1])begin SNGL<=1; flag=flag+1;end
        else begin SNGL<=0; end
        if(D[3])begin LTIM<=1;end
        else begin LTIM<=0;end
        
      end
      else if(A && flag)begin //ICW2
        VectorAdress<=D[7:3];
        flag=flag+1;
        

      end
      else if(!SNGL && A) begin //ICW3
        if(!SP)begin
          CascadedPorts<=D[7:0];
          flag=flag+1;
        end
        else begin
          ID<=D[2:0];
         flag=flag+1; 
          end
      end
      else if (ICW4)begin //ICW4
        if(D[1])begin AEOI<=D[1];flag=flag+1;end
        else begin AEOI<=0; flag=flag+1;end
        
    
      end
    if(flag==4)begin
     if(A)begin IMR<=D[7:0];end  //OCW1
     else if(!A && !D[4] && !D[3])begin IntLevel<=D[2:0]; ControlBits<=D[7:5]; end //OCW2
     else if(!A && !D[4] && !D[7]&& D[3] )begin ReadRegister<=D[1:0]; end //OCW3
      
  end
    
    
    
    
    
    end
  end


endmodule 

