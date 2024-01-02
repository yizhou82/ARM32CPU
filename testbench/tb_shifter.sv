module tb_shifter(output err);
  
  reg[31:0] shift_in;
  reg[1:0] shift_op;
  wire[31:0] shift_out;
  reg error = 1'b0;
  assign err = error;

  shifter DUT(.shift_in(shift_in), .shift_op(shift_op), .shift_out(shift_out));

  initial begin

    //test no shift
    shift_in = 32'b11000000_00000000_00000000_00000111;
    shift_op = 2'b00;
    #10;
    assert(shift_out === 32'b11000000_00000000_00000000_00000111) $display("[PASS] Test no shift from Manual");
    else begin
      error = 1'b1;
      $error("[FAIL] Test no shift from Manual");
    end

    //test left shift
    shift_op = 2'b01;
    #10;
    assert(shift_out === 32'b1000000_00000000_00000000_000001110) $display("[PASS] Test left shift from Manual");
    else begin
      error = 1'b1;
      $error("[FAIL] Test left shift from Manual");
    end

    //test right shift
    shift_op = 2'b10;
    #10;
    assert(shift_out === 32'b011000000_00000000_00000000_0000011) $display("[PASS] Test right shift from Manual");
    else begin
      error = 1'b1;
      $error("[FAIL] Test right shift from Manual");
    end

    //test arithetic right shift
    shift_op = 2'b11;
    #10;
    assert(shift_out === 32'b111000000_00000000_00000000_0000011) $display("[PASS] Test arithetic right shift from Manual");
    else begin
      error = 1'b1;
      $error("[FAIL] Test arithetic right shift from Manual");
    end
    
  end
endmodule: tb_shifter