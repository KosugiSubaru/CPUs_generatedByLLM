module flag_reg_bit (
    input  wire i_clk,
    input  wire i_rst_n,
    input  wire i_en,
    input  wire i_flag_in,
    output wire o_flag_out
);

    reg r_data;

    assign o_flag_out = r_data;

    always @(posedge i_clk) begin
        if (!i_rst_n) begin
            r_data <= 1'b0;
        end else if (i_en) begin
            r_data <= i_flag_in;
        end
    end

endmodule