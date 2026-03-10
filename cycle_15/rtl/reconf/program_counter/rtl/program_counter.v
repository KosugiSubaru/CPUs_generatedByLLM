module program_counter (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [1:0]  i_pc_sel,      // 00:PC+2, 01:PC+imm, 10:rs1+imm, 11:current
    input  wire [15:0] i_imm,         // 符号拡張済み即値
    input  wire [15:0] i_rs1_data,    // jalr用のレジスタ入力
    output wire [15:0] o_pc,          // 命令メモリへの現在のアドレス
    output wire [15:0] o_pc_plus_2    // リンクレジスタ(rd)への書き戻し用
);

    wire [15:0] w_pc_current;
    wire [15:0] w_pc_next;
    wire [15:0] w_calc_results [2:0];

    // 次のPC値を保持する16ビットレジスタ
    program_counter_reg_16bit u_reg (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_data  (w_pc_next),
        .o_data  (w_pc_current)
    );

    // PC計算用の加算器群
    // インデックス0: 通常進捗 (PC + 2)
    // インデックス1: 相対分岐/ジャンプ (PC + imm)
    // インデックス2: レジスタ間接ジャンプ (rs1 + imm)
    genvar i;
    generate
        for (i = 0; i < 3; i = i + 1) begin : gen_pc_adders
            wire [15:0] w_adder_a;
            wire [15:0] w_adder_b;

            if (i == 0) begin
                assign w_adder_a = w_pc_current;
                assign w_adder_b = 16'h0002;
            end else if (i == 1) begin
                assign w_adder_a = w_pc_current;
                assign w_adder_b = i_imm;
            end else begin
                assign w_adder_a = i_rs1_data;
                assign w_adder_b = i_imm;
            end

            program_counter_adder_16bit u_adder_16bit (
                .i_a   (w_adder_a),
                .i_b   (w_adder_b),
                .o_sum (w_calc_results[i])
            );
        end
    endgenerate

    // 制御信号i_pc_selに基づいて次のPC値を選択
    program_counter_mux_4to1_16bit u_mux_4to1 (
        .i_sel  (i_pc_sel),
        .i_d0   (w_calc_results[0]), // PC + 2
        .i_d1   (w_calc_results[1]), // PC + imm
        .i_d2   (w_calc_results[2]), // rs1 + imm
        .i_d3   (w_pc_current),      // 停止/現状維持
        .o_data (w_pc_next)
    );

    // 出力信号の接続
    assign o_pc        = w_pc_current;
    assign o_pc_plus_2 = w_calc_results[0];

endmodule