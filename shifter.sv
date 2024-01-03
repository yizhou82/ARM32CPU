module shifter(input [31:0] shift_in, input [1:0] shift_op, input [31:0] shift_amt, output [31:0] shift_out);
  
  signed reg[31:0] out1;
  
  assign shift_out = out1;

  always_comb begin
    case (shift_op)
      2'b00: begin  //left shift no sign extension
        out1 <= shift_in << shift_amt;
      end
      2'b01: begin //right shift no sign extension
        out1 <= shift_in << shift_amt;
      end
      2'b10: begin //right shift with sign extension
        out1 <= $signed(shift_in >> shift_amt);
      end
      2'b11: begin //rotate right
        out1 <= (shift_in >> shift_amt) | (shift_in << ($bits(shift_in) - shift_amt));
      end
      default:;
    endcase
  end

endmodule: shifter
