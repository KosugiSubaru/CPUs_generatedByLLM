module register_file (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [3:0]  i_rs1_addr,
    input  wire [3:0]  i_rs2_addr,
    input  wire [3:0]  i_rd_addr,
    input  wire [15:0] i_rd_data,
    input  wire        i_we,
    output wire [15:0] o_rs1_data,
    output wire [15:0] o_rs2_data
);

    wire [15:0]  w_we_bus;
    wire [255:0] w_reg_bus;

    register_file_decoder u_register_file_decoder (
        .i_addr   (i_rd_addr),
        .i_we     (i_we),
        .o_we_bus (w_we_bus)
    );

    register_file_array u_register_file_array (
        .i_clk     (i_clk),
        .i_rst_n   (i_rst_n),
        .i_we_bus  (w_we_bus),
        .i_data_in (i_rd_data),
        .o_reg_bus (w_reg_bus)
    );

    register_file_mux16 u_register_file_mux16_rs1 (
        .i_reg_bus (w_reg_bus),
        .i_sel     (i_rs1_addr),
        .o_data    (o_rs1_data)
    );

    register_file_mux16 u_register_file_mux16_rs2 (
        .i_reg_bus (w_reg_bus),
        .i_sel     (i_rs2_addr),
        .o_data    (o_rs2_data)
    );

endmodule