module integrated_cpu(input clk, input rst_n, input [10:0] start_pc);

    // cpu outputs
    wire waiting;
    wire [1:0] sel_pc;
    wire [10:0] memory_out;
    wire sel_ram_addr2;
    wire ram_w_en1;
    wire ram_w_en2;
    wire [10:0] ram_addr1;
    wire [31:0] ram_in2;
    wire [31:0] status_out;
    wire [31:0] datapath_out;
    reg [10:0] ram_addr2;


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
        .ram_data2(ram_data2),
        .PC(pc_out),
        .waiting(waiting),
        .sel_pc(sel_pc),
        .memory_out(memory_out),
        .sel_ram_addr2(sel_ram_addr2),
        .ram_w_en1(ram_w_en1),
        .ram_w_en2(ram_w_en2),
        .ram_addr1(ram_addr1),
        .ram_addr2(ram_addr2),
        .ram_in2(ram_in2),
        .status_out(status_out),
        .datapath_out(datapath_out)
    );

    // pc module
    pc pc(
        .clk(clk),
        .sel_pc(sel_pc),
        .start_pc(start_pc),
        .dp_pc(memory_out),
        .pc_out(pc_out)
    );

    // duel_ram module
    duel_ram duel_ram(
        .clock(clk),
        .wren_a(ram_w_en1),
        .wren_b(ram_w_en2),
        .address_a(ram_addr1),
        .address_b(ram_addr2),
        .data_a(32'b0),
        .data_b(ram_in2),
        .q_a(ram_data1),
        .q_b(ram_data2)
    );

    //Mux for ram_addr2
    always_comb begin
        if (sel_ram_addr2 == 1'b0) begin
            ram_addr2 = memory_out;
        end else begin
            ram_addr2 = 11'b0; //TODO: Rt
        end
    end
endmodule: integrated_cpu