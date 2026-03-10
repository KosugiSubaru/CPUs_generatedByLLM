module alu_main (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire [3:0]  i_alu_op,
    output wire [15:0] o_result,
    output wire        o_flag_z,
    output wire        o_flag_n,
    output wire        o_flag_v
);

    wire [15:0] w_res_arith;
    wire [15:0] w_res_logic;
    wire [15:0] w_res_shift;
    wire        w_cout_arith;

    wire        w_sel_arith;
    wire        w_sel_logic;
    wire        w_sel_shift;
    wire        w_sub_en;

    // ユニット選択信号のデコードロジックを修正
    // XOR (0100) や NOT (0101) が正しく論理演算ユニットで処理されるように、比較対象を明示
    assign w_sel_arith = (i_alu_op == 4'b0000) | (i_alu_op == 4'b0001) | (i_alu_op == 4'b1000) | 
                         (i_alu_op == 4'b1010) | (i_alu_op == 4'b1011);
    
    assign w_sel_logic = (i_alu_op == 4'b0010) | (i_alu_op == 4'b0011) | 
                         (i_alu_op == 4'b0100) | (i_alu_op == 4'b0101);
    
    assign w_sel_shift = (i_alu_op == 4'b0110) | (i_alu_op == 4'b0111);
    
    assign w_sub_en    = (i_alu_op == 4'b0001);

    // 16ビット算術演算器のインスタンス化
    alu_main_arithmetic_16bit u_arith (
        .i_a      (i_a),
        .i_b      (i_b),
        .i_sub_en (w_sub_en),
        .o_sum    (w_res_arith),
        .o_cout   (w_cout_arith)
    );

    // 16ビット論理演算器のインスタンス化
    alu_main_logical_16bit u_logic (
        .i_sel (i_alu_op[1:0]),
        .i_a   (i_a),
        .i_b   (i_b),
        .o_q   (w_res_logic)
    );

    // 16ビットシフタのインスタンス化
    alu_main_shifter_16bit u_shift (
        .i_a     (i_a),
        .i_shamt (i_b[3:0]),
        .i_mode  (i_alu_op[0]), // 0: SRA, 1: SLA
        .o_q     (w_res_shift)
    );

    // 結果選択MUXのパタン構造化
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_output_mux
            assign o_result[i] = (w_sel_arith) ? w_res_arith[i] :
                                 (w_sel_logic) ? w_res_logic[i] :
                                 (w_sel_shift) ? w_res_shift[i] : 1'b0;
        end
    endgenerate

    // フラグ生成
    assign o_flag_n = o_result[15];
    assign o_flag_z = (o_result == 16'h0000);

    // オーバーフローフラグ (V) の論理実装
    wire w_v_add;
    wire w_v_sub;
    assign w_v_add = (i_a[15] == i_b[15]) & (w_res_arith[15] != i_a[15]);
    assign w_v_sub = (i_a[15] != i_b[15]) & (w_res_arith[15] != i_a[15]);
    assign o_flag_v = (i_alu_op == 4'b0001) ? w_v_sub : (w_sel_arith ? w_v_add : 1'b0);

endmodule