module alu_mux8_16bit (
    input  wire [2:0]  i_sel,
    input  wire [15:0] i_d0, // Addition
    input  wire [15:0] i_d1, // Subtraction
    input  wire [15:0] i_d2, // AND
    input  wire [15:0] i_d3, // OR
    input  wire [15:0] i_d4, // XOR
    input  wire [15:0] i_d5, // NOT
    input  wire [15:0] i_d6, // SRA
    input  wire [15:0] i_d7, // SLA
    output wire [15:0] o_data
);

    // 8つの演算結果候補から、i_sel信号に従って最終的な演算結果を選択する
    // 下位3ビットの選択信号に基づき、各演算器の出力をルーティングする
    assign o_data = (i_sel == 3'b000) ? i_d0 :
                    (i_sel == 3'b001) ? i_d1 :
                    (i_sel == 3'b010) ? i_d2 :
                    (i_sel == 3'b011) ? i_d3 :
                    (i_sel == 3'b100) ? i_d4 :
                    (i_sel == 3'b101) ? i_d5 :
                    (i_sel == 3'b110) ? i_d6 : i_d7;

endmodule