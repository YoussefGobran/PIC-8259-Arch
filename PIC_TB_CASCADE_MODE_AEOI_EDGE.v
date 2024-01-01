module PIC_TB_CASCADE_MODE_AEOI_EDGE;
  // This Test bench tests the following:
  // Cascade MODE with one master and two slaves
  // Edge Trigger
  // AEOI 
  reg cs_neg_master;
  reg rd_neg_master;
  reg wr_neg_master;
  reg a0_master;
  reg sp_neg_master;
  reg inta_neg;
  reg vcc;
  reg gnd;
  wire [0:7] ir_master;
  reg ir_master_1;
  reg ir_master_2;
  reg ir_master_3;
  reg ir_master_4;
  reg ir_master_6;
  reg ir_master_7;
  wire [0:7] data_inout;
  wire [0:2] cas;
  wire interrupt_flag_master;

  reg cs_neg_slave_0;
  reg rd_neg_slave_0;
  reg wr_neg_slave_0;
  reg a0_slave_0;
  reg sp_neg_slave_0;
  reg [0:7] ir_slave_0;
  wire interrupt_flag_slave_0;
  

  reg cs_neg_slave_5;
  reg rd_neg_slave_5;
  reg wr_neg_slave_5;
  reg a0_slave_5;
  reg sp_neg_slave_5;
  reg [0:7] ir_slave_5;
  wire interrupt_flag_slave_5;

  reg [0:7]data_bus_buffer;
  assign data_inout=data_bus_buffer;


  assign ir_master={
    interrupt_flag_slave_0,
    ir_master_1,
    ir_master_2,
    ir_master_3,
    ir_master_4,
    interrupt_flag_slave_5,
    ir_master_6,
    ir_master_7
    };

  PIC_8259A pic_slave_0(
    cs_neg_slave_0,
    rd_neg_slave_0,
    wr_neg_slave_0,
    a0_slave_0,
    sp_neg_slave_0,
    inta_neg,
    vcc,
    gnd,
    ir_slave_0,
    data_inout,
    cas,
    interrupt_flag_slave_0
  );
  PIC_8259A pic_slave_5(
    cs_neg_slave_5,
    rd_neg_slave_5,
    wr_neg_slave_5,
    a0_slave_5,
    sp_neg_slave_5,
    inta_neg,
    vcc,
    gnd,
    ir_slave_5,
    data_inout,
    cas,
    interrupt_flag_slave_5
  );
  
  PIC_8259A pic_master(
    cs_neg_master,
    rd_neg_master,
    wr_neg_master,
    a0_master,
    sp_neg_master,
    inta_neg,
    vcc,
    gnd,
    ir_master,
    data_inout,
    cas,
    interrupt_flag_master
  );

  initial begin
    // Initialize Master PIC
    // Intialize Of Global Wires
    data_bus_buffer=8'bzzzzzzzz;
    vcc=1;
    gnd=0;
    inta_neg=1;

    // initial Variables of Master PIC
    cs_neg_master=1;
    wr_neg_master=1;
    rd_neg_master=1;
    a0_master=0;
    sp_neg_master=1;
    ir_master_1=0;
    ir_master_2=0;
    ir_master_3=0;
    ir_master_4=0;
    ir_master_6=0;
    ir_master_7=0;

    // initial Variables of Slave-0
    cs_neg_slave_0=1;
    wr_neg_slave_0=1;
    rd_neg_slave_0=1;
    a0_slave_0=0;
    sp_neg_slave_0=0;
    ir_slave_0=0;
    
    // initial Variables of Slave-5
    cs_neg_slave_5=1;
    wr_neg_slave_5=1;
    rd_neg_slave_5=1;
    a0_slave_5=0;
    sp_neg_slave_5=0;
    ir_slave_5=0;

    // Intilize of Master PIC ICWs
    //ICW1
    #10
    data_bus_buffer=8'b10001000;
    wr_neg_master=0;
    cs_neg_master=0;
    a0_master=0;
    #10
    data_bus_buffer=8'bzzzzzzzz;
    cs_neg_master=1;
    wr_neg_master=1;
    
    //ICW2
    #10
    data_bus_buffer=8'b00010111;
    a0_master=1;
    wr_neg_master=0;
    cs_neg_master=0;
    #10
    data_bus_buffer=8'bzzzzzzzz;
    cs_neg_master=1;
    wr_neg_master=1;

    //ICW3
    #10
    data_bus_buffer=8'b10000100;
    a0_master=1;
    wr_neg_master=0;
    cs_neg_master=0;
    #10
    data_bus_buffer=8'bzzzzzzzz;
    cs_neg_master=1;
    wr_neg_master=1;

    //ICW4
    #10
    data_bus_buffer=8'b11000000;
    a0_master=1;
    wr_neg_master=0;
    cs_neg_master=0;
    #10
    data_bus_buffer=8'bzzzzzzzz;
    cs_neg_master=1;
    wr_neg_master=1;

    // Intilize of slave-0 PIC ICWs
    //ICW1
    #10
    data_bus_buffer=8'b10001000;
    wr_neg_slave_0=0;
    cs_neg_slave_0=0;
    a0_slave_0=0;
    #10
    data_bus_buffer=8'bzzzzzzzz;
    cs_neg_slave_0=1;
    wr_neg_slave_0=1;
    
    //ICW2
    #10
    data_bus_buffer=8'b00010011;
    a0_slave_0=1;
    wr_neg_slave_0=0;
    cs_neg_slave_0=0;
    #10
    data_bus_buffer=8'bzzzzzzzz;
    cs_neg_slave_0=1;
    wr_neg_slave_0=1;

    //ICW3
    #10
    data_bus_buffer=8'b00000000;
    a0_slave_0=1;
    wr_neg_slave_0=0;
    cs_neg_slave_0=0;
    #10
    data_bus_buffer=8'bzzzzzzzz;
    cs_neg_slave_0=1;
    wr_neg_slave_0=1;

    //ICW4
    #10
    data_bus_buffer=8'b11000000;
    a0_slave_0=1;
    wr_neg_slave_0=0;
    cs_neg_slave_0=0;
    #10
    data_bus_buffer=8'bzzzzzzzz;
    cs_neg_slave_0=1;
    wr_neg_slave_0=1;

    // Intilize of slave-5 PIC ICWs
    //ICW1
    #10
    data_bus_buffer=8'b10001000;
    wr_neg_slave_5=0;
    cs_neg_slave_5=0;
    a0_slave_5=0;
    #10
    data_bus_buffer=8'bzzzzzzzz;
    cs_neg_slave_5=1;
    wr_neg_slave_5=1;
    
    //ICW2
    #10
    data_bus_buffer=8'b00010001;
    a0_slave_5=1;
    wr_neg_slave_5=0;
    cs_neg_slave_5=0;
    #10
    data_bus_buffer=8'bzzzzzzzz;
    cs_neg_slave_5=1;
    wr_neg_slave_5=1;

    //ICW3
    #10
    data_bus_buffer=8'b10100000;
    a0_slave_5=1;
    wr_neg_slave_5=0;
    cs_neg_slave_5=0;
    #10
    data_bus_buffer=8'bzzzzzzzz;
    cs_neg_slave_5=1;
    wr_neg_slave_5=1;

    //ICW4
    #10
    data_bus_buffer=8'b11000000;
    a0_slave_5=1;
    wr_neg_slave_5=0;
    cs_neg_slave_5=0;
    #10
    data_bus_buffer=8'bzzzzzzzz;
    cs_neg_slave_5=1;
    wr_neg_slave_5=1;

    // first test with ir-master 1 (not connected to slave)
    #10
    ir_master_1=1;
    
    //first pulse of first interrupt
    #10
    inta_neg=0;
    #10
    inta_neg=1;

    //second pulse of first interrupt
    #10
    inta_neg=0;
    #10
    inta_neg=1;

    #10
    ir_master_1=0;

    //second test with ir-slave-0-0 and  ir-slave-5-0 , look at prioirty and cascading select
    #10
    ir_slave_0=8'b10000000;
    ir_slave_5=8'b10000000;

    //first pulse of second interrupt
    #20
    inta_neg=0;
    #10
    inta_neg=1;

    //second pulse of second interrupt
    #10
    inta_neg=0;
    #10
    inta_neg=1;

    //first pulse of third interrupt
    #20
    inta_neg=0;
    #10
    inta_neg=1;

    //second pulse of third interrupt
    #10
    inta_neg=0;
    #10
    inta_neg=1;

  end
endmodule