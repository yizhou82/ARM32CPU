module controller(input clk, input rst_n,
                input [6:0] opcode, input [31:0] status_reg, input [3:0] cond,
                input P, input U, input W, input en_status_decode,
                output waiting,                                                                                 //no use yet
                output w_en1, output w_en2, output w_en3, output forward_w_data,                                //regfile
                output [1:0] sel_A_in, output [1:0] sel_B_in, output [1:0] sel_shift_in, output sel_shift,      //forwarding muxes
                output en_A, output en_B, output en_C, output en_S,                                             //load regs stage
                output sel_A, output sel_B, output sel_post_shift, output [2:0] ALU_op,                         //execute stage
                output en_status,                                                                               //status reg
                output load_ir,                                                                                 //instruction register
                output load_pc, output [1:0] sel_pc,                                                            //program counter
                output ram_w_en1, output ram_w_en2);                                                            //ram 

    /*

    Load/Store Instructions - TBA
    - P = 1 -> Pre-Indexing
    - P = 0 -> Post-Indexing
    - U = 1 -> Offset is positive
    - U = 0 -> Offset is negative
    - W = 1 -> Write back to base register
    - W = 0 -> Do not write back to base register
    */

    // localparam for states

    //move all the local param values 1 value higher
    localparam [3:0] reset = 4'd0;
    localparam [3:0] load_pc_loop = 4'd1;
    localparam [3:0] fetch = 4'd2;
    localparam [3:0] fetch_wait = 4'd3;
    localparam [3:0] decode = 4'd4;
    localparam [3:0] execute = 4'd5;
    localparam [3:0] memory = 4'd6;
    localparam [3:0] memory_wait = 4'd7;
    localparam [3:0] write_back = 4'd8;
    localparam [3:0] load_pc_start = 4'd9;

    // localparam for specific instructions
    localparam [6:0] NOP = 7'b0000000;
    localparam [6:0] HLT = 7'b0000001;
    localparam [6:0] MOV_I = 7'b0001000;
    localparam [3:0] CMP = 4'b1010; //some overlap with none but should be fine

    // localparam for ALU_op
    localparam [2:0] ADD = 3'b000;
    localparam [2:0] SUB = 3'b001;
    localparam [2:0] AND = 3'b010;
    localparam [2:0] ORR = 3'b011;
    localparam [2:0] XOR = 3'b111;

    // reg for state
    reg [3:0] state;
    reg start = 1'b0;

    // reg for output
    reg waiting_reg;
    reg w_en1_reg;
    reg w_en2_reg;
    reg w_en3_reg;
    reg forward_w_data_reg;
    reg sel_w_data_reg;
    reg [1:0] sel_A_in_reg;
    reg [1:0] sel_B_in_reg;
    reg [1:0] sel_shift_in_reg;
    reg sel_shift_reg;
    reg en_A_reg;
    reg en_B_reg;
    reg en_C_reg;
    reg en_S_reg;
    reg sel_A_reg;
    reg sel_B_reg;
    reg sel_post_shift_reg;
    reg [2:0] ALU_op_reg;
    reg en_status_reg;
    reg load_ir_reg;
    reg load_pc_reg;
    reg sel_pc_reg;
    reg load_addr_reg;
    reg [10:0] ram_addr1_reg;
    reg [10:0] ram_addr2_reg;
    reg ram_w_en1_reg;
    reg ram_w_en2_reg;

    // assign output
    assign waiting = waiting_reg;
    assign w_en1 = w_en1_reg;
    assign w_en2 = w_en2_reg;
    assign w_en3 = w_en3_reg;
    assign forward_w_data = forward_w_data_reg;
    assign sel_w_data = sel_w_data_reg;
    assign sel_A_in = sel_A_in_reg;
    assign sel_B_in = sel_B_in_reg;
    assign sel_shift_in = sel_shift_in_reg;
    assign sel_shift = sel_shift_reg;
    assign en_A = en_A_reg;
    assign en_B = en_B_reg;
    assign en_C = en_C_reg;
    assign en_S = en_S_reg;
    assign sel_A = sel_A_reg;
    assign sel_B = sel_B_reg;
    assign sel_post_shift = sel_post_shift_reg;
    assign ALU_op = ALU_op_reg;
    assign en_status = en_status_reg;
    assign load_ir = load_ir_reg;
    assign load_pc = load_pc_reg;
    assign sel_pc = sel_pc_reg;
    assign load_addr = load_addr_reg;
    assign ram_addr1 = ram_addr1_reg;
    assign ram_addr2 = ram_addr2_reg;
    assign ram_w_en1 = ram_w_en1_reg;
    assign ram_w_en2 = ram_w_en2_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            state <= reset;
        end else begin
            case (state)
                reset: begin
                    state <= load_pc_start;
                end
                load_pc_start: begin
                    state <= fetch;
                end
                load_pc_loop: begin
                    state <= fetch;
                end
                fetch: begin
                    state <= fetch_wait;
                end
                fetch_wait: begin
                    state <= decode;
                end
                decode: begin
                    state <= execute;
                end
                execute: begin
                    state <= memory;
                end
                memory: begin
                    state <= memory_wait;
                end
                memory_wait: begin
                    state <= write_back;
                end
                write_back: begin
                    state <= load_pc_loop;
                    start <= 1'b0; //end of cycle
                end
                default: begin
                    state <= reset;
                    start <= 1'b0;
                end
            endcase
        end
    end

    always_comb begin
        //default set all output to 0        
        waiting_reg = 1'b0;
        w_en1_reg = 1'b0;
        w_en2_reg = 1'b0;
        w_en3_reg = 1'b0;
        forward_w_data_reg = 1'b0;
        sel_w_data_reg = 1'b0;
        sel_A_in_reg = 2'b00;
        sel_B_in_reg = 2'b00;
        sel_shift_in_reg = 1'b0;
        sel_shift_reg = 1'b0;
        en_A_reg = 1'b0;
        en_B_reg = 1'b0;
        en_C_reg = 1'b0;
        en_S_reg = 1'b0;
        sel_A_reg = 1'b0;
        sel_B_reg = 1'b0;
        sel_post_shift_reg = 1'b0;
        ALU_op_reg = 3'b000;
        en_status_reg = 1'b0;
        load_ir_reg = 1'b0;
        load_pc_reg = 1'b0;
        load_addr_reg = 1'b0;
        ram_addr1_reg = 11'b0;
        ram_addr2_reg = 11'b0;
        ram_w_en1_reg = 1'b0;
        ram_w_en2_reg = 1'b0;

        //state behaviour for outputi
        case (state)
            reset: begin
                waiting_reg = 1'b1;
            end
            load_pc_start: begin
                waiting_reg = 1'b1;
                load_pc_reg = 1'b1;
                sel_pc_reg = 2'b01;
            end
            load_pc_loop: begin
                waiting_reg = 1'b1;
                load_pc_reg = 1'b1;
                sel_pc_reg = 2'b00;
            end
            fetch: begin            //fetch from ram
                waiting_reg = 1'b1;
            end
            fetch_wait: begin
                waiting_reg = 1'b1;
            end
            decode: begin
                waiting_reg = 1'b1;
                load_ir_reg = 1'b1;
            end
            execute: begin
                waiting_reg = 1'b1;
                /*
                take care of:
                - sel_A_in
                - sel_B_in
                - en_A
                - en_B
                - sel_shift_in
                - sel_shift
                - en_S
                */
                //normal instructions
                if (opcode[6] == 0 && cond != 4'b1111)  begin
                    //sel_A_in
                    //sel_B_in

                    //en_A
                    if (opcode[3] == 1'b1) begin
                        en_A_reg = 1'b1;
                    end

                    //en_B
                    if (opcode[4] == 1'b1) begin
                        en_B_reg = 1'b1;
                    end

                    // sel_shift_in, sel_shift, en_S
                    en_S_reg = 1'b1;        //TODO: doesnt affect anything for MOV_I BUT should be changed -> right now too lazy to change tb
                    if (opcode[4] == 1'b1) begin
                        //sel_shift
                        sel_shift_reg = opcode[5];
                        //sel_shift_in TODO: change later when do forwarding
                        sel_shift_in_reg = 2'b00;
                    end else begin
                        //load 0 for shift when the operation is Immediate == not load B
                        sel_shift_reg = 1'b0;
                        sel_shift_in_reg = 2'b00;
                    end
                end else if (opcode[6:5] == 2'b11 || opcode[6:3] == 4'b1000) begin //STR and LDR
                    
                    //immendiate
                    if (opcode[3] == 1'b0) begin
                        //sel_A_in
                        if (opcode[6:4] == 3'b100) begin //LDR_Lit
                            sel_A_in_reg = 2'b11;       //load from PC
                        end //otherwise from Rn

                        //sel_B_in
                        sel_B_in_reg = 2'b00;           //load from imme12

                        // en_A
                        en_A_reg = 1'b1;

                        // en_B
                        en_B_reg = 1'b0;

                        // en_S
                        en_S_reg = 1'b0;

                        // load shift - value of 0
                        sel_shift_reg = 1'b0;

                        //sel_shift_in
                        sel_shift_in_reg = 2'b00;       //load from imme12

                    end else begin  //register
                        //sel_A_in
                        sel_A_in_reg = 2'b00;           //load from Rn

                        //sel_B_in
                        sel_B_in_reg = 2'b00;           //load from Rm

                        //en_A - always from Rn
                        en_A_reg = 1'b1;

                        //en_B - always from Rm
                        en_B_reg = 1'b1;

                        //en_S
                        en_S_reg = 1'b1;

                        //sel_shift
                        sel_shift_reg = 1'b1;

                        //sel_shift_in
                        sel_shift_in_reg = 2'b00;       //load from Rm
                    end
                end
            end
            memory: begin
                waiting_reg = 1'b1;
                en_C_reg = 1'b1;

                //normal instructions
                if (opcode[6] == 0 && cond != 4'b1111)  begin
                    //ALU_op
                    case (opcode[2:0])
                        3'b000: ALU_op_reg = ADD;
                        3'b001: ALU_op_reg = SUB;
                        3'b010: ALU_op_reg = SUB;
                        3'b011: ALU_op_reg = AND;
                        3'b100: ALU_op_reg = ORR;
                        3'b101: ALU_op_reg = XOR;
                        default: ALU_op_reg = ADD;
                    endcase

                    //sel_A -> opposite of load A
                    if (opcode[3] == 1'b0) begin
                        sel_A_reg = 1'b1;
                    end

                    //sel_B -> opposite of load B
                    if (opcode[4] == 1'b0) begin
                        sel_B_reg = 1'b1;
                    end

                    //sel_post_shift
                    sel_post_shift_reg = 1'b0;

                    //sel_w_data
                    sel_w_data_reg = 1'b0;

                    //en_status -> since branching decoding doesnt this rule anymore
                    en_status_reg = en_status_decode;
                    
                    //write_back
                    if (opcode[3:0] != CMP) begin
                        //w_en1
                        w_en1_reg = 1'b1;

                        //w_addr is taken from decoder
                    end

                    //ram memory
                    ram_w_en2_reg = 1'b0;
                end else if (opcode[6:5] == 2'b11 || opcode[6:3] == 4'b1000) begin //STR and LDR
                    /*
                    ALU_op
                    sel_A
                    sel_B
                    sel_post_shift
                    en_status
                    ram_memory
                    */

                    //ALU_op
                    case (U)
                    1'b0: ALU_op_reg = SUB;
                    default: ALU_op_reg = ADD;
                    endcase

                    //sel_A - always from Rn
                    sel_A_reg = 1'b0;

                    //sel_B & sel_post_shift
                    sel_post_shift_reg = ~P;
                    if (opcode[3] == 1'b1) begin
                        //register - load from regB
                        sel_B_reg = 1'b0;
                    end else begin
                        //immediate
                        sel_B_reg = 1'b1;
                    end

                    //sel_w_data -> default
                    sel_w_data_reg = 1'b0;

                    //en_status
                    en_status_reg = en_status_decode;


                    //en_w1 write back
                    w_en1_reg = 1'b0;

                    //ram memory
                    if (opcode[4] == 1'b1) begin //STR
                        ram_w_en2_reg = 1'b1;
                    end else begin //LDR
                        ram_w_en2_reg = 1'b0;
                    end
                end
            end
            memory_wait: begin
                waiting_reg = 1'b1;
                //just a stall for LDR to read from memory
            end
            write_back: begin
                waiting_reg = 1'b1;
                /*
                take care of:
                - w_en
                */
                if (opcode[6:4] == 3'b110 || opcode[6:3] == 4'b1000) begin
                    //w_en2
                    w_en3_reg = 1'b1;
                end
            end
        endcase
    end

endmodule: controller