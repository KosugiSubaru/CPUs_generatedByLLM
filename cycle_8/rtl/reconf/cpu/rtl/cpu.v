module cpu (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [15:0] i_instr,
    input  wire [15:0] i_data_from_dmem,
    output wire [15:0] o_addr_to_dmem,
    output wire [15:0] o_data_to_dmem,
    output wire [15:0] o_addr_to_imem,
    output wire        o_dmem_wen,

    // Debug Ports
    output wire [15:0] o_debug_instr,
    output wire [3:0]  o_debug_rs1_addr,
    output wire [15:0] o_debug_rs1_data,
    output wire [3:0]  o_debug_rs2_addr,
    output wire [15:0] o_debug_rs2_data,
    output wire [3:0]  o_debug_rd_addr,
    output wire [15:0] o_debug_rd_data,
    output wire        o_debug_regfile_wen,
    output wire        o_debug_dmem_wen,
    output wire [15:0] o_debug_adder_to_dmem,
    output wire [15:0] o_debug_data_to_dmem,
    output wire [15:0] o_debug_data_from_dmem,
    output wire [15:0] o_debug_now_pc,
    output wire        o_debug_flag_n,
    output wire        o_debug_flag_v,
    output wire        o_debug_flag_z
);

    // 内部接続ワイヤ
    wire [3:0]  w_rd_addr, w_rs1_addr, w_rs2_addr, w_alu_op;
    wire [11:0] w_imm_bits;
    wire        w_reg_wen, w_alu_src_b_sel;
    wire [1:0]  w_reg_wdata_sel, w_pc_sel;
    wire [15:0] w_rs1_data, w_rs2_data, w_imm_data, w_alu_in_b, w_alu_result, w_reg_wdata, w_pc_plus_2;
    wire        w_alu_z, w_alu_n, w_alu_v, w_stored_z, w_stored_n, w_stored_v;
    wire [1:0]  w_imm_src_sel;
    wire        w_flag_wen;

    // 即値形式選択信号の生成 (Opcodeに基づくマッピング)
    assign w_imm_src_sel = (i_instr[3:0] == 4'b1000 || i_instr[3:0] == 4'b1010 || i_instr[3:0] == 4'b1111) ? 2'b00 :
                           (i_instr[3:0] == 4'b1011) ? 2'b01 :
                           (i_instr[3:0] == 4'b1001 || i_instr[3:0] == 4'b1110) ? 2'b10 : 2'b11;

    // フラグ更新有効信号 (算術・論理演算命令の時のみ更新)
    assign w_flag_wen = ~i_instr[3] | (i_instr[3:0] == 4'b1000);

    // --- 各サブモジュールのインスタンス化 ---

    pc_reg u_pc_reg (
        .i_clk       (i_clk),
        .i_rst_n     (i_rst_n),
        .i_pc_sel    (w_pc_sel),
        .i_imm       (w_imm_data),
        .i_rs1_data  (w_rs1_data),
        .o_pc_addr   (o_addr_to_imem),
        .o_pc_plus_2 (w_pc_plus_2)
    );

    instruction_decoder u_decoder (
        .i_instr         (i_instr),
        .i_flag_z        (w_stored_z),
        .i_flag_n        (w_stored_n),
        .i_flag_v        (w_stored_v),
        .o_rd_addr       (w_rd_addr),
        .o_rs1_addr      (w_rs1_addr),
        .o_rs2_addr      (w_rs2_addr),
        .o_imm_bits      (w_imm_bits),
        .o_reg_wen       (w_reg_wen),
        .o_dmem_wen      (o_dmem_wen),
        .o_alu_op        (w_alu_op),
        .o_alu_src_b_sel (w_alu_src_b_sel),
        .o_reg_wdata_sel (w_reg_wdata_sel),
        .o_pc_sel        () // pc_control_logic側で最終決定するため未使用
    );

    imm_generator u_imm_gen (
        .i_instr       (i_instr),
        .i_imm_src_sel (w_imm_src_sel),
        .o_imm         (w_imm_data)
    );

    register_file u_regfile (
        .i_clk      (i_clk),
        .i_rst_n    (i_rst_n),
        .i_wen      (w_reg_wen),
        .i_rd_addr  (w_rd_addr),
        .i_rs1_addr (w_rs1_addr),
        .i_rs2_addr (w_rs2_addr),
        .i_rd_data  (w_reg_wdata),
        .o_rs1_data (w_rs1_data),
        .o_rs2_data (w_rs2_data)
    );

    alu_core u_alu (
        .i_a      (w_rs1_data),
        .i_b      (w_alu_in_b),
        .i_alu_op (w_alu_op),
        .o_result (w_alu_result),
        .o_flag_z (w_alu_z),
        .o_flag_n (w_alu_n),
        .o_flag_v (w_alu_v)
    );

    flag_register u_flags (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_wen   (w_flag_wen),
        .i_z     (w_alu_z),
        .i_n     (w_alu_n),
        .i_v     (w_alu_v),
        .o_z     (w_stored_z),
        .o_n     (w_stored_n),
        .o_v     (w_stored_v)
    );

    pc_control_logic u_pc_ctrl (
        .i_opcode (i_instr[3:0]),
        .i_flag_z (w_stored_z),
        .i_flag_n (w_stored_n),
        .i_flag_v (w_stored_v),
        .o_pc_sel (w_pc_sel)
    );

    data_path_mux u_datapath (
        .i_alu_src_b_sel (w_alu_src_b_sel),
        .i_reg_wdata_sel (w_reg_wdata_sel),
        .i_rs2_data      (w_rs2_data),
        .i_imm_data      (w_imm_data),
        .i_alu_result    (w_alu_result),
        .i_mem_data      (i_data_from_dmem),
        .i_pc_plus_2     (w_pc_plus_2),
        .o_alu_in_b      (w_alu_in_b),
        .o_reg_wdata     (w_reg_wdata)
    );

    // メモリ出力接続
    assign o_addr_to_dmem = w_alu_result;
    assign o_data_to_dmem = w_rs2_data;

    // デバッグ信号の接続
    assign o_debug_instr          = i_instr;
    assign o_debug_rs1_addr       = w_rs1_addr;
    assign o_debug_rs1_data       = w_rs1_data;
    assign o_debug_rs2_addr       = w_rs2_addr;
    assign o_debug_rs2_data       = w_rs2_data;
    assign o_debug_rd_addr        = w_rd_addr;
    assign o_debug_rd_data        = w_reg_wdata;
    assign o_debug_regfile_wen    = w_reg_wen;
    assign o_debug_dmem_wen       = o_dmem_wen;
    assign o_debug_adder_to_dmem  = w_alu_result;
    assign o_debug_data_to_dmem   = w_rs2_data;
    assign o_debug_data_from_dmem = i_data_from_dmem;
    assign o_debug_now_pc         = o_addr_to_imem;
    assign o_debug_flag_z         = w_stored_z;
    assign o_debug_flag_n         = w_stored_n;
    assign o_debug_flag_v         = w_stored_v;

endmodule