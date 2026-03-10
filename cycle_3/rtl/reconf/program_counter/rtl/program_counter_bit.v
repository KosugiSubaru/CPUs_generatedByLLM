module program_counter_bit (
    input  wire i_clk,
    input  wire i_rst_n,
    input  wire i_d,
    output wire o_q
);

    reg r_q;

    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            r_q <= 1'b0;
        end else begin
            r_q <= i_d;
        end
    end

    assign o_q = r_q;

endmodule