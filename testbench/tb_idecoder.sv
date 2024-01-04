module tb_idecoder(output err);

    reg [31:0] instr;
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

    integer error_count = 0;

    idecoder dut (
        .instr(instr),
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

    task check(input [6:0] expected_opcode, input [6:0] actual_opcode, integer test_num);
        begin
            if (expected_opcode !== actual_opcode) begin
            $error("Test %d failed. Expected: %d, Actual: %d", test_num, expected_opcode, actual_opcode);
            error_count = error_count + 1;
            end else begin
                $display("Test %d passed.", test_num);
            end
        end
    endtask: check

    initial begin
        // All outputs check
        instr = 32'b01010101_01010101_01010101_01010101;
        #10;
        if(cond !== 4'b0101) begin
            $error("Test 1 failed. Expected: %b, Actual: %b", 4'b0101, cond);
            error_count = error_count + 1;
        end else begin
            $display("Test 1 passed.");
        end
        if(opcode !== 7'b1011010) begin
            $error("Test 1 failed. Expected: %b, Actual: %b", 7'b1011010, opcode);
            error_count = error_count + 1;
        end else begin
            $display("Test 1 passed.");
        end
        if(en_status !== 1'b1) begin
            $error("Test 1 failed. Expected: %b, Actual: %b", 1'b1, en_status);
            error_count = error_count + 1;
        end else begin
            $display("Test 1 passed.");
        end
        if(rn !== 4'b0101) begin
            $error("Test 1 failed. Expected: %b, Actual: %b", 4'b0101, rn);
            error_count = error_count + 1;
        end else begin
            $display("Test 1 passed.");
        end
        if(rd !== 4'b0101) begin
            $error("Test 1 failed. Expected: %b, Actual: %b", 4'b0101, rd);
            error_count = error_count + 1;
        end else begin
            $display("Test 1 passed.");
        end
        if(rs !== 4'b0101) begin
            $error("Test 1 failed. Expected: %b, Actual: %b", 4'b0101, rs);
            error_count = error_count + 1;
        end else begin
            $display("Test 1 passed.");
        end
        if(rm !== 4'b0101) begin
            $error("Test 1 failed. Expected: %b, Actual: %b", 4'b0101, rm);
            error_count = error_count + 1;
        end else begin
            $display("Test 1 passed.");
        end
        if(shift_op !== 2'b01) begin
            $error("Test 1 failed. Expected: %b, Actual: %b", 2'b01, shift_op);
            error_count = error_count + 1;
        end else begin
            $display("Test 1 passed.");
        end
        if(imm5 !== 5'b10101) begin
            $error("Test 1 failed. Expected: %b, Actual: %b", 5'b10101, imm5);
            error_count = error_count + 1;
        end else begin
            $display("Test 1 passed.");
        end
        if(imm12 !== 12'b010101010101) begin
            $error("Test 1 failed. Expected: %b, Actual: %b", 12'b010101010101, imm12);
            error_count = error_count + 1;
        end else begin
            $display("Test 1 passed.");
        end
        if(imm24 !== 24'b010101010101010101010101) begin
            $error("Test 1 failed. Expected: %b, Actual: %b", 24'b010101010101010101010101, imm24);
            error_count = error_count + 1;
        end else begin
            $display("Test 1 passed.");
        end
        
        // Opcode Check: NOP
        instr = 32'b00000011_00100000_00000000_00000000;
        #10;
        check(7'b0001001, opcode, 2);

        // Opcode Check: HALT
        instr = 32'b00000001_00000000_00000000_00000000;
        #10;
        check(7'b0001000, opcode, 3);

        // Opcode Check: Data
        instr = 32'b0000001_01001111_10111111_001010000; // ADD I
        #10;
        check(7'b0010100, opcode, 4);

        instr = 32'b00000000_1001111_10111111_000111000; // ADD RS
        #10;
        check(7'b0110100, opcode, 5);

        instr = 32'b00000000_10011111_01111110_00101000; // ADD R
        #10;
        check(7'b0100100, opcode, 6);

        // Opcode Check: Load/Store
        instr = 32'b10100101_00010101_10101010_11001100; // LDR
        #10;
        check(7'b1011000, opcode, 7);

        instr = 32'b10100101_00000101_10101010_11001100; // STR
        #10;
        check(7'b1011000, opcode, 8);

        // Opcode Check: Branch
        instr = 32'b10001010_11000101_10101010_11001100; // B
        #10;
        check(7'b1000110, opcode, 9);
    end

endmodule: tb_idecoder