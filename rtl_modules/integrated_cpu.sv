module integrated_cpu(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    // cpu inputs
    reg clk;
    reg rst_n;
    reg [10:0] start_pc;
    assign clk = CLOCK_50;
    assign rst_n = KEY[0];
    assign start_pc = {1'b0, SW};

    // cpu outputs
    wire waiting;
    wire ram_w_en1;
    wire ram_w_en2;
    wire [10:0] ram_addr2;
    wire [31:0] ram_in2;
    wire [31:0] status_out;
    wire [31:0] datapath_out;

    // pc outputs
    wire [10:0] pc_out;

    // duel_ram outputs
    wire [31:0] ram_data1;
    wire [31:0] ram_data2;

    // cpu module
    cpu cpu(
        .clk(clk),
        .rst_n(rst_n),
        .instr(ram_data1),
        .start_pc(start_pc),
        .ram_data2(ram_data2),
        .waiting(waiting),
        .ram_w_en1(ram_w_en1),
        .ram_w_en2(ram_w_en2),
        .ram_addr2(ram_addr2),
        .ram_in2(ram_in2),
        .status_out(status_out),
        .datapath_out(datapath_out),
        .pc_out(pc_out)
    );

    // duel_ram module
    duel_mem duel_mem(
        .clock(clk),
        .wren_a(ram_w_en1),
        .wren_b(ram_w_en2),
        .address_a(pc_out),
        .address_b(ram_addr2),
        .data_a(32'b0),
        .data_b(ram_in2),
        .q_a(ram_data1),
        .q_b(ram_data2)
    );
endmodule: integrated_cpu