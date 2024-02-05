module regfile(input clk, input [31:0] w_data1, input [3:0] w_addr1, input w_en1,
            input [31:0] w_data2, input [3:0] w_addr2, input w_en2,
            input [31:0] w_data3, input [3:0] w_addr3, input w_en3,
            input [3:0] A_addr, input [3:0] B_addr, input [3:0] shift_addr, input [3:0] str_addr,
            input [1:0] sel_pc, input load_pc, input [10:0] start_pc, input [10:0] dp_pc,
            output [31:0] A_data, output [31:0] B_data, output [31:0] shift_data, output [31:0] str_data, output [10:0] pc_out);

    /*
    *** About ***
    - 17 regsiteres 32 bits each
    - 4 bits for address
    - 32 bits for data
    - read is combinational
    - write is sequential

    *** Registers ***
    R0 - General Purpose
    R1 - General Purpose
    R2 - General Purpose
    R3 - General Purpose
    R4 - General Purpose
    R5 - General Purpose
    R6 - General Purpose
    R7 - Holds System Call Number
    R8 - General Purpose
    R9 - General Purpose
    R10 - General Purpose
    R11 - Frame Pointer (FP)
    R12 - Intra Procedural Call (IP)
    R13 - Stack Pointer (SP)
    R14 - Link Register (LR)
    R15 - Program Counter (PC)

    --- Removed to be direct output of datapath ---
    R16 - Status Register (SR)
    */

    reg [31:0] registeres[0:15];
    wire [10:0] pc_in;

    // read is combinational
    assign A_data = registeres[A_addr];
    assign B_data = registeres[B_addr];
    assign shift_data = registeres[shift_addr];
    assign str_data = registeres[str_addr];
    assign pc_out = registeres[4'd15];
    assign pc_in = pc_out + 1;

    // write is sequential
    always_ff @(posedge clk) begin
        if (w_en1 == 1'b1) begin
            registeres[w_addr1] = w_data1;
        end

        if (w_en2 == 1'b1) begin
            registeres[w_addr2] = w_data2;
        end

        if (w_en3 == 1'b1) begin
            registeres[w_addr3] = w_data3;
        end

        if (load_pc == 1'b1) begin
            case (sel_pc)
                2'b01: begin
                    registeres[4'd15] <= start_pc;
                end
                2'b11: begin
                    registeres[4'd15] <= dp_pc;
                end
                default: registeres[4'd15] <= pc_in;
            endcase
        end
    end
endmodule: regfile
