module pc (input clk, input [1:0] sel_pc, input load_pc,
           input [10:0] start_pc, input [10:0] dp_pc,   //dp_pc == datapath pc
           output [10:0] pc_out);

    reg [31:0] pc_reg;
    wire [31:0] pc_in;

    assign pc_out = pc_reg;
    assign pc_in = pc_reg + 1;

    always_ff @(posedge clk) begin
        if (load_pc == 1'b1) begin
            case (sel_pc)
                2'b01: begin
                    pc_reg <= start_pc;
                end
                2'b11: begin
                    pc_reg <= dp_pc;
                end
                default: pc_reg <= pc_in;
            endcase
        end
    end
endmodule: pc