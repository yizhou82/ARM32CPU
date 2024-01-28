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
    output [23:0] imm24,    // Address for branching
    output P,
    output U,
    output W
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
    assign P = instr[24];
    assign U = instr[23];
    assign W = instr[21];

    always_comb begin

        cond_reg = instr[31:28];
        rn_reg = instr[19:16];
        rd_reg = instr[15:12];
        rs_reg = instr[11:8];
        rm_reg = instr[3:0];
        shift_op_reg = instr[6:5];
        imm5_reg = instr[11:7];
        imm12_reg = instr[11:0];
        imm24_reg = instr[23:0];
        en_status_reg = instr[20];

        case (instr[27:26])
            2'b00: begin // Data
                if(instr[27:21] == 7'b0011001) begin // NOP
                    opcode_reg = 7'b0000000; // WILL CHANGE LATER
                end else if(instr[27:21] == 7'b0001000) begin // HALT
                    opcode_reg = 7'b0000001; //WILL CHANGE LATER
                end else if(instr[27:21] == 7'b0001001) begin // BX and BLX
                    if(instr[5] == 1'b0) begin // BX
                        opcode_reg = 7'b1000001;
                    end else begin // BLX
                        opcode_reg = 7'b1000101;
                    end
                end else begin
                    if(type_I) begin
                        // Immediate
                        case(instr[24:21])
                            4'b0100: begin // ADD
                                opcode_reg = 7'b0001000;
                            end
                            4'b0010: begin // SUB
                                opcode_reg = 7'b0001001;
                            end
                            4'b1010: begin // CMP
                                opcode_reg = 7'b0001010;
                            end
                            4'b0000: begin // AND
                                opcode_reg = 7'b0001011;
                            end
                            4'b1100: begin // ORR
                                opcode_reg = 7'b0001100;
                            end
                            4'b0001: begin // EOR
                                opcode_reg = 7'b0001101;
                            end
                            4'b1101: begin // MOV 
                                opcode_reg = 7'b0000000;
                            end
                            default: begin // Return HALT if undefined
                                opcode_reg = 7'b0000111;
                            end
                        endcase
                    end else if(type_RS) begin
                        // Register Shifted
                        case(instr[24:21])
                            4'b0100: begin // ADD
                                opcode_reg = 7'b0111000;
                            end
                            4'b0010: begin // SUB
                                opcode_reg = 7'b0111001;
                            end
                            4'b1010: begin // CMP
                                opcode_reg = 7'b0111010;
                            end
                            4'b0000: begin // AND
                                opcode_reg = 7'b0111011;
                            end
                            4'b1100: begin // ORR
                                opcode_reg = 7'b0111100;
                            end
                            4'b0001: begin // EOR
                                opcode_reg = 7'b0111101;
                            end
                            4'b1101: begin // MOV and shifts
                                opcode_reg = 7'b0110000;
                            end
                            default: begin // Return HALT if undefined
                                opcode_reg = 7'b0000001;
                            end
                        endcase
                    end else begin
                        // Register
                        case(instr[24:21])
                            4'b0100: begin // ADD
                                opcode_reg = 7'b0011000;
                            end
                            4'b0010: begin // SUB
                                opcode_reg = 7'b0011001;
                            end
                            4'b1010: begin // CMP
                                opcode_reg = 7'b0011010;
                            end
                            4'b0000: begin // AND
                                opcode_reg = 7'b0011011;
                            end
                            4'b1100: begin // ORR
                                opcode_reg = 7'b0011100;
                            end
                            4'b0001: begin // EOR
                                opcode_reg = 7'b0011101;
                            end
                            4'b1101: begin // MOV and shifts
                                opcode_reg = 7'b0010000;
                            end
                            default: begin // Return HALT if undefined
                                opcode_reg = 7'b0000001;
                            end
                        endcase
                    end 
                end
            end
            // 2'b01: begin // Load/Store
            //     opcode_reg = {3'b101, instr[24:21]};
            // end
            2'b10: begin // Branch
                if(instr[25:24] == 4'b10) begin
                    case(instr[31:28])
                        // 4'b0000: begin // BEQ
                        //     opcode_reg = 7'b1000100;
                        // end
                        // 4'b0001: begin // BNE
                        //     opcode_reg = 7'b1000101;
                        // end
                        default: begin // B
                            opcode_reg = 7'b1000000;
                        end
                    endcase
                end else begin // BL
                    opcode_reg = 7'b1000100;
                end
            end
            2'b01: begin //load and str
            opcode_reg = {4'b0000, P, U, W};
            if (instr[20] == 1'b1) begin //LDR
                case (instr[25])
                1'b0: begin     //LIT
                    if (instr[19:16] == 4'b1111) begin
                        opcode_reg[6:3] = 4'b1000;
                    end else begin  //Immediate
                        opcode_reg[6:3] = 4'b1100;
                    end
                end
                default: begin
                    opcode_reg[6:3] = 4'b1101;
                end
                endcase
            end else begin //STR
                case (instr[25])
                1'b0: begin     //Immediate
                    opcode_reg[6:3] = 4'b1110;
                end
                default: begin
                    opcode_reg[6:3] = 4'b1111; 
                end
                endcase
            end
            end
            default: begin // Return HALT if undefined
                opcode_reg = 7'b0000001;
            end
        endcase
    end

endmodule: idecoder