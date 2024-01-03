module datapath(input clk, input [31:0] datapath_in, input wb_sel,
                input [3:0] w_addr, input w_en, input [3:0] A_addr, input [3:0] B_addr, input [3:0] shift_addr, 
                input en_A, input en_B, input [1:0] shift_op, input shift_imme[31:0], input sel_shift, input sel_A, input sel_B,
                input imme_data[31:0], input [2:0] ALU_op, input en_C, input en_status,
                output [31:0] datapath_out, output [31:0] status_out);
  
    // --- internal wires ---
    //regfile
    wire [31:0] w_data, A_data, B_data, shift_data;
    //shifter
    wire [31:0] shift_out, shift_in;
    //register ALU
    wire [31:0] val_A, val_B, ALU_out, status_amt;

    // --- internal regs ---
    reg [31:0] A_reg, B_reg, C_reg, status_reg, S_reg;

    // internal connections
    assign status_out = status_reg;
    assign datapath_out = C_reg;

    //internal modules
    regfile regfile(.w_data(w_data), .w_addr(w_addr), .w_en(w_en), .clk(clk), .A_addr(A_addr), .B_addr(B_addr),
                    .shift_addr(shift_addr), .A_data(A_data), .B_data(B_data), .shift_data(shift_data));
    shifter shifter(.shift_in(B_reg), .shift_op(shift_op), shift_amt(S_reg), .shift_out(shift_out));
    ALU alu(.val_A(val_A), .val_B(val_B), .ALU_op(ALU_op), .ALU_out(ALU_out), .flags(status_in));

    //muxes
    assign w_data = (wb_sel == 1'b1) ? datapath_in : C_reg;
    assign val_A = (sel_A == 1'b1) ? 31'b0 : A_reg;
    assign val_B = (sel_B == 1'b1) ? imme_data : shift_out; 
    assign shift_amt = (sel_shift == 1'b0) ? shift_imme : shift_data;

    //register A
    always_ff @(posedge clk) begin
        if (en_A == 1'b1) begin
            A_reg <= r_data;
        end
    end

    //register B
    always_ff @(posedge clk) begin
        if (en_B == 1'b1) begin
            B_reg <= r_data;
        end
    end

    //register C
    always_ff @(posedge clk) begin
        if (en_C == 1'b1) begin
            C_reg <= ALU_out;
        end
    end

    //register status
    always_ff @(posedge clk) begin
        if (en_status == 1'b1) begin
            status_reg <= status_in;
        end
    end

    always_comb begin

    end
endmodule: datapath
