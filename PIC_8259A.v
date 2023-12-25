
module PIC_8259A(
  input rd_neg, wr_neg, a0, sp_neg, inta_neg, vcc, gnd,
  input [0:7] ir,
  inout [0:7] data_inout,
  inout [0:2] cas,
  output reg int
  );

  reg [0:2]interrupt_cycle_counter;
  reg [0:7] data_bus_buffer_output;
  reg output_data_bus_control;
  

  wire interrupt_active;
  reg [0:2]interrupt_active_id;
  reg [0:7]isr;
  reg [0:7]irr;

  // Flags of initialzation and configuration
  wire single_mode_flag;
  wire level_trigger_flag_and_edge_level_neg;
  wire [0:4] last_five_bits_of_vector_address;
  wire [0:7] slaves_connected_flag;
  wire [0:2] my_slave_id;
  wire aeoi_and_eoi_neg_flag;
  wire [0:7] imr;

  wire [0:2] ir_level_ocw2;
  wire [0:2] control_bits_ocw2;
  wire ocw2_output_flag;
  wire automatic_rotation_mode_flag;

  wire [0:1] read_type_flag;
  wire ready_to_accept_interrupts_flag;

  wire slave_active_interrupt_flag;

  wire read_active_flag;
  wire[0:7] read_data_buffer;
  
  reg [0:2] priorities[0:7];
  wire [0:7] priorities_list_1;
  wire [0:7] priorities_list_2;
  wire [0:7] priorities_list_3;
  genvar j;
  generate  // This will intiate the for loop
    for(j = 0; j<8; j=j+1) begin
      assign {priorities_list_1[j],priorities_list_2[j],priorities_list_3[j]}= priorities[j];
    end
  endgenerate
  reg [0:2] current_highest_priority_id;

  reg[0:31] temp_counter;
  integer temp;
  /////////////////////////////////////////////////////////////////////////////////////////////////////////
  INIT_AND_CONFIG_CW_HANDLER IACWH (
    data_inout,
    cs_neg,
    wr_neg,
    a0,
    sp_neg,
    single_mode_flag,
    level_trigger_flag_and_edge_level_neg,
    last_five_bits_of_vector_address,
    slaves_connected_flag,
    my_slave_id,
    aeoi_and_eoi_neg_flag,
    imr,
    ir_level,
    control_bits,
    ocw2_output_flag,
    automatic_rotation_mode_flag,  
    read_type_flag,
    ready_to_accept_interrupts_flag
  );

  CASCADING_STATUS_HANDLER CSH (
    single_mode_flag,
    sp_neg,
    inta_neg,
    interrupt_active_id, // only for master mode
    slaves_connected_flag, // only for master mode
    my_slave_id, // only for slave mode
    cas,
    slave_active_interrupt_flag // only for slave mode
  );
  READING_STATUS_HANDLER RSH(
    read_type_flag,
    a0,
    cs_neg,
    rd_neg,
    imr,
    isr,
    irr,
    read_data_buffer,
    read_active_flag
  );
  PRIORITY_RESOLVER_HANDLER PRH(
    irr,
    imr,
    isr,
    priorities_list_1,
    priorities_list_2,
    priorities_list_3,
    current_highest_priority_id,
    interrupt_active
  );

  assign data_inout=output_data_bus_control?data_bus_buffer_output:read_active_flag?read_data_buffer:8'bzzzzzzzz;
  
  always @(posedge ready_to_accept_interrupts_flag)begin
    for(temp=0;temp<8;temp=temp+1)begin
      priorities[temp]<=7-temp;
    end
  end
  always @(posedge ir) begin
    irr<=ir;
  end

  always @(inta_neg) begin
    if(interrupt_cycle_counter<=5&&interrupt_cycle_counter>=1&& (single_mode_flag || sp_neg || (!sp_neg && slave_active_interrupt_flag))) begin
      interrupt_cycle_counter<=interrupt_cycle_counter+1;
    end
  end

  always @(posedge interrupt_active) begin
    if(ready_to_accept_interrupts_flag)begin
      if(interrupt_cycle_counter ==0)begin
        interrupt_cycle_counter=1;
      end
      else if (interrupt_cycle_counter ==3&&current_highest_priority_id!=interrupt_active_id&&priorities[current_highest_priority_id]>priorities[interrupt_active_id]) begin
        // handles if higher prioirty get handles during waiting for the second inta cycle
        int=0;
        interrupt_cycle_counter=1;
        // start counter and then reactivate interrupt
        for (temp = 0; temp<65536;temp=temp+1 ) begin
          temp_counter=temp_counter+1;
        end
        int=1;
      end
    end
  end

  always @(interrupt_cycle_counter) begin
    if (interrupt_cycle_counter==1) begin
      // means waiting for first inta pulse
      //send on interrupt output 
      int=1;
    end
    else if(interrupt_cycle_counter==2)begin
      if(!interrupt_active)begin
        interrupt_cycle_counter=0;
        int=0;
      end
      else begin 
        interrupt_active_id=current_highest_priority_id;
        //setting of isr
        isr[interrupt_active_id]=1;

        //check if it has level or edge and then reset IRR
        if(!level_trigger_flag_and_edge_level_neg)begin
          irr[interrupt_active_id]=0;
        end
        // incase of master cascading module right here is responsible for broadcasting the id on cas
      end
    end
    else if(interrupt_cycle_counter==3)begin
      // dont do anything
    end
    else if(interrupt_cycle_counter==4)begin
      //setting of D0-A7 of vector address
      if(single_mode_flag || !sp_neg || slaves_connected_flag[interrupt_active_id] == 0 ) begin 
        output_data_bus_control=1;
        data_bus_buffer_output={last_five_bits_of_vector_address,interrupt_active_id};
      end
    end
    else if(interrupt_cycle_counter==5)begin
      output_data_bus_control=0;
      //end of interrupt operations
      if(aeoi_and_eoi_neg_flag) begin
        if(automatic_rotation_mode_flag)begin
          for(temp=0;temp<8;temp=temp+1)begin
            if(priorities[temp]<priorities[interrupt_active_id])begin
                priorities[temp]=priorities[temp]+1;
            end
          end
          priorities[interrupt_active_id]=0;
        end

        isr[interrupt_active_id]=0;        
        interrupt_cycle_counter=0;
        int=0;
      end
    end
  end
  always @(ocw2_output_flag)begin
    if(interrupt_cycle_counter==5)begin
      case (control_bits)
        3'b100: begin // non specific eoi
            isr[interrupt_active_id]=0;
            interrupt_cycle_counter=0;
            int=0;
        end
        3'b110: begin // specific eoi
          if(interrupt_active_id==ir_level_ocw2)begin
            isr[interrupt_active_id]=0;
            interrupt_cycle_counter=0;
            int=0;
          end
        end
        3'b101: begin //rotate on non specific eoi
          
          for(temp=0;temp<8;temp=temp+1)begin
            if(priorities[temp]<priorities[interrupt_active_id])begin
                priorities[temp]=priorities[temp]+1;
            end
          end
          priorities[interrupt_active_id]=0;
          isr[interrupt_active_id]=0;
          interrupt_cycle_counter=0;
          int=0;

        end
        3'b111: begin // rotate on specific eoi 
          if(interrupt_active_id==ir_level_ocw2)begin
            for(temp=0;temp<8;temp=temp+1)begin
              if(priorities[temp]<priorities[interrupt_active_id])begin
                  priorities[temp]=priorities[temp]+1;
              end
            end
            priorities[interrupt_active_id]=0;
            isr[interrupt_active_id]=0;
            interrupt_cycle_counter=0;
            int=0;
          end
        end
        default: begin
        end
      endcase
    end
  end
endmodule 
// Thank You 