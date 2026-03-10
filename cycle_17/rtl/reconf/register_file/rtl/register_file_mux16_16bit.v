module register_file_mux16_16bit (
    input  wire [15:0] i_r0,
    input  wire [15:0] i_r1,
    input  wire [15:0] i_r2,
    input  wire [15:0] i_r3,
    input  wire [15:0] i_r4,
    input  wire [15:0] i_r5,
    input  wire [15:0] i_r6,
    input  wire [15:0] i_r7,
    input  wire [15:0] i_r8,
    input  wire [15:0] i_r9,
    input  wire [15:0] i_r10,
    input  wire [15:0] i_r11,
    input  wire [15:0] i_r12,
    input  wire [15:0] i_r13,
    input  wire [15:0] i_r14,
    input  wire [15:0] i_r15,
    input  wire [3:0]  i_sel,
    output wire [15:0] o_data
);

    genvar i;

    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_mux_array
            // 各ビットごとに、16個のレジスタの同じビット位置を集めて1ビット選択を行う
            register_file_mux16_1bit u_mux1b (
                .i_data ({
                    i_r15[i], i_r14[i], i_r13[i], i_r12[i],
                    i_r11[i], i_r10[i], i_r9[i],  i_r8[i],
                    i_r7[i],  i_r6[i],  i_r5[i],  i_r4[i],
                    i_r3[i],  i_r2[i],  i_r1[i],  i_r0[i]
                }),
                .i_sel  (i_sel),
                .o_y    (o_data[i])
            );
        end
    endgenerate

endmodule