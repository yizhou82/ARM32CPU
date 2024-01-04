module idecoder(
    input [31:0] instr,     // 32-bit ARM instruction
    output [3:0] cond,      // Condition code
    output [6:0] opcode,    // Opcode for the instruction
    output en_status,       // Enable status register
    output [3:0] rn,        // Rn
    output [3:0] rd,        // Rd (destination)
    output [3:0] rs,        // Rs
    output [3:0] rm,        // Rm 
    output [1:0] shift_op,  // Shift operation
    output [4:0] imm5,      // Immediate value
    output [11:0] imm12,    // Immediate value or second operand
    output [23:0] imm24    // Address for branching
);

    reg en_status_reg;
    reg [1:0] shift_op_reg;
    reg [3:0] cond_reg, rn_reg, rd_reg, rs_reg, rm_reg;
    reg [6:0] opcode_reg;
    reg [4:0] imm5_reg;
    reg [11:0] imm12_reg;
    reg [23:0] imm24_reg;

    assign en_status = en_status_reg;
    assign shift_op = shift_op_reg;
    assign cond = cond_reg;
    assign rn = rn_reg;
    assign rd = rd_reg;
    assign rs = rs_reg;
    assign rm = rm_reg;
    assign opcode = opcode_reg;
    assign imm5 = imm5_reg;
    assign imm12 = imm12_reg;
    assign imm24 = imm24_reg;

    assign type_I = instr[25];
    assign type_RS = instr[4];

    always_comb begin

        cond_reg = instr[31:28];
        rn_reg = instr[19:16];
        rd_reg = instr[15:12];
        rs_reg = instr[11:8];
        rm_reg = instr[3:0];
        shift_op_reg = instr[7:6];
        imm5_reg = instr[4:0];
        imm12_reg = instr[11:0];
        imm24_reg = instr[23:0];
        en_status_reg = instr[20];

        case (instr[27:26])
            2'b00: begin // Data
                if(instr[27:21] == 7'b0011001 || instr[27:21] == 7'b0001000) begin // NOP and HALT
                    opcode_reg = {3'b000, instr[24:21]};
                end else begin
                    if(type_I) begin
                        opcode_reg = {3'b001, instr[24:21]}; // Immediate
                    end else if(type_RS) begin
                        opcode_reg = {3'b011, instr[24:21]}; // Register Shifted
                    end else begin
                        opcode_reg = {3'b010, instr[24:21]}; // Register
                    end 
                end
            end
            2'b01: begin // Load/Store
                opcode_reg = {3'b101, instr[24:21]};
            end
            2'b10: begin // Branch
                opcode_reg = {4'b1000, instr[23:21]};
            end
            default: begin // Undefined
                opcode_reg = 7'b1010000;
            end
        endcase
    end

endmodule: idecoder