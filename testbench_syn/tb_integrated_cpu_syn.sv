`timescale 1ps / 1ps

module tb_integrated_cpu_syn();

    //test regs
    integer error_count = 0;

    //cpu inputs
    reg clk, rst_n, sel_instr;
    reg CLOCK_50;
    reg [3:0] KEY;
    reg [9:0] SW;
    reg [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    reg [9:0] LEDR;
    reg [31:0] status_out;
    reg [31:0] reg_output;
    reg [3:0] reg_addr;

    //cpu module
    integrated_cpu DUT(
        .CLOCK_50(CLOCK_50),
        .KEY(KEY),
        .SW(SW),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4),
        .HEX5(HEX5),
        .LEDR(LEDR)
    );

    assign CLOCK_50 = clk;
    assign KEY[0] = rst_n;
    assign KEY[1] = sel_instr;
    assign SW = { 6'b0, reg_addr};
    assign status_out = {HEX4[3:0], HEX3, HEX2, HEX1, HEX0};
    assign reg_output = LEDR;

    // Tasks
    task check(input [31:0] expected, input [31:0] actual, integer test_num);
        begin
            if (expected !== actual) begin
                $error("Test %d failed. Expected: %b(%d), Actual: %b(%d)", test_num, expected, expected, actual, actual);
                error_count = error_count + 1;
            end
        end
    endtask: check

    task setRegAddr(input [3:0] addr);
        begin
            reg_addr = addr;
            #5;
        end
    endtask: setRegAddr

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
        end
    endtask: clkCycle

    integer i = 0;
    initial begin
        //fill the duel memory with instructions: with the mov instructions
        $readmemb("C:/Users/richa/OneDrive - UBC/Documents/Personal_Projects/Winter_CPU_Project/ARM32CPU/memory_data/syn_data/remakeCPUTestsA.memb",
            DUT.\instruction_memory|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem);
        $readmemb("C:/Users/richa/OneDrive - UBC/Documents/Personal_Projects/Winter_CPU_Project/ARM32CPU/memory_data/syn_data/remakeCPUTestsB.memb",
            DUT.\instruction_memory|altsyncram_component|auto_generated|altsyncram1|ram_block3a20 .ram_core0.ram_core0.mem);
        
        reset;
        sel_instr = 1'b0;

        // Fill each register with default values
        for (i = 0; i < 15; i = i + 1) begin
            clkCycle;
            setRegAddr(i);
            check(i + 1, reg_output, i);
        end
        
        // ADD_R r0, r0, r0
        clkCycle;
        clkR;   //because loading start_pc is exctra cycle
        setRegAddr(0);
        check(2, reg_output, 16);
        check(0, status_out, 17);

        // ADD_I r1, r1, #8
        clkCycle;
        setRegAddr(1);
        check(10, reg_output, 18);
        check(0, status_out, 19);

        // ADD_RS r2, r2, r0, LSL r0
        clkCycle;
        setRegAddr(2);
        check(11, reg_output, 20);
        check(0, status_out, 21);

        // CMP_R r2, r1, LSL #1 (r2 = 11, r1 = 10 -> 20)
        clkCycle;
        check(32'b10000000_00000000_00000000_00000000, status_out, 23);

        // CMP_I r2, #11
        clkCycle;
        check(32'b01000000_00000000_00000000_00000000, status_out, 25);

        // // ### LDR and STR tests ###
        // $readmemb("C:/Users/richa/OneDrive - UBC/Documents/Personal_Projects/Winter_CPU_Project/ARM32CPU/memory_data/str_ldr_instr_CPUTests.memb",
        //     DUT.\instruction_memory|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem);
        // $readmemb("C:/Users/richa/OneDrive - UBC/Documents/Personal_Projects/Winter_CPU_Project/ARM32CPU/memory_data/str_ldr_data_CPUTests.memb",
        //     DUT.\data_memory|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem);
        // reset;
        // clkR;   //because loading start_pc is exctra cycle

        // // Fill each register with default values
        // for (i = 0; i < 15; i = i + 1) begin
        //     clkCycle;
        //     setRegAddr(i);
        //     check(i, reg_output, i + 26);
        // end

        // //filler instruction
        // clkCycle;

        // // LDR_I r0, r9, #19
        // clkCycle;
        // clkR;   //because the actual LDR writeback is done on the very very last clk edge
        // setRegAddr(0);
        // check(38, reg_output, 42);

        // // STR_I r8, r0, #9 -> store 8 in address 29 -> 38 - 9 = 29 -> store 29 in r0
        // clkCycle;
        // setRegAddr(0);
        // check(29, reg_output, 43);

        // //LDR_R r14, r0, r1 -> address = 29 -> write 28 to r0
        // clkCycle;
        // setRegAddr(0);
        // check(28, reg_output, 44);
        // setRegAddr(14);
        // check(8, reg_output, 45);

        // //STR_R r9, r12, r2 LSL 3 -> address = 12 + 2 * 8 = 28 -> write 28 address 12
        // clkCycle;
        // setRegAddr(12);
        // check(28, reg_output, 46);
        
        // // LDR_Lit r1, #8 -> PC == 20, write 10 to r1
        // clkCycle;
        // setRegAddr(1);
        // check(10, reg_output, 47);

        // // ### Branch tests ###
        // $readmemb("C:/Users/richa/OneDrive - UBC/Documents/Personal_Projects/Winter_CPU_Project/ARM32CPU/memory_data/branchCPUTests.memb",
        //     DUT.\instruction_memory|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem);
        // reset;
        // clkR;   //because loading start_pc is exctra cycle

        // //MOV_I r0, #1
        // clkCycle;
        // setRegAddr(0);
        // check(1, reg_output, 48);

        // //MOV_I r1, #10
        // clkCycle;
        // setRegAddr(1);
        // check(10, reg_output, 49);

        // //ADD r0, r0, #1
        // //CMP r0, r1
        // //BLE #2
        // for (i = 0; i < 8; i = i + 1) begin
        //     clkCycle;
        //     setRegAddr(0);
        //     check(2 + i, reg_output, i * 3 + 50);
        //     clkCycle;
        //     check(32'b10000000_00000000_00000000_00000000, status_out, (i * 3) + 51);
        //     clkCycle;
        //     setRegAddr(15);
        //     check(2, reg_output, (i * 3) + 52);
        // end
        // clkCycle;
        // setRegAddr(0);
        // check(10, reg_output, 77);
        // clkCycle;   //r0 == r1
        // check(32'b01000000_00000000_00000000_00000000, status_out, 78);
        // clkCycle;
        // setRegAddr(15);
        // check(2, reg_output, 79);
        // clkCycle;
        // setRegAddr(0);
        // check(11, reg_output, 80);
        // clkCycle;   //r0 > r1
        // check(32'b00000000_00000000_00000000_00000000, status_out, 81);
        // clkCycle;
        // setRegAddr(15);
        // check(5, reg_output, 82);
        
        // //STR r0, r0, #1
        // clkCycle;
        // check(11, DUT.\data_memory|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem[10], 83);

        //print final test results
        if (error_count == 0) begin
            $display("All tests passed!");
        end else begin
            $display("%d tests failed.", error_count);
        end
    end
endmodule: tb_integrated_cpu_syn