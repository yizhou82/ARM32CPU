module tb_controller(output err);
  
  // regs for testbench
    reg clk, rst_n;
    reg [6:0] opcode;
    reg [1:0] shift_op;
    reg [31:0] status_reg;
    reg [3:0] cond;
    reg P, U, W;
    reg en_status_decode;

    wire waiting;
    wire w_en1, w_en2, w_en_ldr, sel_w_data;
    wire [1:0] sel_A_in, sel_B_in, sel_shift_in;
    wire sel_shift;
    wire en_A, en_B, en_C, en_S;
    wire sel_A, sel_B, sel_post_shift;
    wire [2:0] ALU_op;
    wire en_status;
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
        .en_status_decode(en_status_decode),
        .waiting(waiting),
        .w_en1(w_en1),
        .w_en2(w_en2),
        .w_en_ldr(w_en_ldr),
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
        .en_status(en_status),
        .load_ir(load_ir),
        .load_pc(load_pc),
        .sel_pc(sel_pc),
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
            #5;
            clk = 1'b0;
            rst_n = 1'b1;
            #5;
            rst_n = 1'b0;
            #5;
            rst_n = 1'b1;
        end
    endtask: reset

    task  first4Cycles(input integer startTestNum);
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
            clkR; // decode
        end
    endtask: first4Cycles

    task executeCycle_MOV_I(input integer startTestNum); //+
        clkR; // execute instruction
        check(0, sel_A_in, startTestNum);
        check(0, sel_B_in, startTestNum + 1);
        check(2'b00, sel_shift_in, startTestNum + 2);
        check(0, en_A, startTestNum + 3);
        check(0, en_B, startTestNum + 4);
        check(0, en_S, startTestNum + 5);
        check(0, sel_shift, startTestNum + 6);
    endtask: executeCycle_MOV_I

    task executeCycle_MOV_R(input integer startTestNum); //+
        clkR; // execute instruction
        check(0, sel_A_in, startTestNum);
        check(0, sel_B_in, startTestNum + 1);
        check(0, sel_shift_in, startTestNum + 2);
        check(0, en_A, startTestNum + 3);
        check(1, en_B, startTestNum + 4);
        check(1, en_S, startTestNum + 5);
        check(0, sel_shift, startTestNum + 6);
    endtask: executeCycle_MOV_R

    task executeCycle_MOV_RS(input integer startTestNum); //+
        clkR; // execute instruction
        check(0, sel_A_in, startTestNum);
        check(0, sel_B_in, startTestNum + 1);
        check(0, sel_shift_in, startTestNum + 2);
        check(0, en_A, startTestNum + 3);
        check(1, en_B, startTestNum + 4);
        check(1, en_S, startTestNum + 5);
        check(1, sel_shift, startTestNum + 6);
    endtask: executeCycle_MOV_RS

    task executeCycle_I(input integer startTestNum); //+
        clkR; // execute instruction
        check(0, sel_A_in, startTestNum);
        check(0, sel_B_in, startTestNum + 1);
        check(0, sel_shift_in, startTestNum + 2);
        check(1, en_A, startTestNum + 3);
        check(0, en_B, startTestNum + 4);
        check(0, en_S, startTestNum + 5);
        check(0, sel_shift, startTestNum + 6);
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

        check(0, sel_shift_in, startTestNum + 2);

        check(1, en_A, startTestNum + 3);

        if (mode == 2) begin
            check(1, en_B, startTestNum + 4);
        end else begin
            check(0, en_B, startTestNum + 4);
        end

        if (mode == 2) begin
            check(1, en_S, startTestNum + 5);
        end else begin
            check(0, en_S, startTestNum + 5);
        end
        

        if (mode == 2) begin
            check(1, sel_shift, startTestNum + 6);
        end else begin
            check(0, sel_shift, startTestNum + 6);  //dont shift by anything
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

    task mem_writeback_MOV_R_RS(input integer startTestNum, input [2:0] ALU_op_ans);
        clkR; // mem 1 + write back
        check(1, sel_A, startTestNum);
        check(0, sel_B, startTestNum + 1);
        check(0, sel_post_shift, startTestNum + 2);
        check(ALU_op_ans, ALU_op, startTestNum + 3);
        check(0, sel_w_data, startTestNum + 4);
        check(1, w_en1, startTestNum + 5);
    endtask: mem_writeback_MOV_R_RS

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
    endtask: mem_wait

    task write_back_LDR(input integer startTestNum);
        clkR; // mem 2
        check(1, w_en_ldr, startTestNum);
    endtask: write_back_LDR

    initial begin
        // Test 1: ADD_R reg0 + reg1 to reg 2
        first4Cycles(0);
        opcode = 7'b0011000;
        cond = 4'b1110;
        executeCycle_R(7);
        mem_writeback_R_RS(14, 3'b000);
        mem_wait(20);

        // Test 2: Mov_R reg0 divide by 2 to reg 1
        first4Cycles(14);
        opcode = 7'b0010000;
        cond = 4'b1110;
        executeCycle_MOV_R(21);
        mem_writeback_MOV_R_RS(28, 3'b000);
        mem_wait(34);

        // Test 3: SUB_RS 1 to reg 1
        first4Cycles(34);
        opcode = 7'b0111001;
        cond = 4'b1110;
        executeCycle_RS(41);
        mem_writeback_R_RS(48, 3'b001);
        mem_wait(54);

        // Test 4: LDR_LIT with P == 0, U ==1
        first4Cycles(54);
        opcode = 7'b1000010;
        cond = 4'b1110;
        P = 1'b0;
        U = 1'b1;
        executeCycle_LDR_STR(61, 1);
        mem_writeback_STR_LDR(68, 0, 1, 1, 0);
        mem_wait(74);
        write_back_LDR(74);

        // Test 5: LDR_I with P == 1, U == 0
        first4Cycles(75);
        opcode = 7'b1100100;
        cond = 4'b1110;
        P = 1'b1;
        U = 1'b0;
        executeCycle_LDR_STR(82, 0);
        mem_writeback_STR_LDR(89, 1, 0, 0, 0);
        mem_wait(95);
        write_back_LDR(95);

        //Test 6: STR_R with P == 1, U == 1
        first4Cycles(96);
        opcode = 7'b1111110;
        cond = 4'b1110;
        P = 1'b1;
        U = 1'b1;
        executeCycle_LDR_STR(103, 2);
        mem_writeback_STR_LDR(110, 1, 1, 2, 1);
        mem_wait(116);

        //print test summary
        if (error_count == 0) begin
            $display("All tests passed!");
        end else begin
            $display("Failed %d tests", error_count);
        end
    end
endmodule: tb_controller