module tb_datapath(output err);
  // your implementation here

  //regs for testbench
  reg [31:0] datapath_in, datapath_out;
  reg wb_sel;
  reg [3:0] w_addr, r_addr;
  reg w_en, clk;
  reg en_A, en_B, en_C, en_status;
  reg [1:0] shift_op;
  reg sel_A, sel_B;
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
  datapath datapath(.clk(clk), .datapath_in(datapath_in), .wb_sel(wb_sel), .w_addr(w_addr),
    .w_en(w_en), .r_addr(r_addr), .en_A(en_A), .en_B(en_B), .shift_op(shift_op), .sel_A(sel_A),
    .sel_B(sel_B), .ALU_op(ALU_op), .en_C(en_C), .en_status(en_status), .datapath_out(datapath_out),
    .status_out(status_out));

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
      r_addr = i;
      clkR;
    end
    w_en = 1'b0;

    // Test 1 & 2 add values in reg1 and reg2
    sel_A = 1'b0;
    sel_B = 1'b0;

    r_addr = 1;
    en_A = 1'b1;
    clkR;
    en_A = 1'b0;

    r_addr = 2;
    en_B = 1'b1;
    clkR;
    en_B = 1'b0;

    shift_op = 2'b00;
    ALU_op = 3'b000;
    en_C = 1'b1;
    clkR;
    en_C = 1'b0;

    check(3, datapath_out, 0, 1);
    check(32'd0, status_out, 0, 2);

    // Test 3 & 4 sel_A and sel_B == 1
    sel_A = 1'b1;
    sel_B = 1'b1;
    datapath_in = 32'd12;
    ALU_op = 3'b001;
    en_C = 1'b1;
    clkR;
    en_C = 1'b0;

    check(-32'sd12, datapath_out, 0, 3);
    check(32'b10000000000000000000000000000000, status_out, 0, 4);

    //  Test 5 write back into reg 0
    wb_sel = 1'b0;
    w_addr = 0;
    w_en = 1'b1;
    clkR;
    w_en = 1'b0;
    sel_A = 1'b1;
    sel_B = 1'b0;
    r_addr = 0;
    en_B = 1'b1;
    clkR;
    en_B = 1'b0;
    shift_op = 2'b00;
    ALU_op = 3'b000;
    en_C = 1'b1;
    clkR;
    en_C = 1'b0;

    check(-32'sd12, datapath_out, 0, 5);
    check(32'b10000000000000000000000000000000, status_out, 0, 6);


    //Print test summary
    if (error_count == 0) begin
      $display("All tests passed!");
    end else begin
      $display("Failed %d tests", error_count);
    end
  end


endmodule: tb_datapath
