module next_pc_logic_mux_2to1_16bit (
    input  wire        i_sel,
    input  wire [15:0] i_d0,
    input  wire [15:0] i_d1,
    output wire [15:0] o_data
);

    // セレクト信号に基づき、2つの16ビット入力から1つを選択
    // 論理合成後の回路図において、4to1 MUXを構成する基本ブロックとして視覚化される
    assign o_data = (i_sel == 1'b1) ? i_d1 : i_d0;

endmodule