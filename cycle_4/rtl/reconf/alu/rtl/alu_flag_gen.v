module alu_flag_gen (
    input  wire [15:0] i_rd,
    input  wire [15:0] i_rs1,
    input  wire [15:0] i_rs2,
    input  wire [3:0]  i_opcode,
    output wire        o_flag_z,
    output wire        o_flag_n,
    output wire        o_flag_v
);

    wire w_v_add;
    wire w_v_sub;

    assign o_flag_z = (i_rd == 16'h0000);
    assign o_flag_n = i_rd[15];

    assign w_v_add = (i_rs1[15] == 1'b1 && i_rs2[15] == 1'b1 && i_rd[15] == 1'b0) || 
                     (i_rs1[15] == 1'b0 && i_rs2[15] == 1'b0 && i_rd[15] == 1'b1);

    assign w_v_sub = (i_rs1[15] == 1'b0 && i_rs2[15] == 1'b1 && i_rd[15] == 1'b1) || 
                     (i_rs1[15] == 1'b1 && i_rs2[15] == 1'b0 && i_rd[15] == 1'b0);

    assign o_flag_v = (i_opcode == 4'b0000) ? w_v_add : // addition
                      (i_opcode == 4'b1000) ? w_v_add : // addi
                      (i_opcode == 4'b0001) ? w_v_sub : // subtraction
                      1'b0;

endmodule