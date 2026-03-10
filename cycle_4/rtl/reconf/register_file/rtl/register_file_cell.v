module register_file_cell (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire        i_wen,
    input  wire [15:0] i_d,
    output reg  [15:0] o_q
);

    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_q <= 16'h0000;
        end else if (i_wen) begin
            o_q <= i_d;
        end
    end

endmodule