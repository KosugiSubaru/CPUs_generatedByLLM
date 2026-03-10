module program_counter (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [1:0]  i_pc_source,
    input  wire [15:0] i_imm,
    input  wire [15:0] i_rs1_data,
    output wire [15:0] o_pc,
    output wire [15:0] o_pc_plus_2
);

    wire [15:0] w_next_pc;
    wire [15:0] w_add_in_a [0:2];
    wire [15:0] w_add_in_b [0:2];
    wire [15:0] w_add_out  [0:2];

    program_counter_reg_16bit u_reg_pc (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_d     (w_next_pc),
        .o_q     (o_pc)
    );

    assign w_add_in_a[0] = o_pc;
    assign w_add_in_b[0] = 16'h0002;
    assign w_add_in_a[1] = o_pc;
    assign w_add_in_b[1] = i_imm;
    assign w_add_in_a[2] = i_rs1_data;
    assign w_add_in_b[2] = i_imm;

    genvar k;
    generate
        for (k = 0; k < 3; k = k + 1) begin : gen_pc_adders
            program_counter_adder_16bit u_pc_calc_adder (
                .i_a   (w_add_in_a[k]),
                .i_b   (w_add_in_b[k]),
                .o_sum (w_add_out[k])
            );
        end
    endgenerate

    assign o_pc_plus_2 = w_add_out[0];

    program_counter_mux_4to1_16bit u_mux_next_pc (
        .i_sel (i_pc_source),
        .i_d0  (w_add_out[0]),
        .i_d1  (w_add_out[1]),
        .i_d2  (w_add_out[2]),
        .i_d3  (16'h0000),
        .o_y   (w_next_pc)
    );

endmodule