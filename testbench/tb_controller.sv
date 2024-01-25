module tb_controller(output err);
  
  // regs for testbench
    reg clk, rst_n;
    reg [6:0] opcode;
    reg [1:0] shift_op;
    reg [31:0] status_reg;
    reg [3:0] cond;
    reg P, U, W;

    wire waiting;
    wire w_en1, w_en2, sel_w_data;
    wire [1:0] sel_A_in, sel_B_in, sel_shift_in;
    wire sel_shift;
    wire en_A, en_B, en_C, en_S;
    wire sel_A, sel_B, sel_post_shift;
    wire [2:0] ALU_op;
    wire en_out1, en_out2, en_status1, en_status2;
    wire load_ir, load_pc;
    wire [1:0] sel_pc;
    wire sel_ram_addr2;
    wire [10:0] ram_addr1, ram_addr2;
    wire ram_w_en1, ram_w_en2;

    integer error_count = 0;

    //DUT
    controller DUT(
        .clk(clk),
        .rst_n(rst_n),
        .opcode(opcode),
        .status_reg(status_reg),
        .cond(cond),
        .P(P),
        .U(U),
        .W(W),
        .waiting(waiting),
        .w_en1(w_en1),
        .w_en2(w_en2),
        .sel_w_data(sel_w_data),
        .sel_A_in(sel_A_in),
        .sel_B_in(sel_B_in),
        .sel_shift_in(sel_shift_in),
        .sel_shift(sel_shift),
        .en_A(en_A),
        .en_B(en_B),
        .en_C(en_C),
        .en_S(en_S),
        .sel_A(sel_A),
        .sel_B(sel_B),
        .sel_post_shift(sel_post_shift),
        .ALU_op(ALU_op),
        .en_out1(en_out1),
        .en_out2(en_out2),
        .en_status1(en_status1),
        .en_status2(en_status2),
        .load_ir(load_ir),
        .load_pc(load_pc),
        .sel_pc(sel_pc),
        .sel_ram_addr2(sel_ram_addr2),
        .ram_addr1(ram_addr1),
        .ram_addr2(ram_addr2),
        .ram_w_en1(ram_w_en1),
        .ram_w_en2(ram_w_en2)
    );

    //tasks
    task check(input integer expected, input integer actual, integer test_num);
        begin
            if (expected !== actual) begin
                $error("Test %d failed. Expected: %b, Actual: %b", test_num, expected, actual);
                error_count = error_count + 1;
            end else begin
                $display("Test %d passed.", test_num);
            end
        end
    endtask: check

    task zeroInputs;
        begin
            opcode = 7'b0;
            shift_op = 2'b00;
            cond = 4'd0;
            P = 1'b0;
            U = 1'b0;
            W = 1'b0;
        end
        endtask: zeroInputs

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
            rst_n = 1'b1;
            #5;
            rst_n = 1'b0;
            #5;
            rst_n = 1'b1;
        end
    endtask: reset

    task  first3Cycles(input integer startTestNum);
        begin
            reset;
            zeroInputs;
            check(1, waiting, startTestNum);
            clkR; // load_pc
            check(1, waiting, startTestNum + 1);
            check(1, load_pc, startTestNum + 2);
            check(1, sel_pc, startTestNum + 3); //first time you load from startpc
            clkR; // fetch 1
            check(1, waiting, startTestNum + 4);
            clkR; // fetch 2
            check(1, waiting, startTestNum + 4);
            check(1, load_ir, startTestNum + 5);
        end
    endtask: first3Cycles

    task executeCycle_MOV_I(input integer startTestNum); //+
        clkR; // execute instruction
        check(0, sel_A_in, startTestNum);
        check(0, sel_B_in, startTestNum + 1);
        check(2'b11, sel_shift_in, startTestNum + 2);
        check(0, en_A, startTestNum + 3);
        check(0, en_B, startTestNum + 4);
        check(1, en_S, startTestNum + 5);
        check(1, sel_shift, startTestNum + 6);
    endtask: executeCycle_MOV_I

    task executeCycle_I(input integer startTestNum); //+
        clkR; // execute instruction
        check(0, sel_A_in, startTestNum);
        check(0, sel_B_in, startTestNum + 1);
        check(2'b11, sel_shift_in, startTestNum + 2);
        check(0, en_A, startTestNum + 3);
        check(1, en_B, startTestNum + 4);
        check(1, en_S, startTestNum + 5);
        check(1, sel_shift, startTestNum + 6);
    endtask: executeCycle_I

    task executeCycle_R(input integer startTestNum);
        clkR; // execute instruction
        check(0, sel_A_in, startTestNum);
        check(0, sel_B_in, startTestNum + 1);
        check(0, sel_shift_in, startTestNum + 2);
        check(1, en_A, startTestNum + 3);
        check(1, en_B, startTestNum + 4);
        check(1, en_S, startTestNum + 5);
        check(0, sel_shift, startTestNum + 6);
    endtask: executeCycle_R

    task executeCycle_RS(input integer startTestNum);
        clkR; // execute instruction
        check(0, sel_A_in, startTestNum);
        check(0, sel_B_in, startTestNum + 1);
        check(0, sel_shift_in, startTestNum + 2);
        check(1, en_A, startTestNum + 3);
        check(1, en_B, startTestNum + 4);
        check(1, en_S, startTestNum + 5);
        check(1, sel_shift, startTestNum + 6);
    endtask: executeCycle_RS

    //mode 0 = I, mode 1 = Lit, mode 2 = R
    task executeCycle_LDR_STR(input integer startTestNum, input [2:0] mode);
        clkR; // execute instruction
        if (mode == 1) begin    //LIT
            check(2'b11, sel_A_in, startTestNum);
        end else begin
            check(0, sel_A_in, startTestNum);
        end

        check(0, sel_B_in, startTestNum + 1);

        if (mode == 2) begin
            check(0, sel_shift_in, startTestNum + 2);
        end else begin
            check(2'b11, sel_shift_in, startTestNum + 2);
        end

        check(1, en_A, startTestNum + 3);

        if (mode == 2) begin
            check(1, en_B, startTestNum + 4);
        end else begin
            check(0, en_B, startTestNum + 4);
        end

        check(1, en_S, startTestNum + 5);

        if (mode == 2) begin
            check(0, sel_shift, startTestNum + 6);
        end else begin
            check(1, sel_shift, startTestNum + 6);  //dont shift by anything
        end
    endtask: executeCycle_LDR_STR

    task mem_writeback_MOV_I(input integer startTestNum, input [2:0] ALU_op_ans);
        clkR; // mem 1 + write back
        check(1, sel_A, startTestNum);
        check(1, sel_B, startTestNum + 1);
        check(0, sel_post_shift, startTestNum + 2);
        check(ALU_op_ans, ALU_op, startTestNum + 3);
        check(0, sel_w_data, startTestNum + 4);
        check(1, w_en1, startTestNum + 5);
    endtask: mem_writeback_MOV_I

    task mem_writeback_I(input integer startTestNum, input [2:0] ALU_op_ans);
        clkR; // mem 1 + write back
        check(1, sel_A, startTestNum);
        check(0, sel_B, startTestNum + 1);
        check(0, sel_post_shift, startTestNum + 2);
        check(ALU_op_ans, ALU_op, startTestNum + 3);
        check(0, sel_w_data, startTestNum + 4);
        check(1, w_en1, startTestNum + 5);
    endtask: mem_writeback_I

    task mem_writeback_R_RS(input integer startTestNum, input [2:0] ALU_op_ans);
        clkR; // mem 1 + write back
        check(0, sel_A, startTestNum);
        check(0, sel_B, startTestNum + 1);
        check(0, sel_post_shift, startTestNum + 2);
        check(ALU_op_ans, ALU_op, startTestNum + 3);
        check(0, sel_w_data, startTestNum + 4);
        check(1, w_en1, startTestNum + 5);
    endtask: mem_writeback_R_RS

    task mem_writeback_STR_LDR(input integer startTestNum, input P, input U, input [1:0] mode, input is_STR);
        clkR; // mem 1 + write back
        check(0, sel_A, startTestNum);

        if (mode == 2) begin
            check(0, sel_B, startTestNum + 1);
        end else begin
            check(1, sel_B, startTestNum + 1);
        end

        if (P == 1) begin //preindex -> change address first before memory access
            check(0, sel_post_shift, startTestNum + 2);
        end else begin
            check(1, sel_post_shift, startTestNum + 2);
        end

        if (U == 1) begin //UP -> add
            check(3'b000, ALU_op, startTestNum + 3);
        end else begin
            check(3'b001, ALU_op, startTestNum + 3);
        end

        check(0, sel_w_data, startTestNum + 4);
        check(0, w_en1, startTestNum + 5);
        //RAM STUFF
        if (is_STR == 1) begin
            check(1, ram_w_en2, startTestNum + 6);
        end else begin
            check(0, ram_w_en2, startTestNum + 6);
        end
    endtask: mem_writeback_STR_LDR

    task mem_wait(input integer startTestNum);
        clkR; // mem 2
    endtask: mem_wait_normal_STR

    task write_back_LDR(input integer startTestNum);
        clkR; // mem 2
        check(1, w_en3, startTestNum);
    endtask: mem_wait_LDR

    initial begin
        // Test 1: ADD_R reg0 + reg1 to reg 2
        first3Cycles(0);
        opcode = 7'b0011000;
        cond = 4'b1110;
        clkR; // execute instruction
        executeCycle_R(6);
        clkR; // mem 1 + write back
        check(1, sel_A, 12);
        check(0, sel_B, 13);
        check(0, sel_post_shift, 14);
        check(0, ALU_op, 15);
        check(1, en_out1, 16);
        check(0, en_status1, 17);
        check(0, sel_w_data, 18);
        check(1, w_en1, 19);
        clkR; // mem 2
        check(1, en_out2, 20);

        // Test 2: Mov_R reg0 divide by 2 to reg 1
        first3Cycles(21);
        opcode = 7'b0001000;
        cond = 4'b1110;
        clkR; // execute instruction
        check(0, sel_A_in, 22);


        clkR; // fetch
        check(1, load_ir, 5);
        check(1, waiting, 6);
        check(0, sel_shift, 7);
        clkR; // execute instruction
        check(1, sel_A, 8);
        check(0, sel_B, 9);
        check(0, en_A, 22);
        check(1, en_B, 23);
        check(3'b000, ALU_op, 10);
        clkR; // write back
        check(1, w_en, 11);
        check(0, wb_sel, 12);

        // Test 3: SUB_RS 1 to reg 1
        reset;
        opcode = 7'b0100001;
        rd = 4'd1;
        rn = 4'd1;
        rm = 4'd0;
        rs = 4'd0;
        cond = 4'd0;
        en_status = 1'b0;
        clkR; // fetch
        check(1, load_ir, 13);
        check(1, waiting, 14);
        clkR; // execute instruction
        check(0, sel_A, 15);
        check(0, sel_B, 16);
        check(1, en_A, 24);
        check(1, en_B, 25);
        check(3'b001, ALU_op, 17);
        clkR; // write back
        check(1, w_en, 18);
        check(0, wb_sel, 19);

        //print test summary
        if (error_count == 0) begin
            $display("All tests passed!");
        end else begin
            $display("Failed %d tests", error_count);
        end
    end
endmodule: tb_controller