module pc_reg (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [1:0]  i_pc_sel,      // 00:PC+2, 01:PC+Imm(Branch/JAL), 10:RS1+Imm(JALR)
    input  wire [15:0] i_imm,         // 符号拡張済み即値
    input  wire [15:0] i_rs1_data,    // JALR用ベースアドレス
    output wire [15:0] o_pc_addr,     // 命令メモリ(imem)用アドレス
    output wire [15:0] o_pc_plus_2    // レジスタ書き戻し用(JAL/JALRリターンアドレス)
);

    // 内部接続用ワイヤ
    wire [15:0] w_pc_now;
    wire [15:0] w_next_pc;

    // パタン構造化のための加算器用配列
    // [0]: PC + 2
    // [1]: PC + Imm
    // [2]: RS1 + Imm
    wire [15:0] w_adder_in_a [2:0];
    wire [15:0] w_adder_in_b [2:0];
    wire [15:0] w_adder_out  [2:0];

    // 加算器入力の割り当て
    assign w_adder_in_a[0] = w_pc_now;     assign w_adder_in_b[0] = 16'h0002;
    assign w_adder_in_a[1] = w_pc_now;     assign w_adder_in_b[1] = i_imm;
    assign w_adder_in_a[2] = i_rs1_data;   assign w_adder_in_b[2] = i_imm;

    // --- 1. PCレジスタ本体（記憶素子階層） ---
    pc_reg_nbit_dff u_pc_dff (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_d     (w_next_pc),
        .o_q     (w_pc_now)
    );

    // --- 2. 次PC計算ユニット（演算階層） ---
    // generate文を用いて複数の加算器パスを並列に構造化
    genvar i;
    generate
        for (i = 0; i < 3; i = i + 1) begin : gen_pc_adders
            pc_reg_nbit_adder u_adder (
                .i_a    (w_adder_in_a[i]),
                .i_b    (w_adder_in_b[i]),
                .i_cin  (1'b0),
                .o_sum  (w_adder_out[i]),
                .o_cout ()
            );
        end
    endgenerate

    // --- 3. 次PC選択ユニット（選択階層） ---
    // 制御信号に基づき、次のクロックでPCに格納する値を選択
    pc_reg_nbit_mux_4to1 u_mux_next_pc (
        .i_sel (i_pc_sel),
        .i_d0  (w_adder_out[0]), // PC+2
        .i_d1  (w_adder_out[1]), // PC+Imm (Branch / JAL)
        .i_d2  (w_adder_out[2]), // RS1+Imm (JALR)
        .i_d3  (w_adder_out[0]), // (予備)
        .o_q   (w_next_pc)
    );

    // 外部出力
    assign o_pc_addr   = w_pc_now;
    assign o_pc_plus_2 = w_adder_out[0];

endmodule