module cpu (input clk, input rst_n, input [31:0] instr,
            output waiting, output [31:0] status_out, output [31:0] datapath_out);

    // idecoder outputs
    reg [31:0] instr_reg;
    wire [3:0] cond;
    wire [6:0] opcode;
    wire en_status;
    wire [3:0] rn;
    wire [3:0] rd;
    wire [3:0] rs;
    wire [3:0] rm;
    wire [1:0] shift_op;
    wire [4:0] imm5;
    wire [11:0] imm12;
    wire [23:0] imm24;

    // datapath outputs
    wire [31:0] status_out_dp;
    wire [31:0] datapath_out_dp;

    assign status_out = status_out_dp;
    assign datapath_out = datapath_out_dp;

    // controller outputs
    wire waiting_ctrl;
    wire wb_sel;
    wire sel_A;
    wire sel_B;
    wire sel_shift;
    wire w_en;
    wire en_A;
    wire en_B;
    wire en_C;
    wire en_S;
    wire [2:0] ALU_op;
    wire load_ir;
    wire load_pc;
    wire clear_pc;
    wire load_addr;
    wire sel_addr;
    wire ram_w_en;

    assign waiting = waiting_ctrl;

    // idecoder module
    idecoder idecoder(
        .instr(instr_reg),
        .cond(cond),
        .opcode(opcode),
        .en_status(en_status),
        .rn(rn),
        .rd(rd),
        .rs(rs),
        .rm(rm),
        .shift_op(shift_op),
        .imm5(imm5),
        .imm12(imm12),
        .imm24(imm24)
    );

    // datapath module
    datapath datapath(
        .clk(clk),
        .datapath_in(datapath_out), //TODO: Probably dont need this at all???
        .wb_sel(wb_sel),
        .w_addr(rd),
        .w_en(w_en),
        .A_addr(rn),
        .B_addr(rm),
        .shift_addr(rs),
        .en_A(en_A),
        .en_B(en_B),
        .en_S(en_S),
        .shift_op(shift_op),
        .shift_imme({27'd0, imm5}),
        .sel_shift(sel_shift),
        .sel_A(sel_A),
        .sel_B(sel_B),
        .imme_data({20'd0, imm12}),
        .ALU_op(ALU_op),
        .en_status(en_status),
        .datapath_out(datapath_out_dp),
        .status_out(status_out_dp)
    );

    // controller module
    controller controller(
        .clk(clk),
        .rst_n(rst_n),
        .opcode(opcode),
        .status_reg(status_out_dp),
        .cond(cond),
        .waiting(waiting_ctrl),
        .wb_sel(wb_sel),
        .sel_A(sel_A),
        .sel_B(sel_B),
        .sel_shift(sel_shift),
        .w_en(w_en),
        .en_A(en_A),
        .en_B(en_B),
        .en_C(en_C),
        .en_S(en_S),
        .ALU_op(ALU_op),
        .load_ir(load_ir),
        .load_pc(load_pc),
        .clear_pc(clear_pc),
        .load_addr(load_addr),
        .sel_addr(sel_addr),
        .ram_w_en(ram_w_en)
    );

    // register for instruction
    always_ff @(posedge clk) begin
        if (load_ir == 1'b1) begin
            instr_reg <= instr;
        end
    end

endmodule: cpu