module register_file_mux_16to1_1bit (
    input  wire [3:0]  i_sel,
    input  wire [15:0] i_in,
    output wire        o_out
);

    wire [3:0] w_stage1_out;
    genvar i;

    // 4対1セレクタを4つ並べて16入力を4つの出力に絞り込む（Stage 1）
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_mux_stage1
            register_file_mux_4to1_1bit u_mux_stage1 (
                .i_sel (i_sel[1:0]),
                .i_in0 (i_in[i*4 + 0]),
                .i_in1 (i_in[i*4 + 1]),
                .i_in2 (i_in[i*4 + 2]),
                .i_in3 (i_in[i*4 + 3]),
                .o_out (w_stage1_out[i])
            );
        end
    endgenerate

    // Stage 1の出力をさらに4対1セレクタで絞り込んで最終的な1ビットを得る（Stage 2）
    register_file_mux_4to1_1bit u_mux_stage2 (
        .i_sel (i_sel[3:2]),
        .i_in0 (w_stage1_out[0]),
        .i_in1 (w_stage1_out[1]),
        .i_in2 (w_stage1_out[2]),
        .i_in3 (w_stage1_out[3]),
        .o_out (o_out)
    );

endmodule