module register_file_cell (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire        i_we,
    input  wire [15:0] i_data,
    output reg  [15:0] o_data
);

    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_data <= 16'h0000;
        end else if (i_we) begin
            o_data <= i_data;
        end
    end

endmodule