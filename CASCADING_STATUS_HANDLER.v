module CASCADING_STATUS_HANDLER (
  input wire single_mode_flag,
  input wire sp_neg,
  input wire [0:2] interrupt_cycle_counter,
  input wire [0:2] interrupt_id, // only for master mode
  input wire [0:7] slaves_connected_flag, // only for master mode
  input wire [0:2] my_slave_id, // only for slave mode

  inout [0:2] cascading_lines,

  output wire slave_active_interrupt_flag // only for slave mode
  );

  assign slave_active_interrupt_flag = single_mode_flag||sp_neg?0:interrupt_cycle_counter>=1&&interrupt_cycle_counter<=5?cascading_lines==my_slave_id:0;

  assign cascading_lines = single_mode_flag || !sp_neg? 3'bzzz: 
    interrupt_cycle_counter>=1&&interrupt_cycle_counter<=5&&slaves_connected_flag[interrupt_id] ?
        interrupt_id : 
          3'bzzz ;
endmodule
