module flag_reg (
    input  wire i_clk,
    input  wire i_rst_n,
    input  wire i_flag_z,
    input  wire i_flag_n,
    input  wire i_flag_v,
    output wire o_flag_z,
    output wire o_flag_n,
    output wire o_flag_v
);

    wire [2:0] w_in;
    wire [2:0] w_out;

    assign w_in = {i_flag_z, i_flag_n, i_flag_v};

    genvar i;
    generate
        for (i = 0; i < 3; i = i + 1) begin : gen_flags
            flag_reg_bit u_flag_bit (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_d     (w_in[i]),
                .o_q     (w_out[i])
            );
        end
    endgenerate

    assign o_flag_z = w_out[2];
    assign o_flag_n = w_out[1];
    assign o_flag_v = w_out[0];

endmodule