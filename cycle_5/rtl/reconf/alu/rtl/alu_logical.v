module alu_logical (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire [2:0]  i_mode, // alu_modeの低位ビットを使用
    output wire [15:0] o_res
);

    wire [15:0] w_and;
    wire [15:0] w_or;
    wire [15:0] w_xor;
    wire [15:0] w_not;

    // ビットごとの論理演算
    assign w_and = i_a & i_b;
    assign w_or  = i_a | i_b;
    assign w_xor = i_a ^ i_b;
    assign w_not = ~i_a;

    // 演算モードに基づいた結果選択
    // 010: AND, 011: OR, 100: XOR, 101: NOT
    assign o_res = (i_mode == 3'b010) ? w_and :
                   (i_mode == 3'b011) ? w_or  :
                   (i_mode == 3'b100) ? w_xor :
                   (i_mode == 3'b101) ? w_not :
                                        16'h0000;

endmodule