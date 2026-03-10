module reg_write_data_selector (
    input  wire [1:0]  i_wb_sel,
    input  wire [15:0] i_alu_res,
    input  wire [15:0] i_mem_data,
    input  wire [15:0] i_pc_plus_2,
    input  wire [15:0] i_imm_data,
    output wire [15:0] o_wb_data
);

    reg_write_data_selector_mux_4to1_16bit u_mux_wb (
        .i_sel (i_wb_sel),
        .i_d0  (i_alu_res),
        .i_d1  (i_mem_data),
        .i_d2  (i_pc_plus_2),
        .i_d3  (i_imm_data),
        .o_y   (o_wb_data)
    );

endmodule