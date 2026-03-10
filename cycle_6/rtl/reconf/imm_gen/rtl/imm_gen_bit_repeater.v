module imm_gen_bit_repeater #(
    parameter REPEATS = 1
)(
    input  wire               i_bit,
    output wire [REPEATS-1:0] o_bus
);

    genvar i;
    generate
        for (i = 0; i < REPEATS; i = i + 1) begin : gen_replication
            // 入力された1ビットをバスの全ビットに接続し、符号拡張用のビット群を生成
            assign o_bus[i] = i_bit;
        end
    endgenerate

endmodule