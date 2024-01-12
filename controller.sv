module controller(input clk, input rst_n,
                input [6:0] opcode, input [31:0] status_reg, input [3:0] cond,
                output waiting,
                output wb_sel, output sel_A, output sel_B, output sel_shift, output sel_post_shift,
                output w_en1, , output w_en2, output en_A, output en_B, output en_C, output en_S, output [2:0] ALU_op,
                output load_ir, output load_pc, output clear_pc, //not yet used
                output load_addr, output sel_addr, output ram_w_en);

    /*

    Load/Store Instructions - TBA
    - P = 1 -> Pre-Indexing
    - P = 0 -> Post-Indexing
    - U = 1 -> Offset is positive
    - U = 0 -> Offset is negative
    - W = 1 -> Write back to base register
    - W = 0 -> Do not write back to base register
    */

    // localparam for states

    //move all the local param values 1 value higher
    localparam [2:0] reset = 3'd0;
    localparam [2:0] fetch = 3'd1;
    localparam [2:0] decode = 3'd2;
    localparam [2:0] execute = 3'd3;
    localparam [2:0] memory = 3'd4;
    localparam [2:0] memory_wait = 3'd5;
    localparam [2:0] write_back = 3'd6;

    // localparam for specific instructions
    localparam [6:0] NOP = 7'b0000000;
    localparam [6:0] HLT = 7'b0000001;
    localparam [2:0] CMP = 4'b0010; //some overlap with none but should be fine

    // localparam for ALU_op
    localparam [2:0] ADD = 3'b000;
    localparam [2:0] SUB = 3'b001;
    localparam [2:0] AND = 3'b010;
    localparam [2:0] ORR = 3'b011;
    localparam [2:0] XOR = 3'b111;

    // reg for state
    reg [2:0] state;
    reg start = 1'b0;

    // reg for output
    reg waiting_reg;
    reg [1:0] wb_sel_reg;
    reg sel_A_reg;
    reg sel_B_reg;
    reg sel_shift_reg;
    reg sel_post_shift_reg;
    reg w_en1_reg;
    reg w_en2_reg;
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
    assign sel_post_shift = sel_post_shift_reg;
    assign w_en1 = w_en1_reg;
    assign w_en2 = w_en2_reg;
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
        if (rst_n == 1'b0 && start == 1'b0) begin
            state <= reset;
            start <= 1'b1;
        end else begin
            case (state)
                reset: begin
                    state <= fetch;
                end
                fetch: begin
                    state <= decode;
                end
                decode: begin
                    state <= execute;
                end
                execute: begin
                    state <= memory;
                end
                memory: begin
                    state <= memory_wait;
                end
                memory_wait: begin
                    state <= write_back;
                end
                write_back: begin
                    state <= fetch;
                    start <= 1'b0; //end of cycle
                end
                default: begin
                    state <= reset;
                    start <= 1'b0;
                end
            endcase
        end
    end

    always_comb begin
        // please take the above signal and concat it like so {waiting, wb_sel, sel_A, ...} = number is bits'd0;
        {waiting_reg, wb_sel_reg, sel_A_reg, sel_B_reg, sel_shift_reg, sel_post_shift_reg, w_en1_reg, w_en2_reg, en_A_reg, en_B_reg, en_C_reg, en_S_reg, load_ir_reg, load_pc_reg, clear_pc_reg, load_addr_reg, sel_addr_reg, ram_w_en_reg, ALU_op_reg} = 21'b0;
        
        // then assign the signal to the output
        case (state)
            reset: begin
                waiting_reg = 1'b1;
            end
            fetch: begin        //fetch from ram
                waiting_reg = 1'b1;
                load_ir_reg = 1'b1;
            end
            decode: begin
                waiting_reg = 1'b1;
                load_ir_reg = 1'b1;

                //also when you change sel_shift
            end
            execute: begin
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
                    if (opcode[3] == 1'b1) begin
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
                end
            end
            memory: begin
                //deal with memory if necessary
            end
            memory_wait: begin
                waiting_reg = 1'b1;
                //just a stall for LDR to read from memory
            end
            write_back: begin
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

                        //w_en1
                        w_en_reg = 1'b1;

                        //w_addr is taken from decoder
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

                    //sel_A -> opposite of load A
                    if (opcode[3] == 1'b0) begin
                        sel_A_reg = 1'b1;
                    end

                    //sel_B -> opposite of load B
                    if (opcode[4] == 1'b0) begin
                        sel_B_reg = 1'b1;
                    end
                end
            end
        endcase
    end

endmodule: controller