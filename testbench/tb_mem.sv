module tb_mem()

// Inputs
reg clk;
reg [10:0]  addr;
reg [31:0]  data_in;
reg w_en;

// Outputs
wire [31:0]  data_out;

// DUT
intru_mem mem (
    .addr(addr),
    .clk(clk),
    .data_in(data_in),
    .w_en(w_en),
    .data_out(data_out)
);

task clkR;
    begin
        #5;
        clk = 1'b0;
        #5;
        clk = 1'b1;
    end
endtask: clkR

initial begin
    //initial clkR
    clkR;

    //write value 1 to memory address 0
    addr = 0;
    w_en = 1'b1;
    data_in = 32'h00000001;
    clkR;
    w_en = 1'b0;

    //read value from memory address 0
    #1;
    addr = 0;
    
end
endmodule: tb_mem