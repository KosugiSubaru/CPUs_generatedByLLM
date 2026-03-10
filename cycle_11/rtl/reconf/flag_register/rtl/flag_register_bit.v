module flag_register_bit (
    input  wire i_clk,
    input  wire i_rst_n,
    input  wire i_we,
    input  wire i_d,
    output reg  o_q
);

    wire w_next_val;

    flag_register_mux_2to1_1bit u_mux (
        .i_sel (i_we),
        .i_d0  (o_q),
        .i_d1  (i_d),
        .o_y   (w_next_val)
    );

    always @(posedge i_clk) begin
        if (i_rst_n == 1'b0) begin
            o_q <= 1'b0;
        end else begin
            o_q <= w_next_val;
        end
    end

endmodule