module alu_shift_unit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,        // シフト量は下位4ビットを使用
    output wire [15:0] o_res_sra,  // 算術右シフト
    output wire [15:0] o_res_sla   // 算術左シフト
);

    // バレルシフタの各ステージ用の中間信号 (16bit * 5ステージ)
    wire [15:0] w_sra_st [0:4];
    wire [15:0] w_sla_st [0:4];

    assign w_sra_st[0] = i_a;
    assign w_sla_st[0] = i_a;

    // generate文を用いて、1, 2, 4, 8ビットのシフトステージを階層的に構築
    // 各ステージでi_bの対応するビットに基づき、シフトするかしないかを選択する
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_shift_stages
            // ステップ量: 8, 4, 2, 1
            localparam integer SH_VAL = 1 << (3-i);
            
            // 各ステージのシフト済み候補データ
            wire [15:0] w_sra_shifted;
            wire [15:0] w_sla_shifted;

            // 算術右シフト: 符号ビット(bit 15)を維持して埋める
            if (SH_VAL == 8) begin
                assign w_sra_shifted = {{8{w_sra_st[i][15]}}, w_sra_st[i][15:8]};
                assign w_sla_shifted = {w_sla_st[i][7:0], 8'h00};
            end else if (SH_VAL == 4) begin
                assign w_sra_shifted = {{4{w_sra_st[i][15]}}, w_sra_st[i][15:4]};
                assign w_sla_shifted = {w_sla_st[i][11:0], 4'h0};
            end else if (SH_VAL == 2) begin
                assign w_sra_shifted = {{2{w_sra_st[i][15]}}, w_sra_st[i][15:2]};
                assign w_sla_shifted = {w_sla_st[i][13:0], 2'b00};
            end else begin // SH_VAL == 1
                assign w_sra_shifted = {w_sra_st[i][15], w_sra_st[i][15:1]};
                assign w_sla_shifted = {w_sla_st[i][14:0], 1'b0};
            end

            // セレクタによるステージ推移
            alu_mux_2to1_16bit u_mux_sra (
                .i_sel  (i_b[3-i]),
                .i_d0   (w_sra_st[i]),
                .i_d1   (w_sra_shifted),
                .o_data (w_sra_st[i+1])
            );

            alu_mux_2to1_16bit u_mux_sla (
                .i_sel  (i_b[3-i]),
                .i_d0   (w_sla_st[i]),
                .i_d1   (w_sla_shifted),
                .o_data (w_sla_st[i+1])
            );
        end
    endgenerate

    // 最終ステージの結果を出力
    assign o_res_sra = w_sra_st[4];
    assign o_res_sla = w_sla_st[4];

endmodule