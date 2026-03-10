module pc_control_adder_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire        i_cin,
    output wire [15:0] o_sum,
    output wire        o_cout
);

    wire [16:0] w_carry;
    genvar i;

    assign w_carry[0] = i_cin;

    // 1ビット加算器を16個接続して Ripple Carry Adder を構成
    // アドレス計算（PC+2, PC+imm, rs1+imm）に使用される
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_adder_array
            pc_control_adder_1bit u_bit_adder (
                .i_a    (i_a[i]),
                .i_b    (i_b[i]),
                .i_cin  (w_carry[i]),
                .o_sum  (o_sum[i]),
                .o_cout (w_carry[i+1])
            );
        end
    endgenerate

    assign o_cout = w_carry[16];

endmodule