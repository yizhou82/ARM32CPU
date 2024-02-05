module datapath(input clk, input [31:0] ram_data2, input forward_w_data, input sel_w_addr1,
                input [3:0] w_addr1, input w_en1, input [3:0] w_addr2, input w_en2, input [3:0] w_addr3, input w_en3,                           //regfile write inputs
                input [31:0] w_data3, input [3:0] A_addr, input [3:0] B_addr, input [3:0] shift_addr, input [3:0] str_addr,                     //end of regfile inputs
                input [1:0] sel_pc, input load_pc, input [10:0] start_pc,                                                                       //pc inputs
                input [1:0] sel_A_in, input [1:0] sel_B_in, input [1:0] sel_shift_in,    //inputs for forwarding muxes
                input en_A, input en_B, input [31:0] shift_imme, input sel_shift,
                input [1:0] shift_op, input en_S,
                input sel_A, input sel_B, input sel_post_indexing, input [31:0] imme_data,
                input [2:0] ALU_op, input en_status, input status_rdy,                                                //datapath inputs
                output [31:0] datapath_out, output [31:0] status_out, output [31:0] str_data, output [10:0] PC);      //datapath outputs
  
    // --- internal wires ---
    //regfile
    wire [31:0] A_data, B_data, shift_data, w_data1;
    wire [3:0] w_addr1_in;
    wire [10:0] pc_out;
    //shifter
    wire [31:0] shift_out;
    //register ALU
    wire [31:0] val_A, val_B, ALU_out, shift_amt, status_in;
    //forwarding muxes
    reg [31:0] A_in, B_in, shift_in;

    // --- internal regs ---
    reg [31:0] A_reg, B_reg, S_reg, status_out_reg;

    // internal connections
    assign status_out = status_out_reg;

    //internal modules
    regfile regfile(.clk(clk), .w_data1(w_data1), .w_addr1(w_addr1_in), .w_en1(w_en1), .w_data2(ALU_out),
                    .w_addr2(w_addr2), .w_en2(w_en2), .w_data3(w_data3), .w_addr3(w_addr3), .w_en3(w_en3), 
                    .sel_pc(sel_pc), .load_pc(load_pc), .start_pc(start_pc), .dp_pc(ALU_out[10:0]),
                    .A_addr(A_addr), .B_addr(B_addr), .shift_addr(shift_addr), .str_addr(str_addr),
                    .A_data(A_data), .B_data(B_data), .shift_data(shift_data), .str_data(str_data), .pc_out(pc_out));
    shifter shifter(.shift_in(B_reg), .shift_op(shift_op), .shift_amt(S_reg), .shift_out(shift_out));
    ALU alu(.val_A(val_A), .val_B(val_B), .ALU_op(ALU_op), .ALU_out(ALU_out), .flags(status_in));
    status_reg_block status_reg(.clk(clk), .en_status(en_status), .status_rdy(status_rdy), .status_in(status_in), .status_out(status_out_reg));

    //muxes
    assign datapath_out = (sel_post_indexing == 1'b1) ? val_A : ALU_out;
    assign w_data1 = (forward_w_data == 1'b1) ? ram_data2 : ALU_out;
    assign w_addr1_in = (sel_w_addr1 == 1'b1) ? 4'd14 : w_addr1;
    assign val_A = (sel_A == 1'b1) ? 31'b0 : A_reg;
    assign val_B = (sel_B == 1'b1) ? imme_data : shift_out; 
    assign shift_amt = (sel_shift == 1'b1) ? shift_in: shift_imme;
    //A_mux
    always_comb begin
        case (sel_A_in)
            2'b00: A_in = A_data;
            2'b01: A_in = ALU_out;
            2'b11: A_in = pc_out;
            default: A_in = A_data;
        endcase
    end
    // B_in mux
    always_comb begin
        case (sel_B_in)
            2'b00: B_in = B_data;
            2'b01: B_in = ALU_out;
            2'b11: B_in = val_B;
            default: B_in = B_data;
        endcase
    end
    //shift_in mux
    always_comb begin
        case (sel_shift_in)
            2'b00: shift_in = shift_data;
            2'b01: shift_in = ALU_out;
            2'b11: shift_in = 32'b0;
            default: shift_in = shift_data;
        endcase
    end

    //register A
    always_ff @(posedge clk) begin
        if (en_A == 1'b1) begin
            A_reg <= A_in;
        end
    end

    //register B
    always_ff @(posedge clk) begin
        if (en_B == 1'b1) begin
            B_reg <= B_in;
        end
    end

    //register S
    always_ff @(posedge clk) begin
        if (en_S == 1'b1) begin
            S_reg <= shift_amt;
        end
    end
endmodule: datapath
