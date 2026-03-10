module register_file_mux_4to1 (
    input  wire [15:0] i_data0,
    input  wire [15:0] i_data1,
    input  wire [15:0] i_data2,
    input  wire [15:0] i_data3,
    input  wire [1:0]  i_sel,
    output wire [15:0] o_data
);

    // 2ビットの選択信号に基づき、4つの16ビット入力から1つを選択する
    assign o_data = (i_sel == 2'b00) ? i_data0 :
                    (i_sel == 2'b01) ? i_data1 :
                    (i_sel == 2'b10) ? i_data2 :
                                       i_data3;

endmodule