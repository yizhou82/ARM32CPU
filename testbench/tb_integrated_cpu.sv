`timescale 1ps / 1ps
module tb_integrated_cpu();

    //test regs
    integer error_count = 0;

    //cpu inputs
    reg clk, rst_n;
    reg [10:0] start_pc;

    //cpu module
    integrated_cpu DUT(
        .clk(clk),
        .rst_n(rst_n),
        .start_pc(start_pc)
    );

    // Tasks
    task check(input integer expected, input integer actual, integer test_num);
        begin
            if (expected !== actual) begin
                $error("Test %d failed. Expected: %b, Actual: %b", test_num, expected, actual);
                error_count = error_count + 1;
            end
        end
    endtask: check

    task clkR;
        begin
            clk = 1'b0;
            #5;
            clk = 1'b1;
            #5;
        end
    endtask: clkR

    task reset;
        begin
            #5;
            clk = 1'b0;
            rst_n = 1'b1;
            #5;
            rst_n = 1'b0;
            #5;
            rst_n = 1'b1;
        end
    endtask: reset

    task clkCycle;
        begin
            clkR;
            clkR;
            clkR;
            clkR;
            clkR;
            clkR;
            clkR;
            clkR;
        end
    endtask: clkCycle

    integer i = 0;
    initial begin
        //fill the duel memory with instructions: with the mov instructions
        $readmemb("C:/Users/richa/OneDrive - UBC/Documents/Personal_Projects/Winter_CPU_Project/ARM32CPU/memory_data/movTests.memh",
            DUT.duel_mem.altsyncram_component.m_default.altsyncram_inst.mem_data);
        
        reset;
        start_pc = 32'd0;

        //Fill each register with default values
        for (i = 0; i < 16; i = i + 1) begin
            clkCycle;
        end
        
        //print final test results
        if (error_count == 0) begin
            $display("All tests passed!");
        end else begin
            $display("%d tests failed.", error_count);
        end
    end
endmodule: tb_integrated_cpu