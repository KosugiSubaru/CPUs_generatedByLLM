module mem_ctrl_buffer_16bit (
    input  wire [15:0] i_in,  // CPU内部からの書き込みデータ (rs2)
    output wire [15:0] o_out  // メモリへ向かうデータバス
);

    // パタン構造化：1bitバッファを16個並列に配置
    // 論理的には直結と同じだが、回路図上でデータバスの「出口」を視覚化する
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : bit_slice_buffer
            mem_ctrl_buffer_1bit u_buf_bit (
                .i_in  (i_in[i]),
                .o_out (o_out[i])
            );
        end
    endgenerate

endmodule