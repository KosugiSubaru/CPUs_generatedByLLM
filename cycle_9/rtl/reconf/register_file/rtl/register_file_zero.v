module register_file_zero (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire        i_we,
    input  wire [15:0] i_data,
    output wire [15:0] o_data
);

    // ゼロレジスタ：書き込みを無視し、常に0を出力する
    assign o_data = 16'h0000;

endmodule