module pc_control_logic_branch_array (
    input  wire [3:0] i_opcode,
    input  wire       i_flag_z,
    input  wire       i_flag_n,
    input  wire       i_flag_v,
    output wire       o_taken
);

    wire [1:0] w_cond_results;

    // 分岐条件判定ユニットの並列配置
    // 論理合成後の回路図において、BLT判定とBZ判定が個別のブロックとして視覚化される
    genvar i;
    generate
        for (i = 0; i < 2; i = i + 1) begin : gen_condition_checkers
            // ユニット0: BLT (N ^ V)
            // ユニット1: BZ  (Z)
            wire [3:0] w_target_opcode = (i == 0) ? 4'b1100 : 4'b1101;
            
            pc_control_logic_condition_checker u_checker (
                .i_target_opcode (w_target_opcode),
                .i_opcode        (i_opcode),
                .i_flag_z        (i_flag_z),
                .i_flag_n        (i_flag_n),
                .i_flag_v        (i_flag_v),
                .o_cond_met      (w_cond_results[i])
            );
        end
    endgenerate

    // いずれかの分岐条件が満たされていれば成立とする
    assign o_taken = |w_cond_results;

endmodule