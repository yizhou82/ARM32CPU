module datapath(input clk, input [31:0] datapath_in, input wb_sel,
                input [3:0] w_addr, input w_en, input [3:0] r_addr, input en_A,
                input en_B, input [1:0] shift_op, input sel_A, input sel_B,
                input [2:0] ALU_op, input en_C, input en_status,
                output [31:0] datapath_out, output status_out);
  //internal wires
  wire [31:0] w_data, r_data, val_A, val_B, shift_out, ALU_out, status_in;

  //internal regs
  reg [31:0] A_reg, B_reg, C_reg, status_reg;

  // internal connections
  assign status_out = status_reg;
  assign datapath_out = C_reg;

  //internal modules
  regfile regfile(.w_data(w_data), .w_addr(w_addr), .w_en(w_en), .r_addr(r_addr), .clk(clk), .r_data(r_data));
  shifter shifter(.shift_in(shift_in), .shift_op(shift_op), .shift_out(shift_out));
  ALU alu(.val_A(val_A), .val_B(val_B), .ALU_op(ALU_op), .ALU_out(ALU_out), .Z(status_in));

  //muxes
  assign w_data = (wb_sel == 1'b1) ? datapath_in : C_out;
  assign val_A = (sel_A == 1'b1) ? 31'b0 : A_reg;
  assign val_B = (sel_B == 1'b1) ? {20'b0, datapath_in[11:0]} : shift_out; 

  //register A
  always_ff @(posedge clk) begin
    if (en_A == 1'b1) begin
      A_reg <= r_data;
    end
  end

  //register B
  always_ff @(posedge clk) begin
    if (en_B == 1'b1) begin
      B_reg <= r_data;
    end
  end

  //register C
  always_ff @(posedge clk) begin
    if (en_C == 1'b1) begin
      C_reg <= ALU_out;
    end
  end

  //register status
  always_ff @(posedge clk) begin
    if (en_status == 1'b1) begin
      status_reg <= status_in;
    end
  end

  always_comb begin
    
  end
endmodule: datapath
