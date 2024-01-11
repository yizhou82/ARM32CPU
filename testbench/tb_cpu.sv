module tb_cpu(output err);

    reg clk, rst_n;
    reg [31:0] instr;
    wire waiting;
    wire [31:0] status_out;
    wire [31:0] datapath_out;
    integer error_count = 0;

    // tasks
    task check(input [31:0] expected, input [31:0] actual, input [3:0] addr, integer test_num);
        begin
            if (expected !== actual) begin
            $error("Test %d failed. Expected: %d, Actual: %d", test_num, expected, actual);
            error_count = error_count + 1;
            end else begin
            $display("Test %d passed.", test_num);
            end
        end
    endtask: check

    // clk task
    task clkR;
        begin
            clk = 1'b0;
            #5;
            clk = 1'b1;
            #5;
        end
    endtask: clkR

    // reset task
    task reset;
        begin
            rst_n = 1'b1;
            #5;
            rst_n = 1'b0;
            #5;
            rst_n = 1'b1;
        end
    endtask: reset

    //cycle and reset
    task clkRst;
        begin
            reset;
            clkR;
            clkR;
            clkR;
            clkR;
        end
    endtask: clkRst
    
    // Instantiate the CPU module
    cpu DUT (
        .clk(clk),
        .rst_n(rst_n),
        .instr(instr),
        .waiting(waiting),
        .status_out(status_out),
        .datapath_out(datapath_out)
    );
    
    integer i = 0;
    initial begin
        //load every register with value of register number
        instr = 32'b1110_00111010_0000_0000_000000000001; // MOV R0, #0

        for (i = 0; i < 16; i = i + 1) begin
            clkRst;
            instr = instr + (32'd1 << 12); //increment the register addr
            instr = instr + 32'd1;       //increment the register value
        end
        //need to have a **negedge** rst_n

        // Test 1: ADD R0, R0, R0
        //ADD R0, R0, R0
        instr = 32'b0000_00001001_0000_00000000_00000000;
        clkRst;
        check(32'b00000000_00000000_00000000_00000000, status_out, 0, 1);
        check(32'd2, datapath_out, 0, 1);

        // Test 2: ADD R1, R1, R0
        //ADD R0, R0, R0
        instr = 32'b0000_00_0_0100_1_0001_0001_0000_00000000; //b0000_00101001_0001_0001_0000_00001000
        clkRst;
        check(32'b00000000_00000000_00000000_00000000, status_out, 0, 1);
        check(32'd4, datapath_out, 0, 1);

        // Test 2: ADD R1, R1, #8
        instr = 32'b0000_00_1_0100_1_0001_0001_000000001000;
        clkRst;
        check(32'b00000000_00000000_00000000_00000000, status_out, 0, 2);
        check(32'd12, datapath_out, 0, 2);



        // Test 3: ADD R2, R2, R0 << R2
        instr = 32'b1110_00_0_0100_0_0010_0010_0010_0_00_1_0000;
        clkRst;
        check(32'b00000000_00000000_00000000_00000000, status_out, 0, 3);
        check(32'd19, datapath_out, 0, 3);


        instr = 32'b1110_00_0_0100_1_0000_0000_00000_00_0_0001; // ADD_R R0, R0, R1
        clkRst;
        check(32'b00000000_00000000_00000000_00000000, status_out, 0, 4);
        check(32'd14, datapath_out, 0, 4);

    end
endmodule
