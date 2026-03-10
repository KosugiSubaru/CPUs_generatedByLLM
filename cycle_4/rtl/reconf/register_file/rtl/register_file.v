module register_file (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [3:0]  i_rs1_addr,
    input  wire [3:0]  i_rs2_addr,
    input  wire [3:0]  i_rd_addr,
    input  wire [15:0] i_rd_data,
    input  wire        i_wen,
    output wire [15:0] o_rs1_data,
    output wire [15:0] o_rs2_data
);

    wire [255:0] w_reg_bus;

    // Zero Register (R0) is always 0
    assign w_reg_bus[15:0] = 16'h0000;

    // Instantiate Registers R1 to R15
    genvar i;
    generate
        for (i = 1; i < 16; i = i + 1) begin : gen_registers
            register_file_cell u_cell (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_wen   (i_wen && (i_rd_addr == i[3:0])),
                .i_d     (i_rd_data),
                .o_q     (w_reg_bus[16*i +: 16])
            );
        end
    endgenerate

    // Read Port 1
    register_file_reader u_reader_rs1 (
        .i_data_bus (w_reg_bus),
        .i_addr     (i_rs1_addr),
        .o_data     (o_rs1_data)
    );

    // Read Port 2
    register_file_reader u_reader_rs2 (
        .i_data_bus (w_reg_bus),
        .i_addr     (i_rs2_addr),
        .o_data     (o_rs2_data)
    );

endmodule