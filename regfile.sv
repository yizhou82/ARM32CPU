module regfile(input [31:0] w_data, input [3:0] w_addr, input w_en, input [3:0] r_addr, input clk, output [31:0] r_data);

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
    assign r_data = regsiteres[r_addr];

    // write is sequential
    always_ff @(posedge clk) begin
        if (w_en == 1'b1) begin
            regsiteres[w_addr] = w_data;
        end
    end
endmodule: regfile
