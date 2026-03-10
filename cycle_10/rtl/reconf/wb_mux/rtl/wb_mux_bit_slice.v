module wb_mux_bit_slice (
    input  wire       i_bit0,
    input  wire       i_bit1,
    input  wire       i_bit2,
    input  wire       i_bit3,
    input  wire [1:0] i_sel,
    output wire       o_bit
);

    // 2ビットの選択信号に基づき、4つの入力ビットから1つを選択する
    // CPUのライトバック・マルチプレクサを構成する最小単位
    assign o_bit = (i_sel == 2'b00) ? i_bit0 :
                   (i_sel == 2'b01) ? i_bit1 :
                   (i_sel == 2'b10) ? i_bit2 :
                                      i_bit3;

endmodule