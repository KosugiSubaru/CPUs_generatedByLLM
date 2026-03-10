module flag_reg (
        input  wire i_clk,
        input  wire i_rst_n,
        input  wire i_flag_z_alu,
        input  wire i_flag_n_alu,
        input  wire i_flag_v_alu,
        output wire o_flag_z,
        output wire o_flag_n,
        output wire o_flag_v
    );

        wire [2:0] w_alu_flags;
        wire [2:0] w_stored_flags;
        genvar i;

        assign w_alu_flags = {i_flag_v_alu, i_flag_n_alu, i_flag_z_alu};

        generate
            for (i = 0; i < 3; i = i + 1) begin : gen_flag_bits
                flag_reg_bit u_flag_reg_bit (
                    .i_clk   (i_clk),
                    .i_rst_n (i_rst_n),
                    .i_d     (w_alu_flags[i]),
                    .o_q     (w_stored_flags[i])
                );
            end
        endgenerate

        assign o_flag_z = w_stored_flags[0];
        assign o_flag_n = w_stored_flags[1];
        assign o_flag_v = w_stored_flags[2];

    endmodule