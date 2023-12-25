
module INIT_AND_CONFIG_CW_HANDLER(
  input [0:7] data_bus_buffer,
  input cs_neg,
  input wr_neg,
  input a0,
  input sp_neg,

  output reg single_mode_flag,
  output reg level_trigger_flag_and_edge_level_neg,
  output reg [0:4] last_five_bits_of_vector_address,
  output reg [0:7] slaves_connected_flag,
  output reg [0:2] my_slave_id,
  output reg aeoi_and_eoi_neg_flag,
  output reg [0:7] imr,

  output reg [0:2] ir_level,
  output reg [0:2] control_bits,
  output reg ocw2_output_flag,  
  output reg automatic_rotation_mode_flag,

  output reg [0:1] read_type_flag,

  output wire ready_to_accept_interrupts_flag
  );
  reg icw_counter;
  reg icw_taken_max_limit;
  reg icw4_is_needed_flag;

  assign ready_to_accept_interrupts_flag = (icw_counter == icw_taken_max_limit);

  always@(negedge wr_neg) begin

    if (!cs_neg && !wr_neg) begin
      if(data_bus_buffer[4] && !a0) begin //ICW1
        ocw2_output_flag=0;
        control_bits=3'b010;
        imr=0;
        read_type_flag=2'b01;
        automatic_rotation_mode_flag=0;
        icw_counter=1;  
        icw_taken_max_limit=2;

        if(data_bus_buffer[0]) begin
          icw_taken_max_limit=icw_taken_max_limit+1;
          icw4_is_needed_flag=1;
        end
        else begin
          icw4_is_needed_flag=0;
        end

        if(data_bus_buffer[1]) begin
          single_mode_flag=1;
        end
        else begin
          single_mode_flag=0;
          icw_taken_max_limit=icw_taken_max_limit+1;
        end

        level_trigger_flag_and_edge_level_neg=data_bus_buffer[3];
      end

      else if(a0 && icw_counter==1)begin //ICW2
        last_five_bits_of_vector_address=data_bus_buffer[3:7];
        icw_counter=icw_counter+1; 
        
      end

      else if(!single_mode_flag && a0 && icw_counter ==2) begin //ICW3
        icw_counter=icw_counter+1; 

        if(sp_neg)begin //if master
          slaves_connected_flag=data_bus_buffer[0:7];
        end

        else begin
          my_slave_id<=data_bus_buffer[0:2];
        end

      end

      else if (icw4_is_needed_flag && a0 && icw_counter >=2 && icw_counter < icw_taken_max_limit) begin //ICW4
        aeoi_and_eoi_neg_flag=data_bus_buffer[1];
        icw_counter=icw_counter+1;
      end

      else if(icw_counter==icw_taken_max_limit) begin // ocw
        if(a0) begin // OCW1
          imr=data_bus_buffer;
        end

        else if (!a0 && !data_bus_buffer[4] && !data_bus_buffer[3]) begin // OCW2
          ir_level=data_bus_buffer[0:2];
          control_bits=data_bus_buffer[5:7];
          ocw2_output_flag=~ocw2_output_flag;
          if(control_bits==1'b001)automatic_rotation_mode_flag=1;
          else if(control_bits==1'b000)automatic_rotation_mode_flag=0;
          
        end

        else if(!a0 && !data_bus_buffer[4] && data_bus_buffer[3] && !data_bus_buffer[7]) begin // OCW3
          read_type_flag=data_bus_buffer[0:1];
        end
      end
    end
  end
endmodule 
