module tb_shifter(output err);
  //regs
  reg [31:0] shift_in, shift_amt;
  reg [1:0] shift_op;
  integer error_count = 0;

  //wires
  wire [31:0] shift_out;

  //internal modules
  shifter shifter(.shift_in(shift_in), .shift_op(shift_op), .shift_amt(shift_amt), .shift_out(shift_out));

  //tasks
  task check(input [31:0] expected, input [31:0] actual, integer test_num);
      begin
          if (expected !== actual) begin
          $error("Test %d failed. Expected: %d, Actual: %d", test_num, expected, actual);
          error_count = error_count + 1;
          end
      end
  endtask: check

  initial begin
    
    #5;
    //test left shift no sign extension
    shift_in = 32'b10101010101010101010101010101010;
    shift_op = 2'b00;
    shift_amt = 32'b0001;
    #5;
    check(32'b01010101010101010101010101010100, shift_out, 1);
    #5;

    //test right shift no sign extension
    shift_in = 32'b10101010101010101010101010101010;
    shift_op = 2'b01;
    shift_amt = 32'b0001;
    #5;
    check(32'b01010101010101010101010101010101, shift_out, 2);
    #5;

    //test right shift with sign extension
    shift_in = 32'b10101010101010101010101010101010;
    shift_op = 2'b10;
    shift_amt = 32'b0001;
    #5;
    check(32'b11010101010101010101010101010101, shift_out, 3);
    #5;

    //test rotate right
    shift_in = 32'b10101010101010101010101010101111;
    shift_op = 2'b11;
    shift_amt = 32'd4;
    #5;
    check(32'b11111010101010101010101010101010, shift_out, 4);
    #5;

    //print test summary
    if (error_count == 0) begin
      $display("All tests passed!");
    end else begin
      $display("Failed %d tests", error_count);
    end
  end
endmodule: tb_shifter
