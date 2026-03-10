module control_unit_gate_or (
    input  wire [15:0] i_instr_signals,
    input  wire [15:0] i_mask,
    output wire        o_gate_out
);

    // デコーダーから出力された16本の命令信号（ワンホット）に対し、
    // 各制御信号（RegWrite等）を有効化すべき命令を指定する「i_mask」との論理積をとる。
    // その結果、1ビットでも1があれば（対象命令のいずれかが実行中であれば）、信号を有効化（1）する。
    assign o_gate_out = |(i_instr_signals & i_mask);

endmodule