module regfile(input [31:0] w_data1, input [3:0] w_addr1, input w_en1, input clk,
            input [31:0] w_data2, input [3:0] w_addr2, input w_en2,
            input [3:0] A_addr, input [3:0] B_addr, input [3:0] shift_addr,
            output [31:0] A_data, output [31:0] B_data, output [31:0] shift_data);

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

    reg [31:0] regsiteres[0:15];

    // read is combinational
    assign A_data = regsiteres[A_addr];
    assign B_data = regsiteres[B_addr];
    assign shift_data = regsiteres[shift_addr];

    // write is sequential
    always_ff @(posedge clk) begin
        if (w_en1 == 1'b1) begin
            regsiteres[w_addr1] = w_data1;
        end

        if (w_en2 == 1'b1) begin
            regsiteres[w_addr2] = w_data2;
        end
    end
endmodule: regfile
