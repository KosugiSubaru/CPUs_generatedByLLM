module register_file_mux_16to1_16bit (
    input  wire [255:0] i_data,
    input  wire [3:0]   i_sel,
    output wire [15:0]  o_q
);

    genvar bit_idx, reg_idx;
    generate
        for (bit_idx = 0; bit_idx < 16; bit_idx = bit_idx + 1) begin : gen_bit_slice_mux
            wire [15:0] w_mux_in;

            // 各レジスタの同じビット目（bit_idx）を集めて、1ビット16入力MUXへの入力とする
            for (reg_idx = 0; reg_idx < 16; reg_idx = reg_idx + 1) begin : gen_mux_input
                assign w_mux_in[reg_idx] = i_data[reg_idx * 16 + bit_idx];
            end

            // 1ビット幅の16入力マルチプレクサを16個並列に配置し、16ビット幅を選択する
            register_file_mux_16to1_1bit u_mux_bit (
                .i_d   (w_mux_in),
                .i_sel (i_sel),
                .o_q   (o_q[bit_idx])
            );
        end
    endgenerate

endmodule