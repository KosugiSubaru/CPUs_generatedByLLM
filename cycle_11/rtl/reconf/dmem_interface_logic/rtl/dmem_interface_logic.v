module dmem_interface_logic (
    input  wire [15:0] i_rs1_data,
    input  wire [15:0] i_rs2_data,
    input  wire [15:0] i_imm_data,
    input  wire        i_mem_write_en,
    output wire [15:0] o_addr_to_dmem,
    output wire [15:0] o_data_to_dmem,
    output wire        o_dmem_wen
);

    dmem_interface_logic_adder_16bit u_addr_adder (
        .i_a   (i_rs1_data),
        .i_b   (i_imm_data),
        .o_sum (o_addr_to_dmem)
    );

    assign o_data_to_dmem = i_rs2_data;
    assign o_dmem_wen     = i_mem_write_en;

endmodule