module wb_data_mux (
    input  wire        i_mem_to_reg,
    input  wire        i_reg_src_pc,
    input  wire [15:0] i_alu_res,
    input  wire [15:0] i_mem_data,
    input  wire [15:0] i_pc_plus2,
    output wire [15:0] o_wb_data
);

    wire [1:0] w_sel;

    // 選択信号のデコード（00:ALU, 01:Mem, 10:PC+2）
    assign w_sel = (i_reg_src_pc) ? 2'b10 :
                   (i_mem_to_reg) ? 2'b01 : 2'b00;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_wb_mux
            wb_data_mux_bit u_mux_bit (
                .i_sel (w_sel),
                .i_alu (i_alu_res[i]),
                .i_mem (i_mem_data[i]),
                .i_pc2 (i_pc_plus2[i]),
                .o_q   (o_wb_data[i])
            );
        end
    endgenerate

endmodule