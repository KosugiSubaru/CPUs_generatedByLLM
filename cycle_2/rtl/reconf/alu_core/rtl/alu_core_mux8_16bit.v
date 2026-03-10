module alu_core_mux8_16bit (
    input  wire [2:0]  i_sel,
    input  wire [15:0] i_d0,
    input  wire [15:0] i_d1,
    input  wire [15:0] i_d2,
    input  wire [15:0] i_d3,
    input  wire [15:0] i_d4,
    input  wire [15:0] i_d5,
    input  wire [15:0] i_d6,
    input  wire [15:0] i_d7,
    output wire [15:0] o_y
);

    genvar i;

    // 16ビットの各ビットに対して、8入力1出力の選択ロジックを生成
    // 物理的な並列構造（ビットスライス構造）を視覚化する
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_mux8_bits
            assign o_y[i] = (i_sel == 3'b000) ? i_d0[i] :
                            (i_sel == 3'b001) ? i_d1[i] :
                            (i_sel == 3'b010) ? i_d2[i] :
                            (i_sel == 3'b011) ? i_d3[i] :
                            (i_sel == 3'b100) ? i_d4[i] :
                            (i_sel == 3'b101) ? i_d5[i] :
                            (i_sel == 3'b110) ? i_d6[i] : i_d7[i];
        end
    endgenerate

endmodule