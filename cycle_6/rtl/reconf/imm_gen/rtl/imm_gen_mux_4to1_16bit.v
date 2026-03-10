module imm_gen_mux_4to1_16bit (
    input  wire [1:0]  i_sel,
    input  wire [15:0] i_d0,
    input  wire [15:0] i_d1,
    input  wire [15:0] i_d2,
    input  wire [15:0] i_d3,
    output wire [15:0] o_y
);

    // 制御信号(i_imm_type)に基づき、4つの即値フォーマットから1つを選択
    // 論理合成後の回路図でセレクタとして視覚化されるよう、条件演算子を使用
    assign o_y = (i_sel == 2'b00) ? i_d0 :
                 (i_sel == 2'b01) ? i_d1 :
                 (i_sel == 2'b10) ? i_d2 : i_d3;

endmodule