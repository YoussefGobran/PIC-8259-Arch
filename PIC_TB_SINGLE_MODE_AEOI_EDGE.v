module PIC_TB_SINGLE_MODE_AEOI_EDGE;
  // This Test bench tests the following:
  // - Programmability
  // - Interrupt Priority Handling
  // - Masking
  // Edge Triggering
  // Fully Nested
  // Auto Rotation in AEOI
  // AEOI 
  // Reading Status
  reg cs_neg;
  reg rd_neg;
  reg wr_neg;
  reg a0;
  reg sp_neg;
  reg inta_neg;
  reg vcc;
  reg gnd;
  reg [0:7] ir;
  wire [0:7] data_inout;
  wire [0:2] cas;
  wire interrupt_flag;

  PIC_8259A pic(
    cs_neg,
    rd_neg,
    wr_neg,
    a0,
    sp_neg,
    inta_neg,
    vcc,
    gnd,
    ir,
    data_inout,
    cas,
    interrupt_flag
  );

  reg [0:7]data_bus_buffer;
  reg control_write=0;
  assign data_inout=data_bus_buffer;

  initial begin
    
    //intialize all
    data_bus_buffer=8'bzzzzzzzz;
    cs_neg=1;
    wr_neg=1;
    rd_neg=1;
    a0=0;
    sp_neg=1;
    inta_neg=1;
    vcc=1;
    gnd=0;
    ir=0;

    //ICW1
    #10
    data_bus_buffer=8'b11001000;
    wr_neg=0;
    cs_neg=0;
    a0=0;

    #10
    data_bus_buffer=8'bzzzzzzzz;
    cs_neg=1;
    wr_neg=1;
    
    //ICW2
    #10
    data_bus_buffer=8'b00010101;
    a0=1;
    wr_neg=0;
    cs_neg=0;

    #10
    data_bus_buffer=8'bzzzzzzzz;
    cs_neg=1;
    wr_neg=1;

    //ICW4
    #10
    data_bus_buffer=8'b11000000;
    a0=1;
    wr_neg=0;
    cs_neg=0;

    #10
    data_bus_buffer=8'bzzzzzzzz;
    cs_neg=1;
    wr_neg=1;

    //setting imr by ocw1(mask IR1)
    #10
    data_bus_buffer=8'b01000000;
    a0=1;
    wr_neg=0;
    cs_neg=0;
    #10
    data_bus_buffer=8'bzzzzzzzz;
    cs_neg=1;
    wr_neg=1;

    //IRR of 0-2 active
    #10
    ir=8'b11100000;

    #10;
    inta_neg=0;
    #10;
    inta_neg=1;

    // read IRR by turing rd should be the same except the first one is 1
    #10
    a0=0;
    rd_neg=0;
    cs_neg=0;
    #10
    a0=0;
    rd_neg=1;
    cs_neg=1;

     // read ISR by first sending ocw3
    #10
    data_bus_buffer=8'b11010000;
    a0=0;
    wr_neg=0;
    cs_neg=0;
    #10
    data_bus_buffer=8'bzzzzzzzz;
    cs_neg=1;
    wr_neg=1;

    // read ISR by turing rd should be empty
    #10
    a0=0;
    rd_neg=0;
    cs_neg=0;

    #10
    cs_neg=1;
    rd_neg=1;

    //second pulse of first interrupt
    #10;
    inta_neg=0;
    #10;
    inta_neg=1;

    //first pulse of second interrupt
    #20;
    inta_neg=0;
    #10;
    inta_neg=1;

    //second pulse of second interrupt
    #10;
    inta_neg=0;
    #10;
    inta_neg=1;

    // disabled because of imr 
    // //first pulse of third interrupt
    // #20;
    // inta_neg=0;
    // #10;
    // inta_neg=1;

    // //second pulse of third interrupt
    // #10;
    // inta_neg=0;
    // #10;
    // inta_neg=1;

    //setting of automatic rotation by sending ocw2
    #10
    data_bus_buffer=8'b00000001;
    a0=0;
    wr_neg=0;
    cs_neg=0;
    #10
    data_bus_buffer=8'bzzzzzzzz;
    cs_neg=1;
    wr_neg=1;

    //IRR of 0 active
    #10
    ir=8'b10000000;

    //first pulse of fourth interrupt
    #20;
    inta_neg=0;
    #10;
    inta_neg=1;
    //second pulse of fourth interrupt
    #10;
    inta_neg=0;
    #10;
    inta_neg=1;

    #10
    ir=8'b00000000;

    //IRR of 0,2 active
    #10
    ir=8'b10100000;

    // will make the ir 2 first because of autorotation
    //first pulse of fifth interrupt
    #20;
    inta_neg=0;
    #10;
    inta_neg=1;
    //second pulse of fifth interrupt
    #10;
    inta_neg=0;
    #10;
    inta_neg=1;

    //first pulse of sixth interrupt (now it will go back to the ir0)
    #20;
    inta_neg=0;
    #10;
    inta_neg=1;
    //second pulse of sixth interrupt
    #10;
    inta_neg=0;
    #10;
    inta_neg=1;


  end
endmodule