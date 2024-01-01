module PIC_TB_SINGLE_MODE_EOI_LEVEL;
  // This Test bench tests the following:
  // Level Triggering
  // automatic rotation in eoi
  // Specific Rotation
  // EOI 
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
    data_bus_buffer=8'b11011000;
    wr_neg=0;
    cs_neg=0;
    a0=0;

    #10
    data_bus_buffer=8'bzzzzzzzz;
    cs_neg=1;
    wr_neg=1;
    
    //ICW2
    #10
    data_bus_buffer=8'b00010111;
    a0=1;
    wr_neg=0;
    cs_neg=0;

    #10
    data_bus_buffer=8'bzzzzzzzz;
    cs_neg=1;
    wr_neg=1;

    //ICW4
    #10
    data_bus_buffer=8'b10000000;
    a0=1;
    wr_neg=0;
    cs_neg=0;

    #10
    data_bus_buffer=8'bzzzzzzzz;
    cs_neg=1;
    wr_neg=1;

    //IRR of 0 active
    #10
    ir=8'b10000000;

    //first pulse of first interrupt
    #10;
    inta_neg=0;
    #10;
    inta_neg=1;
    
    //second pulse of first interrupt
    #10;
    inta_neg=0;
    #10;
    inta_neg=1;

    //disable ir0 because of level
    #10
    ir=0;

    //send non-specific eoi
    //OCW2
    #10
    data_bus_buffer=8'b00000100;
    a0=0;
    wr_neg=0;
    cs_neg=0;

    #10
    data_bus_buffer=8'bzzzzzzzz;
    cs_neg=1;
    wr_neg=1;

    
    //IRR of 1 active
    #10
    ir=8'b01000000;

    //first pulse of second interrupt
    #10;
    inta_neg=0;
    #10;
    inta_neg=1;

    //second pulse of second interrupt
    #10;
    inta_neg=0;
    #10;
    inta_neg=1;

    //disable ir1 because of level
    #10
    ir=0;

    //send specific eoi
    //OCW2
    #10
    data_bus_buffer=8'b10000110;
    a0=0;
    wr_neg=0;
    cs_neg=0;

    #10
    data_bus_buffer=8'bzzzzzzzz;
    cs_neg=1;
    wr_neg=1;

    

    //IRR of 0 active
    #10
    ir=8'b11000000;

    //first pulse of third interrupt
    #10;
    inta_neg=0;
    #10;
    inta_neg=1;

    //second pulse of third interrupt
    #10;
    inta_neg=0;
    #10;
    inta_neg=1;

    //send rotate non-specific
    //OCW2
    #10
    data_bus_buffer=8'b00000101;
    a0=0;
    wr_neg=0;
    cs_neg=0;

    #10
    data_bus_buffer=8'bzzzzzzzz;
    cs_neg=1;
    wr_neg=1;

    //first pulse of fourth interrupt (will choose ir 1 because of 0 was rotated)
    #10;
    inta_neg=0;
    #10;
    inta_neg=1;

    //second pulse of fourth interrupt 
    #10;
    inta_neg=0;
    #10;
    inta_neg=1;

    //send rotate specific
    //OCW2
    #10
    data_bus_buffer=8'b10000111;
    a0=0;
    wr_neg=0;
    cs_neg=0;

    #10
    data_bus_buffer=8'bzzzzzzzz;
    cs_neg=1;
    wr_neg=1;

    //first pulse of fifth interrupt (will be again ir 0)
    #10;
    inta_neg=0;
    #10;
    inta_neg=1;

    //second pulse of fifth interrupt
    #10;
    inta_neg=0;
    #10;
    inta_neg=1;

    //disable ir
    #10
    ir=0;

    //send non specific
    //OCW2
    #10
    data_bus_buffer=8'b00000100;
    a0=0;
    wr_neg=0;
    cs_neg=0;

    #10
    data_bus_buffer=8'bzzzzzzzz;
    cs_neg=1;
    wr_neg=1;

  end
endmodule