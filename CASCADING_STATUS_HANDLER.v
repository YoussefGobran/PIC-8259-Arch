module CASCADING_STATUS_HANDLER (
  input wire single_mode_flag,
  input wire sp_neg,
  input wire inta_neg,
  input wire [0:3] interrupt_id, // only for master mode
  input wire [0:7] slaves_connected_flag, // only for master mode
  input wire [0:3] my_slave_id, // only for slave mode

  inout [0:3] cascading_lines,

  output wire slave_active_interrupt_flag // only for slave mode
  );

  assign slave_active_interrupt_flag = cascading_lines==my_slave_id;

  assign cascading_lines = !single_mode_flag && !sp_neg? 3'bzzz:!single_mode_flag && sp_neg && ! inta_neg &&
         slaves_connected_flag[interrupt_id] == 1 ?
               interrupt_id : 
               slaves_connected_flag[0] == 1 ?
                  3'bzzz :
                  3'b000;
endmodule