module controller(input clk, input rst_n,
                  input [6:0] opcode, input [1:0] shift_op,
                  input [31:0] status_reg,
                  output waiting,
                  output [1:0] wb_sel, output sel_A, output sel_B, output sel_shift,
                  output w_en, output en_A, output en_B, output en_C, output en_status, output en_S,
                  output load_ir, output load_pc, output clear_pc, //not yet used
                  output load_addr, output sel_addr, output ram_w_en);

    /*
    Regular Instructions (No-type)
    NOP: 0000000
    HLT: 0000001

    Regular Instructions (I-type)
    MOV: 0010000 (1clk)
        1. wb_sel = 1, w_en = 1, w_addr = rd
    ADD: 0010001 (3clk)
        1. A_addr = rn, en_A = 1
        2. sel_A = 0, sel_B = 1, ALU_op = 000, en_C = 1
        3. wb_sel = 1, w_en = 1, w_addr = rd
    SUB: 0010010
        same as ADD, ALU_op = 001
    CMP: 0010011
        same as SUB, en_status = 1
    AND: 0010100
        same as ADD, ALU_op = 010
    ORR: 0010101
        same as ADD, ALU_op = 011
    EOR: 0010110 == XOR
        same as ADD, ALU_op = 111
    LSL: 0010111
        1. B_addr = rm, en_B = 1, sel_shift = 0, en_S = 1
        2. shift_op = 0, sel_A = 1, sel_B = 0, ALU_op = 000, en_C = 1
        3. wb_sel = 1, w_en = 1, w_addr = rd
    LSR: 0011000
        same as LSL, shift_op = 1
    ASR: 0011001
        same as LSL, shift_op = 2
    ROR: 0011010
        same as LSL, shift_op = 3

    Regular Instructions (R-type)
    MOV: 0100000
        1. B_addr = rm, en_B = 1, sel_shift = 0, en_S = 1
        2. shift_op = 0, sel_A = 1, sel_B = 0, ALU_op = 000, en_C = 1
        3. wb_sel = 1, w_en = 1, w_addr = rd
    ADD: 0100001
        1. A_addr = rn, en_A = 1, B_addr = rm, en_B = 1, sel_shift = 0, en_S = 1
        2. shift_op = 0, sel_A = 0, sel_B = 1, ALU_op = 000, en_C = 1
        3. wb_sel = 1, w_en = 1, w_addr = rd
    SUB: 0100010
        same as ADD, ALU_op = 001
    CMP: 0100011
        same as SUB, en_status = 1
    AND: 0100100
        same as ADD, ALU_op = 010
    ORR: 0100101
        same as ADD, ALU_op = 011
    EOR: 0100110 == XOR
        same as ADD, ALU_op = 111

    Regular Instructions (RS-type)
    MOV: 0110000
        1. B_addr = rm, en_B = 1, shift_addr = rs, sel_shift = 1, en_S = 1
        2. shift_op = 0, sel_A = 1, sel_B = 0, ALU_op = 000, en_C = 1
        3. wb_sel = 1, w_en = 1, w_addr = rd
    ADD: 0110001
        1. A_addr = rn, en_A = 1, B_addr = rm, en_B = 1, shift_addr = rs, sel_shift = 1, en_S = 1
        2. shift_op = 0, sel_A = 0, sel_B = 1, ALU_op = 000, en_C = 1
        3. wb_sel = 1, w_en = 1, w_addr = rd
    SUB: 0110010
        same as ADD, ALU_op = 001
    CMP: 0110011
        same as SUB, en_status = 1
    AND: 0110100
        same as ADD, ALU_op = 010
    ORR: 0110101
        same as ADD, ALU_op = 011
    EOR: 0110110 == XOR
        same as ADD, ALU_op = 111
    LSL: 0110111
        1. B_addr = rm, en_B = 1, shift_addr = rs, sel_shift = 1, en_S = 1
        2. shift_op = 0, sel_A = 1, sel_B = 0, ALU_op = 000, en_C = 1
        3. wb_sel = 1, w_en = 1, w_addr = rd
    LSR: 0111000
        same as LSL, shift_op = 1
    ASR: 0111001
        same as LSL, shift_op = 2
    ROR: 0111010
        same as LSL, shift_op = 3

    Branch Instructions
    B: 1000000
    BX: 1000001
    BL: 1000010
    BLX: 1000011
    BEQ: 1000100
    BNE: 1000101

    Load/Store Instructions - TBA
    - P = 1 -> Pre-Indexing
    - P = 0 -> Post-Indexing
    - U = 1 -> Offset is positive
    - U = 0 -> Offset is negative
    - W = 1 -> Write back to base register
    - W = 0 -> Do not write back to base register
    */


endmodule: controller