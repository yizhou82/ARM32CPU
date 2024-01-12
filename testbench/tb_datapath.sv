module tb_datapath(output err);
  // your implementation here

  //regs for testbench
  reg [31:0] datapath_in, datapath_out, imme_data, shift_imme;
  reg wb_sel;
  reg [3:0] w_addr, A_addr, B_addr, shift_addr;
  reg w_en, clk;
  reg en_A, en_B, en_S, en_status;
  reg [1:0] shift_op;
  reg sel_A, sel_B, sel_shift;
  reg [2:0] ALU_op;
  reg [31:0] status_out;
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
          clk = 1'b0;
          #5;
          clk = 1'b1;
          #5;
      end
  endtask: clkR

  // DUT
  datapath datapath(
      .wb_sel(wb_sel),
      .A_addr(A_addr),
      .B_addr(B_addr),
      .shift_addr(shift_addr),
      .en_A(en_A),
      .en_B(en_B),
      .en_S(en_S),
      .shift_op(shift_op),
      .shift_imme(shift_imme),
      .sel_shift(sel_shift),
      .sel_post_shift(sel_post_shift),
      .sel_A(sel_A),
      .sel_B(sel_B),
      .imme_data(imme_data),
      .PC(PC),
      .ALU_op(ALU_op),
      .en_status(en_status),
      .sel_A_in(2'b00),
      .sel_B_in(2'b00),
      .sel_shift_in(1'b1),
      .datapath_out(datapath_out),
      .status_out(status_out)
  );

  integer i = 0;

  initial begin
    wb_sel = 1'b1;
    shift_op = 2'b00;
    ALU_op = 3'b000;
    en_status = 1'b1;

    // write values to every register
    for (i = 0; i < 16; i = i + 1) begin
      datapath_in = i;
      w_addr = i;
      w_en = 1'b1;
      clkR;
    end
    w_en = 1'b0;

    // Test 1 & 2 add values in reg1 and reg2, 1 + 2 * 2 = 5
    sel_A = 1'b0;
    sel_B = 1'b0;

    A_addr = 1;
    en_A = 1'b1;
    B_addr = 2;
    en_B = 1'b1;
    shift_addr = 32'd1;
    sel_shift = 1'b1;
    en_S = 1'b1;
    clkR;
    en_A = 1'b0;
    en_B = 1'b0;
    en_S = 1'b0;

    shift_op = 2'b00;
    sel_A = 1'b0;
    sel_B = 1'b0;
    ALU_op = 3'b000;
    #5;
    check(5, datapath_out, 0, 1);
    clkR;
    check(32'd0, status_out, 0, 2);

    // Test 3 & 4 sel_A and sel_B == 1
    sel_A = 1'b1;
    sel_B = 1'b1;
    imme_data = 32'd12;
    ALU_op = 3'b001;
    #5;
    check(-32'sd12, datapath_out, 0, 3);
    clkR;
    check(32'b10000000000000000000000000000000, status_out, 0, 4);

    //  Test 5 write back into reg 0
    wb_sel = 1'b0;
    w_addr = 0;
    w_en = 1'b1;
    clkR;
    w_en = 1'b0;
    shift_imme = 32'd0;
    sel_shift = 1'b0;
    B_addr = 0;
    en_B = 1'b1;
    en_S = 1'b1;
    clkR;
    en_B = 1'b0;
    en_S = 1'b0;
    sel_A = 1'b1;
    sel_B = 1'b0;
    shift_op = 2'b00;
    ALU_op = 3'b001;
    #5;
    check(32'd12, datapath_out, 0, 5);
    clkR;
    check(32'b00000000000000000000000000000000, status_out, 0, 6);


    //Print test summary
    if (error_count == 0) begin
      $display("All tests passed!");
    end else begin
      $display("Failed %d tests", error_count);
    end
  end


endmodule: tb_datapath
