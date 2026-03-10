module program_counter_mux4_16bit (
    input  wire [1:0]  i_sel,
    input  wire [15:0] i_d0,
    input  wire [15:0] i_d1,
    input  wire [15:0] i_d2,
    input  wire [15:0] i_d3,
    output wire [15:0] o_y
);

    wire [15:0] w_mux_low;
    wire [15:0] w_mux_high;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : mux_bit
            // Level 1: d0 or d1 based on sel[0]
            program_counter_mux2 u_mux_low (
                .i_sel (i_sel[0]),
                .i_d0  (i_d0[i]),
                .i_d1  (i_d1[i]),
                .o_y   (w_mux_low[i])
            );

            // Level 1: d2 or d3 based on sel[0]
            program_counter_mux2 u_mux_high (
                .i_sel (i_sel[0]),
                .i_d0  (i_d2[i]),
                .i_d1  (i_d3[i]),
                .o_y   (w_mux_high[i])
            );

            // Level 2: final selection based on sel[1]
            program_counter_mux2 u_mux_final (
                .i_sel (i_sel[1]),
                .i_d0  (w_mux_low[i]),
                .i_d1  (w_mux_high[i]),
                .o_y   (o_y[i])
            );
        end
    endgenerate

endmodule