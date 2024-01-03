module READING_STATUS_HANDLER (
  input wire [0:1] read_type_flag,
  input wire a0,
  input wire cs_neg,
  input wire rd_neg,
  input wire [0:7] imr,
  input wire [0:7] isr,
  input wire [0:7] irr,

  output wire [0:7] read_multiplixer_output,
  output wire read_active_flag
  );

  localparam read_isr_type = 2'b11;
  localparam read_irr_type = 2'b01;
  // always@(negedge cs_neg) begin
  //   read_active_flag=0;
  //   if (!cs_neg && !rd_neg) begin
  //     read_active_flag=1;
  //     read_multiplixer_output = a0 ? ((read_type_flag == read_irr_type) ? irr : isr ) : imr ;
  //   end
  // end
  assign read_active_flag = (! cs_neg) && (! rd_neg); 
  assign read_multiplixer_output = !a0 ? ((read_type_flag == read_irr_type) ? irr : isr ) : imr ;
endmodule