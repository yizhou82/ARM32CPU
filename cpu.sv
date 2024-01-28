module cpu (input clk, input rst_n, input [31:0] instr, input [31:0] ram_data2, input [31:0] PC,
            output waiting, output [1:0] sel_pc, output load_pc, output [10:0] dp_pc,
            output ram_w_en1, output ram_w_en2, output [10:0] ram_addr2, output [31:0] ram_in2,
            output [31:0] status_out, output [31:0] datapath_out); //TODO: status_out may be removed

    // idecoder outputs
    reg [31:0] instr_reg;
    wire [3:0] cond;
    wire [6:0] opcode;
    wire en_status_decode;
    wire [3:0] rn;
    wire [3:0] rd;
    wire [3:0] rt;
    wire [3:0] rs;
    wire [3:0] rm;
    wire [1:0] shift_op;
    wire [4:0] imm5;
    wire [11:0] imm12;
    wire [23:0] imm24;
    wire P,U,W;
    assign rt = rd;

    // datapath outputs
    wire [31:0] status_out_dp;
    wire [31:0] datapath_out_dp;
    wire [31:0] str_data_dp;
    assign status_out = status_out_dp;
    assign datapath_out = datapath_out_dp;
    assign dp_pc = datapath_out_dp[10:0];
    assign ram_addr2 = datapath_out_dp[10:0];
    assign ram_in2 = str_data_dp;

    // controller outputs
    wire waiting_ctrl;
    wire w_en1, w_en2, w_en3, forward_w_data;
    wire [1:0] sel_A_in, sel_B_in, sel_shift_in;
    wire sel_shift;
    wire wb_sel;
    wire en_A, en_B, en_C, en_S;
    wire sel_A, sel_B, sel_post_shift;
    wire [2:0] ALU_op;
    wire en_status, status_rdy_ctrl;
    wire load_ir, load_pc_ctrl;
    wire [1:0] sel_pc_ctrl;
    wire [10:0] ram_addr1_ctrl, ram_addr2_ctrl;
    wire ram_w_en1_ctrl, ram_w_en2_ctrl;
    assign waiting = waiting_ctrl;
    assign sel_pc = sel_pc_ctrl;
    assign ram_w_en1 = ram_w_en1_ctrl;
    assign ram_w_en2 = ram_w_en2_ctrl;
    assign load_pc = load_pc_ctrl;

    // idecoder module
    idecoder idecoder(
        .instr(instr_reg),
        .cond(cond),
        .opcode(opcode),
        .en_status(en_status_decode),
        .rn(rn),
        .rd(rd),
        .rs(rs),
        .rm(rm),
        .shift_op(shift_op),
        .imm5(imm5),
        .imm12(imm12),
        .imm24(imm24),
        .P(P),
        .U(U),
        .W(W)
    );

    // datapath module
    datapath datapath(
        .clk(clk),
        .ram_data2(ram_data2),
        .forward_w_data(forward_w_data),
        .w_addr1(rd),
        .w_en1(w_en1),
        .w_addr2(rd),
        .w_en2(w_en2),
        .w_addr3(rt),   //for LDR
        .w_en3(w_en3),
        .w_data3(ram_data2),  //for LDR
        .A_addr(rn),
        .B_addr(rm),
        .shift_addr(rs),
        .str_addr(rt),
        .PC(PC),
        .sel_A_in(sel_A_in),
        .sel_B_in(sel_B_in),
        .sel_shift_in(sel_shift_in),
        .en_A(en_A),
        .en_B(en_B),
        .shift_imme({27'd0, imm5}),
        .sel_shift(sel_shift),
        .shift_op(shift_op),
        .en_S(en_S),
        .sel_A(sel_A),
        .sel_B(sel_B),
        .sel_post_shift(sel_post_shift),
        .imme_data({20'd0, imm12}),
        .ALU_op(ALU_op),
        .en_status(en_status),
        .status_rdy(status_rdy_ctrl),
        .datapath_out(datapath_out_dp),
        .status_out(status_out_dp),
        .str_data(str_data_dp)
    );

    // controller module
    controller controller(
        .clk(clk),
        .rst_n(rst_n),
        .opcode(opcode),
        .status_reg(status_out_dp),
        .cond(cond),
        .P(P),
        .U(U),
        .W(W),
        .en_status_decode(en_status_decode),
        .waiting(waiting_ctrl),
        .w_en1(w_en1),
        .w_en2(w_en2),
        .w_en3(w_en3),
        .forward_w_data(forward_w_data),
        .sel_A_in(sel_A_in),
        .sel_B_in(sel_B_in),
        .sel_shift_in(sel_shift_in),
        .sel_shift(sel_shift),
        .en_A(en_A),
        .en_B(en_B),
        .en_C(en_C),
        .en_S(en_S),
        .sel_A(sel_A),
        .sel_B(sel_B),
        .sel_post_shift(sel_post_shift),
        .ALU_op(ALU_op),
        .en_status(en_status),
        .status_rdy(status_rdy_ctrl),
        .load_ir(load_ir),
        .load_pc(load_pc_ctrl),
        .sel_pc(sel_pc_ctrl),
        .ram_w_en1(ram_w_en1_ctrl),
        .ram_w_en2(ram_w_en2_ctrl)
    );

    // register for instruction
    always_ff @(posedge clk) begin
        if (load_ir == 1'b1) begin
            instr_reg <= instr;
        end
    end

endmodule: cpu