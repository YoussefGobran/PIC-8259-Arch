module PRIORITY_RESOLVER_HANDLER(
  input wire [0:7] irr,
  input wire [0:7] imr,
  input wire [0:7] isr,

  input wire [0:7] priorities_list_1,
  input wire [0:7] priorities_list_2,
  input wire [0:7] priorities_list_3,
  
  output reg [0:2] current_highest_priority_id,
  output reg start_interrupt_flag
  );
  wire[0:7] masked_irr=(irr & (~imr));
  wire [0:2] priorities[0:7];
  
  genvar j;
  generate  // This will intiate the for loop
    for(j = 0; j<8; j=j+1) begin
      assign priorities[j]= {priorities_list_1[j],priorities_list_2[j],priorities_list_3[j]};
    end
  endgenerate

  integer i;
  always @(masked_irr,isr) begin
    // for loop looking fo the max value 
    // every row inside the matrix is an ir level
    // the value it self will be what priority it have
    start_interrupt_flag=0;
    current_highest_priority_id=0;
    for (i = 0; i < 8; i=i+1) begin
        if (masked_irr[i] == 1'b1 && (!start_interrupt_flag || priorities[i] > priorities[current_highest_priority_id])) begin
            start_interrupt_flag=1;
            current_highest_priority_id = i;
        end
    end
  end
endmodule