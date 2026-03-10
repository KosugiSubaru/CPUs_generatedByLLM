module pc_control_adder_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    output wire [15:0] o_sum
);

    // アドレス計算（PC+2, PC+imm, rs1+imm）を行う16ビット加算器
    assign o_sum = i_a + i_b;

endmodule