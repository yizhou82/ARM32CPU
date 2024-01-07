module tb_controller(output err);
  
  // regs for testbench
    reg clk, rst_n;
    reg [6:0] opcode;
    reg [1:0] shift_op;
    reg [31:0] status_reg;
    reg en_status;
    reg [3:0] cond;
    reg [3:0] rn;
    reg [3:0] rd;
    reg [3:0] rm;
    reg [3:0] rs;
    reg [31:0] imme_data;
    reg [31:0] shift_imme;

    wire waiting;
    wire [1:0] wb_sel;
    wire sel_A;
    wire sel_B;
    wire sel_shift;
    wire w_en;
    wire en_A;
    wire en_B;
    wire en_C;
    wire en_S;
    wire [2:0] ALU_op;
    wire load_ir;
    wire load_pc;
    wire clear_pc;
    wire load_addr;
    wire sel_addr;
    wire ram_w_en;

    integer error_count = 0;

    //DUT
    controller DUT(
        .clk(clk),
        .rst_n(rst_n),
        .opcode(opcode),
        .cond(cond),
        .waiting(waiting),
        .wb_sel(wb_sel),
        .sel_A(sel_A),
        .sel_B(sel_B),
        .sel_shift(sel_shift),
        .w_en(w_en),
        .en_A(en_A),
        .en_B(en_B),
        .en_C(en_C),
        .en_S(en_S),
        .ALU_op(ALU_op),
        .load_ir(load_ir),
        .load_pc(load_pc),
        .clear_pc(clear_pc),
        .load_addr(load_addr),
        .sel_addr(sel_addr),
        .ram_w_en(ram_w_en)
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

    initial begin
        reset;

        // Test 1: Mov_I 8 to reg 0
        opcode = 7'b0011000;
        rd = 4'd0;
        imme_data = 32'd8;
        cond = 4'd0;
        en_status = 1'b0;
        clkR; // fetch
        check(1, load_ir, 0);
        check(1, waiting, 1);
        clkR; // execute instruction
        check(1, sel_A, 2);
        check(1, sel_B, 3);
        check(3'b000, ALU_op, 4);
        clkR; // write back
        check(1, w_en, 5);
        check(0, wb_sel, 6);


        // Test 2: Mov_R reg0 divide by 2 to reg 1
        reset;
        opcode = 7'b0001000;
        rd = 4'd1;
        rm = 4'd0;
        cond = 4'd0;
        shift_imme = 5'd1;
        shift_op = 2'b01;
        en_status = 1'b0;
        clkR; // fetch
        check(1, load_ir, 5);
        check(1, waiting, 6);
        check(0, sel_shift, 7);
        clkR; // execute instruction
        check(1, sel_A, 8);
        check(0, sel_B, 9);
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