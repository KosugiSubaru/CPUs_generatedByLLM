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

    wire [255:0] w_regs_flatten;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_reg_slots
            if (i == 0) begin : slot_zero
                assign w_regs_flatten[15:0] = 16'h0000;
            end else begin : slot_normal
                register_file_slot u_slot (
                    .i_clk   (i_clk),
                    .i_rst_n (i_rst_n),
                    .i_we    ((i_rd_addr == i[3:0]) & i_wen),
                    .i_data  (i_rd_data),
                    .o_data  (w_regs_flatten[i*16 +: 16])
                );
            end
        end
    endgenerate

    register_file_read_selector u_rs1_sel (
        .i_sel  (i_rs1_addr),
        .i_data (w_regs_flatten),
        .o_data (o_rs1_data)
    );

    register_file_read_selector u_rs2_sel (
        .i_sel  (i_rs2_addr),
        .i_data (w_regs_flatten),
        .o_data (o_rs2_data)
    );

endmodule