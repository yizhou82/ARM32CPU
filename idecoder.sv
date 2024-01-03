module idecoder(
    input [31:0] ir,        // 32-bit ARM instruction
    output [3:0] cond,      // Condition code (0000 = EQ, 0001 = NE, rest irrelevant)
    output [1:0] types,      // Instruction type (00 = data processing, 01 = load/store, 10 = branch, 11 = other)
    output [3:0] opcode,    // Opcode for the instruction
    output [3:0] rn,        // Rn
    output [3:0] rd,        // Rd (destination)
    output [3:0] rs,        // Rs
    output [3:0] rm,        // Rm 
    output [3:0] rt,        // Rt (used in load/store)
    output [11:0] operand2, // Immediate value or second operand
    output [1:0] shift_op,  // Shift operation (00 = logical left, 01 = logical right, 10 = arithmetic right, 11 = rotate right)
    output [23:0] address,  // Address for branching
);

reg [3:0] cond_reg, opcode_reg, rn_reg, rd_reg, rs_reg, rm_reg, rt_reg;
reg [1:0] type_reg, shift_op_reg;
reg [11:0] operand2_reg;
reg [23:0] address_reg;

assign cond = cond_reg;
assign types = types_reg;
assign opcode = opcode_reg;
assign rn = rn_reg;
assign rd = rd_reg;
assign rs = rs_reg;
assign rm = rm_reg;
assign rt = rt_reg;
assign operand2 = operand2_reg;
assign shift_op = shift_op_reg;
assign address = address_reg;

assign bit25 = ir[25];
assign bit4 = ir[4];
assign bit20 = ir[20];
assign bit25 = ir[25];

assign types = ir[27:26];

//ALL OLD CHANGE STUFF

endmodule: idecoder