module tb_ALU(output err);

    //regs for testbench
    reg [31:0] val_A, val_B;
    reg [2:0] ALU_op;
    wire [31:0] ALU_out, flags;
    reg clk;
    integer error_count = 0;

    // tasks
    task check(input [31:0] expected, input [31:0] actual, input [31:0] expected_flags, input [31:0] actual_flags, integer test_num);
        begin
            if (expected !== actual) begin
            $display("Test %d failed. Expected: %d, Actual: %d", test_num, expected, actual);
            error_count = error_count + 1;
            end
            if (expected_flags !== actual_flags) begin
            $display("Test %d failed. Expected flags: %b, Actual flags: %b", test_num, expected_flags, actual_flags);
            error_count = error_count + 1;
            end else begin
            $display("Test %d passed.", test_num);
            end
        end
    endtask: check

    // clk task
    task clkR;
        begin
            clk = 1'b0;
            #5;
            clk = 1'b1;
            #5;
        end
    endtask: clkR

    // DUT
    ALU DUT(
        .val_A(val_A),
        .val_B(val_B),
        .ALU_op(ALU_op),
        .ALU_out(ALU_out),
        .flags(flags)
    );

    initial begin
        // test every ALU operation
        // Addition
        val_A = 32'b00000000_00000000_00000000_00000011;
        val_B = 32'b00000000_00000000_00000000_00000001;
        ALU_op = 3'b000;
        clkR;
        check(32'b00000000_00000000_00000000_00000100, ALU_out, 32'b0, flags, 0);

        // Addition with overflow and negative flag
        val_A = 32'b01000000_00000000_00000000_00000000;
        val_B = 32'b01000000_00000000_00000000_00000000;
        ALU_op = 3'b000;
        clkR;
        check(32'b10000000_00000000_00000000_00000000, ALU_out, 32'b10010000_00000000_00000000_00000000, flags, 1);

        // Subtraction
        val_A = 32'b00000000_00000000_00000000_00000111;
        val_B = 32'b00000000_00000000_00000000_00000011;
        ALU_op = 3'b001;
        clkR;
        check(32'b00000000_00000000_00000000_00000100, ALU_out, 32'b0, flags, 2);

        // Subtraction with zero flag
        val_A = 32'b00000000_00000000_00000000_00000111;
        val_B = 32'b00000000_00000000_00000000_00000111;
        ALU_op = 3'b001;
        clkR;
        check(32'b0, ALU_out, 32'b01000000_00000000_00000000_00000000, flags, 3);
        
        // AND
        val_A = 32'b00000000_00000000_00000000_01010101;
        val_B = 32'b00000000_00000000_00000000_10101010;
        ALU_op = 3'b010;
        clkR;
        check(32'b00000000_00000000_00000000_00000000, ALU_out, 32'b01000000_00000000_00000000_00000000, flags, 4);

        // OR
        val_A = 32'b00000000_00000000_00000000_01010101;
        val_B = 32'b00000000_00000000_00000000_10101010;
        ALU_op = 3'b011;
        clkR;
        check(32'b00000000_00000000_00000000_11111111, ALU_out, 32'b00000000_00000000_00000000_00000000, flags, 5);

        // Multiplication
        val_A = 32'b00000000_00000000_00000000_00000011;
        val_B = 32'b00000000_00000000_00000000_00000011;
        ALU_op = 3'b100;
        clkR;
        check(32'b00000000_00000000_00000000_00001001, ALU_out, 32'b00000000_00000000_00000000_00000000, flags, 6);

        // Multiplication with overflow flag
        val_A = 32'b10000000_00000000_00000000_00000000;
        val_B = 32'b10000000_00000000_00000000_00000000;
        ALU_op = 3'b100;
        clkR;
        check(32'b00000000_00000000_00000000_00000000, ALU_out, 32'b01010000_00000000_00000000_00000000, flags, 7);

        // Division
        val_A = 32'b00000000_00000000_00000000_00000100;
        val_B = 32'b00000000_00000000_00000000_00000010;
        ALU_op = 3'b101;
        clkR;
        check(32'b00000000_00000000_00000000_00000010, ALU_out, 32'b00000000_00000000_00000000_00000000, flags, 8);

        // Division with invalid flag
        val_A = 32'b00000000_00000000_00000000_00000100;
        val_B = 32'b00000000_00000000_00000000_00000000;
        ALU_op = 3'b101;
        clkR;
        check(32'b00000000_00000000_00000000_00000000, ALU_out, 32'b01100000_00000000_00000000_00000000, flags, 9);

        // NOT
        val_A = 32'b00000000_00000000_00000000_00000000;
        val_B = 32'b00000000_00000000_00000000_00000011;
        ALU_op = 3'b110;
        clkR;
        check(32'b11111111_11111111_11111111_11111100, ALU_out, 32'b10000000_00000000_00000000_00000000, flags, 10);

        // Addition with negative values
        val_A = 32'b11111111_11111111_11111111_11111111;
        val_B = 32'b11111111_11111111_11111111_11111111;
        ALU_op = 3'b000;
        clkR;
        check(32'b11111111_11111111_11111111_11111110, ALU_out, 32'b10000000_00000000_00000000_00000000, flags, 11);
        

    end
endmodule: tb_ALU
