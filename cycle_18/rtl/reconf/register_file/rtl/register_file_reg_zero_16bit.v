module register_file_reg_zero_16bit (
    input wire         i_clk,   
    input wire         i_rst_n, 
    input wire         i_we,    
    input wire [15:0]  i_d,     
    output wire [15:0] o_q
);

    // R0は常に0を返し、書き込みを無視するため、出力を定数0に固定
    assign o_q = 16'h0000;

endmodule