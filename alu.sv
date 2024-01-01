module ALU(input [31:0] val_A, input [31:0] val_B, input [2:0] ALU_op, output [31:0] ALU_out, output Z);
  
  reg [31:0] out1;
  reg out2;

  assign ALU_out = out1;
  assign Z = out2;

  always_comb begin
    case (ALU_op)
      3'b000: begin
        out1 = val_A + val_B;
      end
      3'b001: begin
        out1 = val_A - val_B;
      end
      3'b010: begin
        out1 = val_A & val_B;
      end
      3'b011: begin
        out1 = val_A | val_B;
      end
      3'b100: begin
        out1 = val_A * val_B;
      end
      3'b101: begin
        out1 = val_A / val_B;
      end
      3'b110: begin
        out1 = ~val_B;
      end
      default:;
    endcase

    if (out1 == 0) begin
      out2 <= 1;
    end
    else begin
      out2 <= 0;
    end
  end



endmodule: ALU
