module tb_datapath(output err);
    // your implementation here

    //regs for testbench
    reg [31:0] imme_data, shift_imme, PC, w_data1, w_data2, ram_data2;
    reg [3:0] w_addr1, w_addr2, A_addr, B_addr, shift_addr;
    reg w_en1, w_en2, clk, sel_w_data;
    reg en_A, en_B, en_out1, en_out2, en_S, en_status1, en_status2;
    reg [1:0] shift_op, sel_A_in, sel_B_in, sel_shift_in;
    reg sel_A, sel_B, sel_shift, sel_post_shift;
    reg [2:0] ALU_op;
    wire [31:0] status_out, datapath_out;
    integer error_count = 0;

    // tasks
    task check(input [31:0] expected, input [31:0] actual, input [3:0] addr, integer test_num);
        begin
            if (expected !== actual) begin
            $error("Test %d failed. Expected: %d, Actual: %d", test_num, expected, actual);
            error_count = error_count + 1;
            end
        end
    endtask: check

    // clk task
    task clkR;
        begin
        #5;
        clk = 1'b1;
        #5;
        clk = 1'b0;
        end
    endtask: clkR

    task rstSignals;
        begin
        //set all inputs to 0
        clk = 1'b0;
        ram_data2 = 32'd0;
        sel_w_data = 1'b0;
        w_addr1 = 4'd0;
        w_addr2 = 4'd0;
        w_en1 = 1'b0;
        w_en2 = 1'b0;
        A_addr = 4'd0;
        B_addr = 4'd0;
        shift_addr = 4'd0;
        PC = 32'd0;
        sel_A_in = 2'b00;
        sel_B_in = 2'b00;
        sel_shift_in = 2'b00;
        en_A = 1'b0;
        en_B = 1'b0;
        en_out1 = 1'b0;
        en_out2 = 1'b0;
        shift_imme = 32'd0;
        sel_shift = 1'b0;
        shift_op = 2'b00;
        en_S = 1'b0;
        sel_A = 1'b0;
        sel_B = 1'b0;
        sel_post_shift = 1'b0;
        imme_data = 32'd0;
        ALU_op = 3'b000;
        en_status1 = 1'b0;
        en_status2 = 1'b0;
        #5;
        end
    endtask: rstSignals

    // DUT
    datapath DUT(
        .clk(clk),
        .ram_data2(ram_data2),
        .sel_w_data(sel_w_data),
        .w_addr1(w_addr1),
        .w_en1(w_en1),
        .w_addr2(w_addr2),
        .w_en2(w_en2),
        .A_addr(A_addr),
        .B_addr(B_addr),
        .shift_addr(shift_addr),
        .PC(PC),
        .sel_A_in(sel_A_in),
        .sel_B_in(sel_B_in),
        .sel_shift_in(sel_shift_in),
        .en_A(en_A),
        .en_B(en_B),
        .en_out1(en_out1),
        .en_out2(en_out2),
        .shift_imme(shift_imme),
        .sel_shift(sel_shift),
        .shift_op(shift_op),
        .en_S(en_S),
        .sel_A(sel_A),
        .sel_B(sel_B),
        .sel_post_shift(sel_post_shift),
        .imme_data(imme_data),
        .ALU_op(ALU_op),
        .en_status1(en_status1),
        .en_status2(en_status2),
        .datapath_out(datapath_out),
        .status_out(status_out)
    );

    integer i = 0;  
    initial begin
        /*
        states:
        1. fetch
        2. fetch_wait
        3. decode
        4. execute
        5. memory
        6. memory_wait
        7. write_back
        */

        /*
        input signals:
        - clk
        - wb_sel
        - A_addr
        - B_addr
        - shift_addr
        - en_A
        - en_B
        - en_S
        - shift_op
        - shift_imme
        - sel_shift
        - sel_post_shift
        - sel_A
        - sel_B
        - imme_data
        - PC
        - ALU_op
        - en_status
        - sel_A_in
        - sel_B_in
        - sel_shift_in
        */

        //set app input to 0
        rstSignals;

        // write values to every register
        for (i = 0; i < 16; i = i + 1) begin
            ram_data2 = i;
            sel_w_data = 1'b1;
            w_addr1 = i;
            w_en1 = 1'b1;
            clkR;
        end

        // Test 1 & 2 add values in reg1 and reg2, 1 + 2 * 2 = 5
        rstSignals;
        A_addr = 1;
        en_A = 1'b1;
        B_addr = 2;
        en_B = 1'b1;
        shift_addr = 32'd1;
        sel_shift = 1'b1;
        en_S = 1'b1;
        clkR; //load registers
        rstSignals;

        shift_op = 2'b00;
        sel_A = 1'b0;
        sel_B = 1'b0;
        ALU_op = 3'b000;
        en_status1 = 1'b1;
        en_out1 = 1'b1;
        clkR; //propagate datapath
        rstSignals;
        en_out2 = 1'b1;
        en_status2 = 1'b1;
        clkR; //load status reg 2
        check(32'd0, status_out, 0, 2);
        check(5, datapath_out, 0, 1);
        //Conclusion: nothing changed in registers

        // Test 3 & 4 sel_A and sel_B == 1
        sel_A = 1'b1;
        sel_B = 1'b1;
        imme_data = 32'd12;
        ALU_op = 3'b001;
        en_out1 = 1'b1;
        en_status1 = 1'b1;
        clkR; //load status and out reg1
        rstSignals;
        en_out2 = 1'b1;
        en_status2 = 1'b1;
        clkR; //load status and out reg2
        rstSignals;
        check(-32'sd12, datapath_out, 0, 3);
        check(32'b10000000000000000000000000000000, status_out, 0, 4);

        //  Test 5 write back -12 into reg 0
        w_addr1 = 0;
        w_en1 = 1'b1;
        clkR; //write back
        rstSignals;

        B_addr = 0;
        en_B = 1'b1;
        shift_imme = 32'd0;
        sel_shift = 1'b0;
        en_S = 1'b1;
        clkR;
        rstSignals;
        sel_A = 1'b1;
        sel_B = 1'b0;
        shift_op = 2'b00;
        ALU_op = 3'b001;
        #5;
        en_status1 = 1'b1;
        en_out1 = 1'b1;
        clkR; //load status and out reg1
        rstSignals;
        en_out2 = 1'b1;
        en_status2 = 1'b1;
        clkR; //load status and out reg2
        check(32'd12, datapath_out, 0, 5);
        check(32'b00000000000000000000000000000000, status_out, 0, 6);

        // Test 6 & 7 post shift subtract and write back into reg 0
        rstSignals;

        // -12 + 2 = -10 BUT change register 0 to 2*4 = 8
        A_addr = 0;
        en_A = 1'b1;
        B_addr = 2;
        en_B = 1'b1;
        shift_imme = 32'd2;
        sel_shift = 1'b0;
        en_S = 1'b1;
        clkR;   //load registers
        rstSignals;
        shift_op = 2'b00;
        sel_A = 1'b0;
        sel_B = 1'b0;
        sel_post_shift = 1'b1;
        ALU_op = 3'b000;
        #5;
        en_out1 = 1'b1;
        en_status1 = 1'b1;
        clkR; //load out 1
        rstSignals;
        en_out2 = 1'b1;
        en_status2 = 1'b1;
        clkR; //load out 2
        rstSignals;
        check(-32'sd10, datapath_out, 0, 7);
        w_addr2 = 0;
        w_en2 = 1'b1;
        clkR; //write back
        rstSignals;

        // Test 8 read from reg0 if it is 8
        B_addr = 0;
        en_B = 1'b1;
        sel_shift = 1'b0;
        shift_imme = 32'd0;
        en_S = 1'b1;
        clkR; //load registers
        rstSignals;
        sel_A = 1'b1;
        sel_B = 1'b0;
        ALU_op = 3'b000;
        #5;
        en_out1 = 1'b1;
        en_status1 = 1'b1;
        clkR; //load out 1
        rstSignals;
        en_out2 = 1'b1;
        en_status2 = 1'b1;
        clkR; //load out 2
        rstSignals;
        check(32'd8, datapath_out, 0, 8);

        //Print test summary
        if (error_count == 0) begin
            $display("All tests passed!");
        end else begin
            $display("Failed %d tests", error_count);
        end
    end


endmodule: tb_datapath
