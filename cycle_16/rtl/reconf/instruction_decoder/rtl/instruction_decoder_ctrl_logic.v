module instruction_decoder_ctrl_logic (
    input  wire [15:0] i_inst_valid,    // One-hot展開された命令信号 (0:add, 1:sub, ..., 15:jalr)
    input  wire        i_branch_taken,  // 分岐条件成立信号
    output wire [3:0]  o_alu_op,        // ALU演算選択
    output wire        o_reg_wen,       // レジスタ書き込み許可
    output wire        o_dmem_wen,      // メモリ書き込み許可
    output wire [1:0]  o_pc_sel,        // 次PC選択 (00:PC+2, 01:PC+imm, 10:rs1+imm)
    output wire        o_alu_src_b_sel, // ALU入力B選択 (0:rs2, 1:imm)
    output wire [1:0]  o_reg_wdata_sel  // レジスタ書き込みデータ選択 (0:ALU, 1:Mem, 2:PC+2, 3:Imm)
);

    // 各命令のエイリアス (可読性と回路図上の対応用)
    wire inst_add   = i_inst_valid[0];
    wire inst_sub   = i_inst_valid[1];
    wire inst_and   = i_inst_valid[2];
    wire inst_or    = i_inst_valid[3];
    wire inst_xor   = i_inst_valid[4];
    wire inst_not   = i_inst_valid[5];
    wire inst_sra   = i_inst_valid[6];
    wire inst_sla   = i_inst_valid[7];
    wire inst_addi  = i_inst_valid[8];
    wire inst_loadi = i_inst_valid[9];
    wire inst_load  = i_inst_valid[10];
    wire inst_store = i_inst_valid[11];
    wire inst_blt   = i_inst_valid[12];
    wire inst_bz    = i_inst_valid[13];
    wire inst_jal   = i_inst_valid[14];
    wire inst_jalr  = i_inst_valid[15];

    // レジスタ書き込み許可: StoreとBranch以外の全命令
    assign o_reg_wen = inst_add | inst_sub | inst_and | inst_or | inst_xor | inst_not | 
                       inst_sra | inst_sla | inst_addi | inst_loadi | inst_load | inst_jal | inst_jalr;

    // データメモリ書き込み許可: Store命令のみ
    assign o_dmem_wen = inst_store;

    // 次PC選択信号の生成
    // 01(PC+imm): 分岐成立 または JAL
    // 10(rs1+imm): JALR
    assign o_pc_sel[0] = i_branch_taken | inst_jal;
    assign o_pc_sel[1] = inst_jalr;

    // ALU入力B選択: 即値を使用する命令 (addi, load, store)
    assign o_alu_src_b_sel = inst_addi | inst_load | inst_store;

    // レジスタ書き込みデータ選択
    // 01(Mem): load
    // 10(PC+2): jal, jalr
    // 11(Imm): loadi
    assign o_reg_wdata_sel[0] = inst_load  | inst_loadi;
    assign o_reg_wdata_sel[1] = inst_loadi | inst_jal | inst_jalr;

    // ALU演算指示 (o_alu_op)
    // load/store/addi/addはすべてALUの"加算(0000)"を使用する
    assign o_alu_op[0] = inst_sub | inst_or  | inst_not | inst_sla;
    assign o_alu_op[1] = inst_and | inst_or  | inst_sra | inst_sla;
    assign o_alu_op[2] = inst_xor | inst_not | inst_sra | inst_sla;
    assign o_alu_op[3] = 1'b0; // 現在のISAでは最上位ビットは未使用(0固定)

endmodule