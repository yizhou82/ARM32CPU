module datapath(input clk, input wb_sel, input [3:0] A_addr, input [3:0] B_addr, input [3:0] shift_addr, 
                input en_A, input en_B, input en_S, input [1:0] shift_op, input [31:0] shift_imme,
                input sel_shift, input sel_A, input sel_B,
                input [31:0] imme_data, input [2:0] ALU_op, input en_status,
                output [31:0] datapath_out, output [31:0] status_out);
  
    // --- internal wires ---
    //regfile
    wire [31:0] w_data, A_data, B_data, shift_data;
    //shifter
    wire [31:0] shift_out, shift_in;
    //register ALU
    wire [31:0] val_A, val_B, val_B_in, ALU_out, shift_amt, status_in, A_in, B_in, shift_in;

    // --- internal regs ---
    reg [31:0] A_reg, B_reg, S_reg, status_reg;

    // internal connections
    assign status_out = status_reg;
    assign datapath_out = ALU_out;

    //internal modules
    regfile regfile(.w_data1(w_data1), .w_addr1(w_addr1), .w_en1(w_en1), .w_data2(val_B_in),
                    .w_addr2(w_addr2), .w_en2(w_en2), .clk(clk), .A_addr(A_addr), .B_addr(B_addr),
                    .shift_addr(shift_addr), .A_data(A_data), .B_data(B_data), .shift_data(shift_data));
    shifter shifter(.shift_in(B_reg), .shift_op(shift_op), .shift_amt(S_reg), .shift_out(shift_out));
    ALU alu(.val_A(val_A), .val_B(val_B), .ALU_op(ALU_op), .ALU_out(ALU_out), .flags(status_in));

    //muxes
    assign w_data = ALU_out;
    assign val_A = (sel_A == 1'b1) ? 31'b0 : A_reg;
    assign val_B_in = (sel_B == 1'b1) ? imme_data : shift_out; 
    assign shift_amt = (sel_shift == 1'b0) ? shift_imme : shift_data;
    assign val_B = (sel_post_shift == 1'b1) ? B_reg : val_B_in;
    assign A_in = (1'b0) ? ALU_out : A_data; //only change during pipeline
    assign shift_in = (1'b0) ? ALU_out : shift_data; //only change during pipeline

    always_comb begin
        if (1'b0) begin //only change during pipeline
            B_in = ALU_out;
        end
        else if (1'b0) begin //onlt change during pipeline
            B_in = val_B;
        end else begin
            B_in = B_data
        end
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

    //register status
    always_ff @(posedge clk) begin
        if (en_status == 1'b1) begin
            status_reg <= status_in;
        end
    end
endmodule: datapath
