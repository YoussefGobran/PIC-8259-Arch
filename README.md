# 8259 PIC Project - CSE311s Computer Architecture

## Team 26:

1. Andrew Ayman Samir - 2000003
2. Mazen Essam Eldin Helmy - 2001607
3. George Geham William - 2000073
4. Sara Ahmed Mostafa - 2000362
5. Youssef Saad Gobran - 2001440
6. Philopeteer Sameh Rasmy - 2000955

### Contents:

1. [Contribution Table](#contribution-table)
2. [Project Description](#project-description)
3. [Block Diagram](#block-diagram)
4. [Description for all signals used](#description-for-all-signals-used)
5. [Brief description of the testing strategy](#brief-description-of-the-testing-strategy)
   1. [First Testbench](#1-first-testbench)
   2. [Second Testbench](#2-second-testbench)
   3. [Third Testbench](#3-third-testbench)

---

## Contribution Table:

| Name              | Contribution                                     |
|-------------------|--------------------------------------------------|
| Andrew Ayman      | PIC main control logic module & Cascading Testbench   |
| Mazen Essam Eldin | Initialization and Configuration module       |
| George Geham      | Single Mode AEOI Edge Triggered Testbench      |
| Sara Ahmed        | Priority Resolver Handler Module               |
| Youssef Saad      | Cascading Handler Module & Single Mode EOI Level Triggered Testbench |
| Philopeteer Sameh | Reading Status Handler Module                   |

---

## Project Description:

Design and implement a Programmable Interrupt Controller (PIC) based on the 8259-architecture using Verilog hardware description language. The 8259 PIC is a crucial component in computer systems responsible for managing and prioritizing interrupt requests, facilitating efficient communication between peripherals and the CPU.

**Functionalities Provided:**
- 8259 Compatibility
- Programmability (ICWs,OCWs)
- Cascade Mode
- Interrupt Handling
- Interrupt Masking through IMR
- Edge/Level Triggering
- Fully Nested Mode
- Automatic Rotation
- EOI
- AEOI
- Specific Rotation
- Reading Status

---
## Block Diagram:

<img src="Archi 8259 Project Block Diagram.jpg" alt="Block Diagram">

---

## Description for all signals used:

| Signal                           | Description                                              |
|----------------------------------|----------------------------------------------------------|
| cs_neg                           | Used to activate the reading and writing protocols (active_low). |
| rd_neg                           | Used to read the status of the PIC (irr, isr, imr) (active_low). |
| wr_neg                           | Used to write ICWs, OCWs to PIC to initialize and configure some important flags (active_low). |
| a0                               | Used with the data bus buffer in reading and writing protocols. |
| sp_eng                           | Used in cascade mode to flag the module as a slave (active_low). |
| inta_neg                         | Used to receive the interrupt acknowledged pulses during the interrupt cycle. |
| vcc                              | Giving 5V+ power to PIC (Not used in Verilog as it has no meaning from a simulation perspective). |
| gnd                              | Giving GND power to PIC (Not used in Verilog as it has no meaning from a simulation perspective). |
| ir[0:7]                          | The interrupt lines coming from the I/O devices (Slave Interrupt Lines) which are used to flag to PIC what interrupt is active. |
| data_inout[0:7]                  | The data bus buffer used in: Initialization, Configuration, reading, releasing vector address. |
| cas[0:2]                         | The cascading lines which are used as a chip select to the active slave with the interrupt. |
| int                              | The interrupt line used to flag to the CPU that there is an active interrupt. |
| interrupt_cycle_counter          | Used internally to check where exactly is the pic during the interrupt cycle (Think of it as an FSM). |
| data_bus_buffer_output[0:7]      | Used to control what values it has when releasing the vector address. |
| output_data_bus_control          | To control when the data_out line has the data bus buffer output. |
| interrupt_active                 | To check internally if there is an active interrupt at all times. |
| interrupt_active_id[0:2]          | The id of the corresponding higher priority interrupt after the first inta pulse which this id will be set in the isr. |
| isr[0:7]                         | Holds 1 in the corresponding active id after the first inta pulse in the interrupt cycle. |
| irr[0:7]                         | Holds 1 in the corresponding id after initialization from ir and resets the value in edge triggering mode after setting of the isr after the first inta pulse in the interrupt cycle. |
| single_mode_flag                 | flags that are calculate from the ICW 1 ,2,3,4, OCW 1,2,3 which are needed in the rest of the design in conditional checks along the code. |
| level_trigger_flag_and_edge_level_neg | ... |
| last_five_bits_of_vector_address[0:4] | ... |
| slaves_connected_flag[0:7]       | ... |
| my_slave_id[0:2]                      | ... |
| aeoii_and_eoi_neg_flag           | ... |
| imr[0:7]                         | ... |
| ir_level_ocw2[0:2]               | ... |
| control_bits_ocw2[0:2]           | ... |
| ocw2_output_flag                 | ... |
| automatic_rotation_mode_flag     | ... |
| read_type_flag[0:1]              | ... |
| ready_to_accept_interrupts_flag  | Flags that are calculated from the ICW 1,2,3,4, OCW 1,2,3 which are needed in the rest of the design in conditional checks along the code. |
| read_active_flag                 | To flag that there is a read output should be done unto the data_out. |
| read_data_buffer                 | What the value the data_out when read_active_flag is active. |
| priorities[0:2]                  | used as a prioirty controller (8x3) where each row as and ir level and the value of the row is the prioirty level where initially ir0 has a priority of 7 and so forth. |
| priorities_list_1[0:7]           | ... |
| priorities_list_2[0:7]           | ... |
| priorities_list_3[0:7]           | Used as a priority controller (8x3) where each row as an ir level and the value of the row is the priority level where initially ir0 has a priority of 7 and so forth. |
| current_highest_priority_id[0:2] | The id of the corresponding higher priority interrupt which is calculated from the masked_irr. |
| current_highest_priority_id_with_isr[0:2] | The id of the corresponding higher priority interrupt which is calculated from the masked_irr with the isr used in cascading mode to release the cascading line. |
| interrupt_start_flag              | To start the interrupt cycle and increase the interrupt cycle. |

---

## Brief description of the testing strategy:

### 1. PIC_TB_SINGLE_MODE_AEOI_EDGE Testbench:

- Initialize the PICs through ICW1, ICW2, ICW4.
- Setting of the IMR, disabling IR1 through OCW 1.
- IR0-2 is active, and the priority chooses IR0.
- Send the first INTA pulse to set the ISR.
- Read IRR which gives the correct value that IRR0 is disabled and the rest as they are.
- Read the ISR by sending OCW3.
- Send the second pulse during the data bus buffer has the vector address of IR0 to close the interrupt cycle (AEOI).
- Set the IMR, disable IR1.
- Verify that the next interrupt would be of IR2.
- Set automatic rotation, make IR0 active, and send corresponding INTA pulses.
- Verify that, at the end, IR0 becomes the least priority.

### 2. PIC_TB_SINGLE_MODE_EOI_LEVEL Testbench:

- Initialize the PICs through ICW1, ICW2, ICW4.
- Setting of the IR0, making the interrupt flag as on.
- Send two pulses of INTA, but the interrupt flag wouldn’t come down at the end of the second pulse.
- Send non-specific EOI through OCW2 to end the interrupt cycle.
- Set IR0 back to 0 to not restart the cycle because of level triggering.
- Test IR0 again with specific EOI command.
- Disable IR0 before the end because of level triggering.
- Set IR0,1 and send two pulses of INTA pulses.
- Send non-specific rotate EOI to reset IR0.
- Set IR0,1 and send specific rotate on IR1 to reset it.
- IR0 becomes active again because of rotated IR1.

### 3. PIC_TB_CASCADE_MODE_AEOI_EDGE Testbench:

- Use a Master- Slave schema with slaves connected to IR0, IR5.
- Set the three pics with the appropriate ICW1, 2, 3, 4 to all three pics.
- Test IR1-master to ensure normal interrupts are handled correctly.
- Set IR0-slave-0, IR0-slave-5, making IR0,5-master active.
- Verify the correct operation of cascading lines and appropriate IDs of slaves connected to the active IR.
- Finish the cycle for IR0-master, then choose IR5-master.
- Verify the correct vector address at the end of the cycle.


