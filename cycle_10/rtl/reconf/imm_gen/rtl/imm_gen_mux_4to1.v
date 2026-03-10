module imm_gen_mux_4to1 (
    input  wire [15:0] i_data_i,
    input  wire [15:0] i_data_s,
    input  wire [15:0] i_data_l,
    input  wire [15:0] i_data_b,
    input  wire [1:0]  i_sel,
    output wire [15:0] o_imm
);

    // 選択信号に基づき、I/S/L/B形式のいずれかの即値を選択する
    assign o_imm = (i_sel == 2'b00) ? i_data_i :
                   (i_sel == 2'b01) ? i_data_s :
                   (i_sel == 2'b10) ? i_data_l :
                                      i_data_b;

endmodule