module flag_reg (
    input  wire i_clk,
    input  wire i_rst_n,
    input  wire i_wen,
    input  wire i_alu_z,
    input  wire i_alu_n,
    input  wire i_alu_v,
    output wire o_flag_z,
    output wire o_flag_n,
    output wire o_flag_v
);

    wire [2:0] w_din;
    wire [2:0] w_dout;

    assign w_din = {i_alu_z, i_alu_n, i_alu_v};
    assign o_flag_z = w_dout[2];
    assign o_flag_n = w_dout[1];
    assign o_flag_v = w_dout[0];

    genvar i;
    generate
        for (i = 0; i < 3; i = i + 1) begin : gen_flags
            flag_reg_dff u_dff (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_en    (i_wen),
                .i_d     (w_din[i]),
                .o_q     (w_dout[i])
            );
        end
    endgenerate

endmodule