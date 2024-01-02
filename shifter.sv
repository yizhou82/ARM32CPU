module shifter(input [31:0] shift_in, input [1:0] shift_op, output reg [31:0] shift_out);
  
  reg[31:0] out1;

  assign shift_out = out1;

  always_comb begin
    case (shift_op)
      2'b00: begin
        out1 <= shift_in;
      end
      2'b01: begin
        out1 <= shift_in << 1;
      end
      2'b10: begin
        out1 <= shift_in >> 1;
      end
      2'b11: begin
        out1 <= {shift_in[31:31], shift_in[31:1]};
      end
      default:;
    endcase
  end

endmodule: shifter
