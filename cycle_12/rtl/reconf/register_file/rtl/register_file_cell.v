module register_file_cell (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire        i_wen,
    input  wire [15:0] i_data,
    output wire [15:0] o_data
);

    reg [15:0] r_data;

    assign o_data = r_data;

    always @(posedge i_clk) begin
        if (!i_rst_n) begin
            r_data <= 16'h0000;
        end else if (i_wen) begin
            r_data <= i_data;
        end
    end

endmodule