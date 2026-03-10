module alu_mux_result (
    input  wire [3:0]  i_alu_op,
    input  wire [15:0] i_res_adder,
    input  wire [15:0] i_res_logic,
    input  wire [15:0] i_res_shifter,
    input  wire [15:0] i_imm_val,
    output wire [15:0] o_result
);

    // ALUOpに基づいて、各演算ブロックの出力から最終的な結果を選択
    // ISAのオペコード定義に直接対応させることで、回路図での理解を助ける
    assign o_result = 
        // 算術演算・メモリアドレス計算 (add, sub, addi, load, store)
        (i_alu_op == 4'b0000 || i_alu_op == 4'b0001 || 
         i_alu_op == 4'b1000 || i_alu_op == 4'b1010 || i_alu_op == 4'b1011) ? i_res_adder :
        
        // 論理演算 (and, or, xor, not)
        (i_alu_op == 4'b0010 || i_alu_op == 4'b0011 || 
         i_alu_op == 4'b0100 || i_alu_op == 4'b0101) ? i_res_logic :
        
        // シフト演算 (sra, sla)
        (i_alu_op == 4'b0110 || i_alu_op == 4'b0111) ? i_res_shifter :
        
        // 即値ロード (loadi)
        (i_alu_op == 4'b1001) ? i_imm_val : 
        
        // デフォルト値
        16'h0000;

endmodule