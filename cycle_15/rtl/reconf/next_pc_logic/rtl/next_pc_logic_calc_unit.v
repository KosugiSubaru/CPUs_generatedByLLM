module next_pc_logic_calc_unit (
    input  wire [15:0] i_pc,
    input  wire [15:0] i_imm,
    input  wire [15:0] i_rs1_data,
    output wire [15:0] o_pc_plus_2,
    output wire [15:0] o_pc_plus_imm,
    output wire [15:0] o_rs1_plus_imm
);

    wire [15:0] w_results [2:0];

    // generate文を用いて3つの独立した加算器を配置
    // これにより論理合成後の回路図で、各アドレス候補が個別の加算器で計算される様子が視覚化される
    genvar i;
    generate
        for (i = 0; i < 3; i = i + 1) begin : gen_pc_adders
            wire [15:0] w_a;
            wire [15:0] w_b;

            if (i == 0) begin : p2
                assign w_a = i_pc;
                assign w_b = 16'h0002; // 通常進捗
            end else if (i == 1) begin : pimm
                assign w_a = i_pc;
                assign w_b = i_imm;    // 相対分岐/ジャンプ
            end else begin : rpimm
                assign w_a = i_rs1_data;
                assign w_b = i_imm;    // レジスタ間接ジャンプ
            end

            next_pc_logic_adder_16bit u_adder_16bit (
                .i_a   (w_a),
                .i_b   (w_b),
                .o_sum (w_results[i])
            );
        end
    endgenerate

    // 計算結果の割り当て
    assign o_pc_plus_2    = w_results[0];
    assign o_pc_plus_imm  = w_results[1];
    assign o_rs1_plus_imm = w_results[2];

endmodule