module controller(input clk, input rst_n,
                input [6:0] opcode, input [1:0] shift_op,
                input [31:0] status_reg, input en_status , input [3:0] cond,
                input [3:0] rn, input [3:0] rd, input [3:0] rm, input [3:0] rs,
                input [31:0] imme_data, input [31:0] shift_imme,
                output waiting,
                output [1:0] wb_sel, output sel_A, output sel_B, output sel_shift,
                output w_en, output en_A, output en_B, output en_C, output en_S, output [2:0] ALU_op,
                output load_ir, output load_pc, output clear_pc, //not yet used
                output load_addr, output sel_addr, output ram_w_en);

    /*
    Regular Instructions (No-type)
    NOP: 0000000
    HLT: 0000001

    Regular Instructions (I-type)
    ADD: 0010000 (3clk)
        1. A_addr = rn, en_A = 1
        2. sel_A = 0, sel_B = 1, ALU_op = 000, en_C = 1
        3. wb_sel = 1, w_en = 1, w_addr = rd
    SUB: 0010001
        same as ADD, ALU_op = 001
    CMP: 0010010
        same as SUB, en_status = 1
    AND: 0010011
        same as ADD, ALU_op = 010
    ORR: 0010100
        same as ADD, ALU_op = 011
    EOR: 0010101 == XOR
        same as ADD, ALU_op = 111
    MOV: 0011000 (1clk)
        1. wb_sel = 1, w_en = 1, w_addr = rd
    LSL: 0011001
        1. B_addr = rm, en_B = 1, sel_shift = 0, en_S = 1
        2. shift_op = 0, sel_A = 1, sel_B = 0, ALU_op = 000, en_C = 1
        3. wb_sel = 1, w_en = 1, w_addr = rd
    LSR: 0011010
        same as LSL, shift_op = 1
    ASR: 0011011
        same as LSL, shift_op = 2
    ROR: 0011100
        same as LSL, shift_op = 3

    Regular Instructions (R-type)
    ADD: 0100000
        1. A_addr = rn, en_A = 1, B_addr = rm, en_B = 1, sel_shift = 0, en_S = 1
        2. shift_op = 0, sel_A = 0, sel_B = 1, ALU_op = 000, en_C = 1
        3. wb_sel = 1, w_en = 1, w_addr = rd
    SUB: 0100001
        same as ADD, ALU_op = 001
    CMP: 0100010
        same as SUB, en_status = 1
    AND: 0100011
        same as ADD, ALU_op = 010
    ORR: 0100100
        same as ADD, ALU_op = 011
    EOR: 0100101 == XOR
        same as ADD, ALU_op = 111
    MOV: 0101000
        1. B_addr = rm, en_B = 1, sel_shift = 0, en_S = 1
        2. shift_op = 0, sel_A = 1, sel_B = 0, ALU_op = 000, en_C = 1
        3. wb_sel = 1, w_en = 1, w_addr = rd

    Regular Instructions (RS-type)
    ADD: 0110000
        1. A_addr = rn, en_A = 1, B_addr = rm, en_B = 1, shift_addr = rs, sel_shift = 1, en_S = 1
        2. shift_op = 0, sel_A = 0, sel_B = 1, ALU_op = 000, en_C = 1
        3. wb_sel = 1, w_en = 1, w_addr = rd
    SUB: 0110001
        same as ADD, ALU_op = 001
    CMP: 0110010
        same as SUB, en_status = 1
    AND: 0110011
        same as ADD, ALU_op = 010
    ORR: 0110100
        same as ADD, ALU_op = 011
    EOR: 0110101 == XOR
        same as ADD, ALU_op = 111
    MOV: 0111000
        1. B_addr = rm, en_B = 1, shift_addr = rs, sel_shift = 1, en_S = 1
        2. shift_op = 0, sel_A = 1, sel_B = 0, ALU_op = 000, en_C = 1
        3. wb_sel = 1, w_en = 1, w_addr = rd
    LSL: 0111001
        1. B_addr = rm, en_B = 1, shift_addr = rs, sel_shift = 1, en_S = 1
        2. shift_op = 0, sel_A = 1, sel_B = 0, ALU_op = 000, en_C = 1
        3. wb_sel = 1, w_en = 1, w_addr = rd
    LSR: 0111010
        same as LSL, shift_op = 1
    ASR: 0111011
        same as LSL, shift_op = 2
    ROR: 0111100
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

    // localparam for states
    localparam [2:0] reset = 3'd0;
    localparam [2:0] fetch = 3'd1;
    localparam [2:0] load_A_B_shift = 3'd2;
    localparam [2:0] update_regs_status = 3'd3;
    localparam [2:0] finish = 3'd4; //temp state

    // localparam for specific instructions
    localparam [6:0] NOP = 7'b0000000;
    localparam [6:0] HLT = 7'b0000001;
    localparam [6:0] MOV_I = 7'b0001000;
    localparam [2:0] CMP = 4'b0010; //some overlap with none but should be fine

    // localparam for ALU_op
    localparam [2:0] ADD = 3'b000;
    localparam [2:0] SUB = 3'b001;
    localparam [2:0] AND = 3'b010;
    localparam [2:0] ORR = 3'b011;
    localparam [2:0] XOR = 3'b111;

    // reg for state
    reg [2:0] state;

    // reg for output
    reg waiting_reg;
    reg [1:0] wb_sel_reg;
    reg sel_A_reg;
    reg sel_B_reg;
    reg sel_shift_reg;
    reg w_en_reg;
    reg en_A_reg;
    reg en_B_reg;
    reg en_C_reg;
    reg en_S_reg;
    reg [2:0] ALU_op_reg;
    reg load_ir_reg;
    reg load_pc_reg;
    reg clear_pc_reg;
    reg load_addr_reg;
    reg sel_addr_reg;
    reg ram_w_en_reg;

    // assign output
    assign waiting = waiting_reg;
    assign wb_sel = wb_sel_reg;
    assign sel_A = sel_A_reg;
    assign sel_B = sel_B_reg;
    assign sel_shift = sel_shift_reg;
    assign w_en = w_en_reg;
    assign en_A = en_A_reg;
    assign en_B = en_B_reg;
    assign en_C = en_C_reg;
    assign en_S = en_S_reg;
    assign ALU_op = ALU_op_reg;
    assign load_ir = load_ir_reg;
    assign load_pc = load_pc_reg;
    assign clear_pc = clear_pc_reg;
    assign load_addr = load_addr_reg;
    assign sel_addr = sel_addr_reg;
    assign ram_w_en = ram_w_en_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            state <= reset;
        end else begin
            case (state)
                reset: begin
                    state <= fetch;
                end
                fetch: begin
                    state <= load_A_B_shift;
                end
                load_A_B_shift: begin
                    state <= update_regs_status;
                end
                update_regs_status: begin
                    state <= finish;
                end
                finish : begin
                    state <= finish;
                end
                default: begin
                    state <= reset;
                end
            endcase
        end
    end

    always_comb begin
        // please take the above signal and concat it like so {waiting, wb_sel, sel_A, ...} = number is bits'd0;
        {waiting_reg, wb_sel_reg, sel_A_reg, sel_B_reg, sel_shift_reg, w_en_reg, en_A_reg, en_B_reg, en_C_reg, en_S_reg, ALU_op_reg, load_ir_reg, load_pc_reg, clear_pc_reg, load_addr_reg, sel_addr_reg, ram_w_en_reg} = 19'b0;
        // then assign the signal to the output
        case (state)
            reset: begin
                waiting_reg = 1'b1;
            end
            fetch: begin
                waiting_reg = 1'b1;
                load_ir_reg = 1'b1;

                //also when you change sel_shift
            end
            load_A_B_shift: begin
                waiting_reg = 1'b1;
                /*
                take care of:
                - sel_shift
                - en_A
                - en_B
                - en_S
                - A_addr
                - B_addr
                - shift_addr
                - sel_A
                - sel_B
                - ALU_op
                */
                //normal instructions
                if (opcode[6] == 0 && cond != 4'b1111)  begin
                    //loads A
                    if (opcode[3] == 1) begin
                        en_A_reg = 1'b1;
                    end

                    //load B
                    if (opcode[4] == 1'b1) begin
                        en_B_reg = 1'b1;
                    end

                    //load shift
                    if (opcode[4] == 1'b1) begin
                        en_S_reg = 1'b1;
                        sel_shift_reg = opcode[5];
                    end

                    //sel_A
                    if (opcode[3] == 1'b1) begin
                        sel_A_reg = 1'b1;
                    end

                    //sel_B
                    if (opcode[4] == 1'b1) begin
                        sel_B_reg = 1'b1;
                    end

                    //ALU_op
                    case (opcode[2:0])
                        3'b000: ALU_op_reg = ADD;
                        3'b001: ALU_op_reg = SUB;
                        3'b010: ALU_op_reg = SUB;
                        3'b011: ALU_op_reg = AND;
                        3'b100: ALU_op_reg = ORR;
                        3'b101: ALU_op_reg = XOR;
                        default: ALU_op_reg = ADD;
                    endcase
                end
            end
            update_regs_status: begin
                waiting_reg = 1'b1;
                /*
                take care of:
                - wb_sel
                - w_en
                */
                //normal instructions
                if (opcode[6] == 0 && cond != 4'b1111)  begin

                    if (opcode[3:0] != CMP) begin
                        //wb_sel
                        wb_sel_reg = 1'b0;

                        //w_en
                        w_en_reg = 1'b1;

                        //w_addr is taken from decoder
                    end
                end
            end
        endcase
    end

endmodule: controller