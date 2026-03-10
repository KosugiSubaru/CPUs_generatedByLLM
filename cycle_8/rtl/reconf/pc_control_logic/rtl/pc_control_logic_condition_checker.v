module pc_control_logic_condition_checker (
    input  wire [3:0] i_target_opcode, // このチェッカーが担当するオペコード
    input  wire [3:0] i_opcode,        // デコーダからの現在のオペコード
    input  wire       i_flag_z,        // Zeroフラグ
    input  wire       i_flag_n,        // Negativeフラグ
    input  wire       i_flag_v,        // Overflowフラグ
    output wire       o_cond_met       // 分岐条件成立信号
);

    wire w_is_active;
    wire w_cond_logic;

    // 現在実行中の命令が、この判定ユニットの担当であるかを確認
    assign w_is_active = (i_opcode == i_target_opcode);

    // ISA定義に基づく条件判定の論理合成
    // 論理合成後の回路図において、フラグ配線から条件判定ゲート(XOR等)へ至る
    // データパスを視覚化するために明示的に分離して記述
    
    // 1100 (branch less than) : N ^ V
    // 1101 (branch zero)      : Z
    assign w_cond_logic = (i_target_opcode == 4'b1100) ? (i_flag_n ^ i_flag_v) :
                          (i_target_opcode == 4'b1101) ? (i_flag_z)            :
                          1'b0;

    // 命令が有効であり、かつ条件式が真である場合にのみ分岐成立を出力
    assign o_cond_met = w_is_active & w_cond_logic;

endmodule