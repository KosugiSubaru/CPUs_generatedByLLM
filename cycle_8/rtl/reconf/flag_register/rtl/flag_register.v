module flag_register (
    input  wire i_clk,
    input  wire i_rst_n,
    input  wire i_wen,   // デコーダからのフラグ更新有効信号
    input  wire i_z,     // ALUからの現在のZeroフラグ
    input  wire i_n,     // ALUからの現在のNegativeフラグ
    input  wire i_v,     // ALUからの現在のOverflowフラグ
    output wire o_z,     // 保存されているZeroフラグ
    output wire o_n,     // 保存されているNegativeフラグ
    output wire o_v      // 保存されているOverflowフラグ
);

    // 内部接続用ワイヤ (Z=0, N=1, V=2)
    wire [2:0] w_flags_in;
    wire [2:0] w_flags_out;

    // 入力信号をバスにまとめる
    assign w_flags_in[0] = i_z;
    assign w_flags_in[1] = i_n;
    assign w_flags_in[2] = i_v;

    // --- フラグバンク階層 ---
    // 複数のフラグビットを並列に保持する構造
    // 内部でgenerate文を用いて各ビットのDFFを配置
    flag_register_nbit_bank u_bank (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_wen   (i_wen),
        .i_data  (w_flags_in),
        .o_data  (w_flags_out)
    );

    // 保存されたフラグを出力信号へ分配
    // これにより、分岐ロジックは1クロック前の演算結果に基づくフラグを参照できる
    assign o_z = w_flags_out[0];
    assign o_n = w_flags_out[1];
    assign o_v = w_flags_out[2];

endmodule