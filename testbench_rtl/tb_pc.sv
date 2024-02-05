module tb_pc (output err);
    //regs
    integer error_count = 0;

    //module inputs
    reg clk;
    reg [1:0] sel_pc;
    reg [10:0] start_pc;
    reg [10:0] dp_pc;

    //module outputs
    wire [10:0] pc_out;

    //DUT
    pc DUT(
        .clk(clk),
        .sel_pc(sel_pc),
        .start_pc(start_pc),
        .dp_pc(dp_pc),
        .pc_out(pc_out)
    );

    //task to check the output
    task check(input [10:0] expected, input [10:0] actual, integer test_num);
        begin
            if (expected !== actual) begin
            $error("Test %d failed. Expected: %d, Actual: %d", test_num, expected, actual);
            error_count = error_count + 1;
            end
        end
    endtask: check

    //task to clk the clock
    task clkR;
        begin
            clk = 1'b0;
            #5;
            clk = 1'b1;
            #5;
        end
    endtask: clkR

    integer i = 0;
    initial begin
        //start the pc at 0 then increment 10 times
        start_pc = 32'd0;
        sel_pc = 2'b01;
        clkR;
        check(32'd00, pc_out, 1);

        for (int i = 0; i < 9; i = i + 1) begin
            sel_pc = 2'b00;
            clkR;
            check(i + 1, pc_out, i + 2);
        end

        //load from dp_pc
        sel_pc = 2'b11;
        dp_pc = 32'd100;
        clkR;
        check(32'd100, pc_out, 11);

        //print test result
        if (error_count == 0) begin
            $display("All tests passed!");
        end else begin
            $display("There were %d errors.", error_count);
        end
    end
endmodule: tb_pc