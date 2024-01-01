module tb_regfile(output err);

    //regs for testbench
    reg [31:0] w_data, r_data;
    reg [3:0] w_addr, r_addr;
    reg w_en, clk;
    integer error_count = 0;

    // tasks
    task check(input [31:0] expected, input [31:0] actual, input [3:0] addr, integer test_num);
        begin
            if (expected !== actual) begin
            $display("Test %d failed. Expected: %d, Actual: %d", test_num, expected, actual);
            error_count = error_count + 1;
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
    regfile regfile(
        .w_data(w_data),
        .w_addr(w_addr),
        .w_en(w_en),
        .r_addr(r_addr),
        .clk(clk),
        .r_data(r_data)
    );

    integer i = 0;
    initial begin
        // test every register write and read
        for (i = 0; i < 16; i = i + 1) begin
            w_data = i;
            w_addr = i;
            w_en = 1'b1;
            r_addr = i;
            clkR;
            check(i, r_data, r_addr, i);
        end

        // test every register read again
        for (i = 0; i < 16; i = i + 1) begin
            w_data = i;
            w_addr = i;
            w_en = 1'b0;
            r_addr = i;
            #10;
            check(i, r_data, r_addr, i);
        end

        // print test summary
        if (error_count == 0) begin
            $display("All tests passed!");
        end else begin
            $display("Failed %d tests", error_count);
        end
    end
endmodule: tb_regfile
