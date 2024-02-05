`timescale 1 ps / 1 ps
module tb_mem();

// Inputs
reg clk;
reg [10:0]  addr_a, addr_b;
reg [31:0]  data_a, data_b;
reg en_a, en_b;

// Outputs
wire [31:0]  data_out_a, data_out_b;

// DUT
duel_mem mem (
    .address_a(addr_a),
    .address_b(addr_b),
    .clock(clk),
    .data_a(data_a),
    .data_b(data_b),
    .wren_a(en_a),
    .wren_b(en_b),
    .q_a(data_out_a),
    .q_b(data_out_b)
);

task clkR;
    begin
        #5;
        clk = 1'b1;
        #5;
        clk = 1'b0;
    end
endtask: clkR

initial begin
    //initial clkR
    clkR;

    //write value 1 to memory address 0 && val 2 to mem addr 1
    addr_a = 0;
    en_a = 1'b1;
    data_a = 32'h00000001;
    addr_b = 1;
    en_b = 1'b1;
    data_b = 32'h00000002;
    clkR;
    en_a = 1'b0;
    en_b = 1'b0;

    //start reading from memory address 3 so reads should be 0
    addr_a = 3;
    clkR;
    clkR;
    clkR;
    clkR;
    clkR;

    //start reading from memory address 0 so reads should be 1 then addr 1 so reads should be 2 while printing out the values
    addr_a = 0;
    clkR;
    addr_a = 1;
    $display("data_out_a = %d\n", data_out_a);
    clkR;
    $display("data_out_a = %d\n", data_out_b);
    clkR;
    $display("data_out_a = %d\n", data_out_a); 

end
endmodule: tb_mem