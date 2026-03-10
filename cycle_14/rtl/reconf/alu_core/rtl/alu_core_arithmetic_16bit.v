module alu_core_arithmetic_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire        i_sub_en, // 0: Add, 1: Sub
    output wire [15:0] o_res,
    output wire        o_v       // Overflowフラグ
);

    wire [16:0] w_carry;
    wire [15:0] w_b_mod;

    // 減算時はBを反転し、キャリー入力(w_carry[0])を1にすることで2の補数演算を実現
    assign w_carry[0] = i_sub_en;
    
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_adder
            // 減算モードならi_bを反転
            assign w_b_mod[i] = i_b[i] ^ i_sub_en;

            alu_core_full_adder u_fa (
                .i_a    (i_a[i]),
                .i_b    (w_b_mod[i]),
                .i_cin  (w_carry[i]),
                .o_sum  (o_res[i]),
                .o_cout (w_carry[i+1])
            );
        end
    endgenerate

    // ISA定義に基づくオーバーフロー判定
    // Addition: (rs1[15]==1 & rs2[15]==1 & rd[15]==0) | (rs1[15]==0 & rs2[15]==0 & rd[15]==1)
    // Subtraction: (rs1[15]==0 & rs2[15]==1 & rd[15]==1) | (rs1[15]==1 & rs2[15]==0 & rd[15]==0)
    wire w_v_add;
    wire w_v_sub;

    assign w_v_add = (i_a[15] == 1'b1 && i_b[15] == 1'b1 && o_res[15] == 1'b0) ||
                     (i_a[15] == 1'b0 && i_b[15] == 1'b0 && o_res[15] == 1'b1);

    assign w_v_sub = (i_a[15] == 1'b0 && i_b[15] == 1'b1 && o_res[15] == 1'b1) ||
                     (i_a[15] == 1'b1 && i_b[15] == 1'b0 && o_res[15] == 1'b0);

    assign o_v = (i_sub_en) ? w_v_sub : w_v_add;

endmodule