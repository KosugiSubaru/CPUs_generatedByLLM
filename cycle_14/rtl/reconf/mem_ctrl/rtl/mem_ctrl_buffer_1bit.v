module mem_ctrl_buffer_1bit (
    input  wire i_in,  // CPU内部からの1ビットデータ
    output wire o_out  // メモリポートへ出力される1ビットデータ
);

    // 1ビット信号の通過点
    // 論理的には直結だが、回路図上でデータバスの終端をブロックとして表現する
    assign o_out = i_in;

endmodule