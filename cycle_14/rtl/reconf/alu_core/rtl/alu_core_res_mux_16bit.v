module alu_core_res_mux_16bit (
    input  wire [3:0]  i_sel,       // Opcode (4bit)
    input  wire [15:0] i_res_arith, // 算術演算結果 (add, sub, addi, load, store, jalr)
    input  wire [15:0] i_res_logic, // 論理演算結果 (and, or, xor, not)
    input  wire [15:0] i_res_shift, // シフト演算結果 (sra, sla)
    input  wire [15:0] i_res_imm,   // 即値パススルー (loadi)
    output wire [15:0] o_res        // 最終選択結果
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_bit_slices
            // 各演算器のi番目のビットをまとめ、16入力1出力セレクタの入力とする
            wire [15:0] w_mux_in;

            // Opcodeと演算器の対応マッピング
            assign w_mux_in[0]  = i_res_arith[i]; // add
            assign w_mux_in[1]  = i_res_arith[i]; // sub
            assign w_mux_in[2]  = i_res_logic[i]; // and
            assign w_mux_in[3]  = i_res_logic[i]; // or
            assign w_mux_in[4]  = i_res_logic[i]; // xor
            assign w_mux_in[5]  = i_res_logic[i]; // not
            assign w_mux_in[6]  = i_res_shift[i]; // sra
            assign w_mux_in[7]  = i_res_shift[i]; // sla
            assign w_mux_in[8]  = i_res_arith[i]; // addi
            assign w_mux_in[9]  = i_res_imm[i];   // loadi
            assign w_mux_in[10] = i_res_arith[i]; // load (addr)
            assign w_mux_in[11] = i_res_arith[i]; // store (addr)
            assign w_mux_in[12] = 1'b0;           // blt (rd未使用)
            assign w_mux_in[13] = 1'b0;           // bz (rd未使用)
            assign w_mux_in[14] = 1'b0;           // jal (rdはPC+2を使用)
            assign w_mux_in[15] = i_res_arith[i]; // jalr (target addr)

            // ビットスライスごとに最小単位のセレクタを配置（パタン構造化）
            alu_core_mux16_1bit u_mux_bit (
                .i_sel (i_sel),
                .i_in  (w_mux_in),
                .o_out (o_res[i])
            );
        end
    endgenerate

endmodule