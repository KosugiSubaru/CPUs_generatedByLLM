module control_unit_writeback_selector (
    input  wire [15:0] i_onehot,
    output wire [1:0]  o_wb_sel // 00: ALU Result, 01: Memory Data, 10: PC+2
);

    // 各書き戻しソースを選択するための有効化信号を生成
    // 論理合成後の回路図で、どの命令群がどのデータパスを選択するかがORゲートの束として視覚化される

    wire w_sel_mem;
    wire w_sel_pc_link;

    // load命令 (opcode: 10) の場合にデータメモリからの読み出しを選択
    assign w_sel_mem = i_onehot[10];

    // jal (opcode: 14) または jalr (opcode: 15) の場合に復帰アドレス(PC+2)を選択
    assign w_sel_pc_link = i_onehot[14] | i_onehot[15];

    // セレクタ制御信号へのマッピング
    // 01: Memory
    // 10: PC+2
    // 00: ALU (デフォルト: R形式およびaddi, loadi等)
    assign o_wb_sel[0] = w_sel_mem;
    assign o_wb_sel[1] = w_sel_pc_link;

endmodule