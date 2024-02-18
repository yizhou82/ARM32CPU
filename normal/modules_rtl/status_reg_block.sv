module status_reg_block (input clk, input en_status, input status_rdy, input [31:0] status_in, output [31:0] status_out);
    reg [31:0] status_reg;

    assign status_out = (status_rdy == 1'b1) ? status_in : status_reg;

    always @(posedge clk) begin
        if (en_status == 1'b1) begin
            status_reg <= status_in;
        end
    end
endmodule: status_reg_block