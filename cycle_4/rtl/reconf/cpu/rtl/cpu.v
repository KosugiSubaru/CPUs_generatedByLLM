module cpu (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [15:0] i_instr,
    input  wire [15:0] i_data_from_dmem,

    output wire [15:0] o_addr_to_dmem,
    output wire [15:0] o_data_to_dmem,
    output wire [15:0] o_addr_to_imem,
    output wire        o_dmem_wen,

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

    // 内部信号定義
    wire [15:0] w_pc_current;
    wire [15:0] w_pc_next;
    wire [15:0] w_pc_plus2;
    wire [3:0]  w_opcode;
    wire [3:0]  w_rd_addr;
    wire [3:0]  w_rs1_addr;
    wire [3:0]  w_rs2_addr;
    
    // 制御信号
    wire        w_reg_write;
    wire        w_mem_write;
    wire        w_alu_src;
    wire        w_mem_to_reg;
    wire        w_reg_src_pc;
    wire        w_imm_load;
    wire [3:0]  w_alu_op;
    wire        w_branch;
    wire        w_jump;
    wire        w_jump_reg;
    wire [1:0]  w_imm_sel;

    // データパス信号
    wire [15:0] w_rs1_data;
    wire [15:0] w_rs2_data;
    wire [15:0] w_rd_data;
    wire [15:0] w_imm;
    wire [15:0] w_alu_op2;
    wire [15:0] w_alu_res;
    
    // フラグ信号
    wire        w_flag_z_curr, w_flag_n_curr, w_flag_v_curr;
    wire        w_flag_z_latched, w_flag_n_latched, w_flag_v_latched;

    // 命令フィールドの分解
    assign w_opcode  = i_instr[3:0];
    assign w_rs2_addr = i_instr[7:4];
    assign w_rs1_addr = i_instr[11:8];
    assign w_rd_addr  = i_instr[15:12];

    // 即値選択ロジック (ISAのbit_field定義に基づく)
    assign w_imm_sel = (w_opcode == 4'b1001 || w_opcode == 4'b1110) ? 2'b01 : // loadi, jal (ext8)
                       (w_opcode == 4'b1100 || w_opcode == 4'b1101) ? 2'b10 : // branch (ext12)
                       (w_opcode == 4'b1011) ? 2'b11 :                        // store (ext4h)
                       2'b00;                                                 // addi, load, jalr (ext4)

    // PCレジスタ
    pc_reg u_pc_reg (
        .i_clk          (i_clk),
        .i_rst_n        (i_rst_n),
        .i_pc_next      (w_pc_next),
        .o_pc_current   (w_pc_current)
    );

    // 制御ユニット
    control_unit u_control_unit (
        .i_opcode       (w_opcode),
        .o_reg_write    (w_reg_write),
        .o_mem_write    (w_mem_write),
        .o_alu_src      (w_alu_src),
        .o_mem_to_reg   (w_mem_to_reg),
        .o_reg_src_pc   (w_reg_src_pc),
        .o_imm_load     (w_imm_load),
        .o_alu_op       (w_alu_op),
        .o_branch       (w_branch),
        .o_jump         (w_jump),
        .o_jump_reg     (w_jump_reg)
    );

    // レジスタファイル
    register_file u_register_file (
        .i_clk          (i_clk),
        .i_rst_n        (i_rst_n),
        .i_rs1_addr     (w_rs1_addr),
        .i_rs2_addr     (w_rs2_addr),
        .i_rd_addr      (w_rd_addr),
        .i_rd_data      (w_rd_data),
        .i_wen          (w_reg_write),
        .o_rs1_data     (w_rs1_data),
        .o_rs2_data     (w_rs2_data)
    );

    // 即値生成
    imm_gen u_imm_gen (
        .i_instr        (i_instr),
        .i_imm_sel      (w_imm_sel),
        .o_imm          (w_imm)
    );

    // ALU入力MUX (loadi時はimmを第2入力へ)
    alu_src_mux u_alu_src_mux (
        .i_alu_src      (w_alu_src || w_imm_load),
        .i_rs2_data     (w_rs2_data),
        .i_imm_data     (w_imm),
        .o_alu_op2      (w_alu_op2)
    );

    // ALU
    alu u_alu (
        .i_rs1          (w_rs1_data),
        .i_rs2          (w_alu_op2),
        .i_opcode       (w_alu_op),
        .o_rd           (w_alu_res),
        .o_flag_z       (w_flag_z_curr),
        .o_flag_n       (w_flag_n_curr),
        .o_flag_v       (w_flag_v_curr)
    );

    // フラグレジスタ (1クロック遅延させて条件分岐で使用)
    flag_reg u_flag_reg (
        .i_clk          (i_clk),
        .i_rst_n        (i_rst_n),
        .i_flag_z       (w_flag_z_curr),
        .i_flag_n       (w_flag_n_curr),
        .i_flag_v       (w_flag_v_curr),
        .o_flag_z       (w_flag_z_latched),
        .o_flag_n       (w_flag_n_latched),
        .o_flag_v       (w_flag_v_latched)
    );

    // PC制御 (次PC決定)
    pc_control u_pc_control (
        .i_pc_current   (w_pc_current),
        .i_rs1_data     (w_rs1_data),
        .i_imm          (w_imm),
        .i_opcode       (w_opcode),
        .i_flag_z       (w_flag_z_latched),
        .i_flag_n       (w_flag_n_latched),
        .i_flag_v       (w_flag_v_latched),
        .i_branch       (w_branch),
        .i_jump         (w_jump),
        .i_jump_reg     (w_jump_reg),
        .o_pc_next      (w_pc_next),
        .o_pc_plus2     (w_pc_plus2)
    );

    // ライトバックMUX
    wb_data_mux u_wb_data_mux (
        .i_mem_to_reg   (w_mem_to_reg),
        .i_reg_src_pc   (w_reg_src_pc),
        .i_alu_res      (w_alu_res),
        .i_mem_data     (i_data_from_dmem),
        .i_pc_plus2     (w_pc_plus2),
        .o_wb_data      (w_rd_data)
    );

    // 外部インターフェース接続
    assign o_addr_to_imem   = w_pc_current;
    assign o_addr_to_dmem   = w_alu_res;
    assign o_data_to_dmem   = w_rs2_data;
    assign o_dmem_wen       = w_mem_write;

    // デバッグ出力
    assign o_debug_instr          = i_instr;
    assign o_debug_rs1_addr       = w_rs1_addr;
    assign o_debug_rs1_data       = w_rs1_data;
    assign o_debug_rs2_addr       = w_rs2_addr;
    assign o_debug_rs2_data       = w_rs2_data;
    assign o_debug_rd_addr        = w_rd_addr;
    assign o_debug_rd_data        = w_rd_data;
    assign o_debug_regfile_wen    = w_reg_write;
    assign o_debug_dmem_wen       = w_mem_write;
    assign o_debug_adder_to_dmem  = w_alu_res;
    assign o_debug_data_to_dmem   = w_rs2_data;
    assign o_debug_data_from_dmem = i_data_from_dmem;
    assign o_debug_now_pc         = w_pc_current;
    assign o_debug_flag_n         = w_flag_n_latched;
    assign o_debug_flag_v         = w_flag_v_latched;
    assign o_debug_flag_z         = w_flag_z_latched;

endmodule