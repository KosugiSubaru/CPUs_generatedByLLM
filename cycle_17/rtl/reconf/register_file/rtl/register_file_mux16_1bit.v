module register_file_mux16_1bit (
    input  wire [15:0] i_data,
    input  wire [3:0]  i_sel,
    output wire        o_y
);

    // 16入力1出力の1ビットセレクタ
    assign o_y = i_data[i_sel];

endmodule