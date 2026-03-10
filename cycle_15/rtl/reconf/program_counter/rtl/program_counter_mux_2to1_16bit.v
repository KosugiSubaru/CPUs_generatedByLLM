module program_counter_mux_2to1_16bit (
    input  wire        i_sel,
    input  wire [15:0] i_d0,
    input  wire [15:0] i_d1,
    output wire [15:0] o_data
);

    // セレクト信号に基づき、d0またはd1を16ビット幅で選択
    assign o_data = (i_sel == 1'b1) ? i_d1 : i_d0;

endmodule