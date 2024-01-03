module controller(input clk, input rst_n,
                  input [6:0] opcode, input [1:0] shift_op,
                  input [31:0] status_reg,
                  output waiting,
                  output [1:0] reg_sel, output [1:0] wb_sel, output w_en,
                  output en_A, output en_B, output en_C, output en_status,
                  output sel_A, output sel_B, output load_ir, output load_pc, output clear_pc,
                  output load_addr, output sel_addr, output ram_w_en);