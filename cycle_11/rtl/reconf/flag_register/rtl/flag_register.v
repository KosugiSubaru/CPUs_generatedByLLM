module flag_register (
    input  wire i_clk,
    input  wire i_rst_n,
    input  wire i_wen,
    input  wire i_flag_z,
    input  wire i_flag_n,
    input  wire i_flag_v,
    output wire o_flag_z,
    output wire o_flag_n,
    output wire o_flag_v
);

    wire [2:0] w_in_flags;
    wire [2:0] w_out_flags;

    assign w_in_flags[0] = i_flag_z;
    assign w_in_flags[1] = i_flag_n;
    assign w_in_flags[2] = i_flag_v;

    genvar i;
    generate
        for (i = 0; i < 3; i = i + 1) begin : gen_flag_storage
            flag_register_bit u_flag_bit (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_we    (i_wen),
                .i_d     (w_in_flags[i]),
                .o_q     (w_out_flags[i])
            );
        end
    endgenerate

    assign o_flag_z = w_out_flags[0];
    assign o_flag_n = w_out_flags[1];
    assign o_flag_v = w_out_flags[2];

endmodule