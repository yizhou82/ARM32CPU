module ALU(input [31:0] val_A, input [31:0] val_B, input [2:0] ALU_op, output [31:0] ALU_out, output [31:0] flags);
  
  // Assume we do not pass a number greater than 2^31, since all are SIGNED values

  reg [31:0] out1;
  reg [31:0] out2;

  reg [63:0] temp;

  assign ALU_out = out1;
  assign flags = out2;

  always_comb begin
    out2 = 32'd0;
    case (ALU_op)
      3'b000: begin // Addition
        out1 = $signed(val_A) + $signed(val_B);
        out2[28] = ((val_A[31] & val_B[31] & ~out1[31]) | (~val_A[31] & ~val_B[31] & out1[31]));
      end
      3'b001: begin // Subtraction
        out1 = $signed(val_A) - $signed(val_B);
        out2[28] = ((val_A[31] ^ val_B[31] & out1[31]) != val_A[31]);
      end
      3'b010: begin // AND
        out1 = val_A & val_B;
      end
      3'b011: begin // OR
        out1 = val_A | val_B;
      end
      3'b100: begin // Multiplication
        temp = $signed(val_A) * $signed(val_B);
        out1 = temp[31:0];
        out2[28] = (temp[63:32] != 32'h0 && temp[63:32] != 32'hFFFFFFFF) || (temp[63] != temp[31]);
      end
      3'b101: begin // Division
        out1 = ($signed(val_B) == 0) ? 0 : $signed(val_A) / $signed(val_B);
        out2[29] = (val_B == 0) ? 1 : 0;
      end
      3'b110: begin // NOT
        out1 = ~val_B;
      end
      3'b111: begin // XOR
        out1 = val_A ^ val_B;
      end
      default: begin
        out1 = val_A;
        out2 = 0;
        temp = 0;
      end
    endcase

    /*
      Output flags: 31, 30, 29, 28, and 19:16

      31: Negative flag
      30: Zero flag
      29: Invalid flag
      28: Overflow flag
      19: Greater than or Equal flag
      18: Less than flag
      17: Greater than flag
      16: Less than or Equal flag
    */

    // Negative flag
    out2[31] = out1[31]; // MSB

    // Zero flag
    out2[30] = (out1 == 0) ? 1 : 0;

    // Greater than or Equal flags
    // out2[16] = val_A[7:0] >= val_B[7:0];   // Lower 8 bits
    // out2[17] = val_A[15:8] >= val_B[15:8]; // Next 8 bits
    // out2[18] = val_A[23:16] >= val_B[23:16]; // Next 8 bits
    // out2[19] = val_A[31:24] >= val_B[31:24]; // Upper 8 bits

  end



endmodule: ALU
