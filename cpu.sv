module cpu (input clk, input rst_n, input [31:0] instr, input [31:0] ram_data2, input [31:0] PC,
            output waiting, output [1:0] sel_pc, output [10:0] memory_out, 
            output ram_w_en1, output ram_w_en2, output [10:0] ram_addr1, output [10:0] ram_addr2, output [31:0] ram_in2,
            output [31:0] status_out, output [31:0] datapath_out);

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
    wire P,U,W;

    // datapath outputs
    wire [31:0] status_out_dp;
    wire [31:0] datapath_out_dp;
    wire [10:0] memory_out_dp;
    assign status_out = status_out_dp;
    assign datapath_out = datapath_out_dp;
    assign memory_out = memory_out_dp;

    // controller outputs
    wire waiting_ctrl;
    wire w_en1, w_en2, sel_w_data;
    wire [1:0] sel_A_in, sel_B_in, sel_shift_in;
    wire sel_shift;
    wire wb_sel;
    wire en_A, en_B, en_C, en_S;
    wire sel_A, sel_B, sel_post_shift;
    wire [2:0] ALU_op;
    wire en_out1, en_out2, en_status1, en_status2;
    wire load_ir, load_pc;
    wire [1:0] sel_pc_ctrl;
    wire sel_ram_addr2;
    wire [10:0] ram_addr1_ctrl, ram_addr2_ctrl;
    wire ram_w_en1_ctrl, ram_w_en2_ctrl;
    assign waiting = waiting_ctrl;
    assign sel_pc = sel_pc_ctrl;
    assign ram_w_en1 = ram_w_en1_ctrl;
    assign ram_w_en2 = ram_w_en2_ctrl;
    assign ram_addr1 = 32'd0;
    assign ram_addr2 = ram_addr2_ctrl;
    assign ram_in2 = 32'd0; //TODO: Rt

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
        .imm24(imm24),
        .P(P),
        .U(U),
        .W(W)
    );

    // datapath module
    datapath datapath(
        .clk(clk),
        .ram_data2(ram_data2),
        .sel_w_data(sel_w_data),
        .w_addr1(rd),
        .w_en1(w_en1),
        .w_addr2(rd),
        .w_en2(w_en2),
        .A_addr(rn),
        .B_addr(rm),
        .shift_addr(rs),
        //need rt for load/store
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
        .en_out1(en_out1),
        .en_out2(en_out2),
        .en_status1(en_status1),
        .en_status2(en_status2),
        .datapath_out(datapath_out_dp),
        .memory_out(memory_out_dp),
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
        .w_en1(w_en1),
        .w_en2(w_en2),
        .sel_w_data(sel_w_data),
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
        .en_out1(en_out1),
        .en_out2(en_out2),
        .en_status1(en_status1),
        .en_status2(en_status2),
        .load_ir(load_ir),
        .load_pc(load_pc),
        .sel_pc(sel_pc_ctrl),
        .sel_ram_addr2(sel_ram_addr2),
        .ram_addr1(ram_addr1_ctrl),
        .ram_addr2(ram_addr2_ctrl),
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