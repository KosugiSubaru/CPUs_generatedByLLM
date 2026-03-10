module alu_unit_mux8_1bit (
    input  wire [2:0] i_sel,
    input  wire       i_d0, // Addition
    input  wire       i_d1, // Subtraction
    input  wire       i_d2, // And
    input  wire       i_d3, // Or
    input  wire       i_d4, // Xor
    input  wire       i_d5, // Not
    input  wire       i_d6, // SRA
    input  wire       i_d7, // SLA
    output wire       o_y
);

    // 8入力1出力セレクタ
    assign o_y = (i_sel == 3'b000) ? i_d0 :
                 (i_sel == 3'b001) ? i_d1 :
                 (i_sel == 3'b010) ? i_d2 :
                 (i_sel == 3'b011) ? i_d3 :
                 (i_sel == 3'b100) ? i_d4 :
                 (i_sel == 3'b101) ? i_d5 :
                 (i_sel == 3'b110) ? i_d6 : i_d7;

endmodule