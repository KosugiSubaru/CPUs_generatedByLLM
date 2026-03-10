module control_unit (
    input  wire [3:0] i_opcode,
    output wire [3:0] o_alu_op,
    output wire       o_reg_wen,
    output wire       o_dmem_wen,
    output wire       o_alu_src_sel,
    output wire [1:0] o_wb_sel,
    output wire       o_is_branch_blt,
    output wire       o_is_branch_bz,
    output wire       o_is_jump_imm,
    output wire       o_is_jump_reg
);

    wire [15:0] w_instr_signals;
    wire        w_wb_mem;
    wire        w_wb_pc;
    wire        w_wb_imm;

    // 命令デコーダー：4bitのopcodeを16本の信号に展開
    control_unit_decoder u_decoder (
        .i_opcode        (i_opcode),
        .o_instr_signals (w_instr_signals)
    );

    // ALU演算種別の決定
    // Load (opcode: 1010, bit 10) と Store (opcode: 1011, bit 11) は、
    // アドレス計算のために強制的に「加算（0000）」を行うよう、ALUへの指示を変換する。
    // これにより、Store命令(1011)の末尾の1によって減算が行われる誤動作を防ぐ。
    assign o_alu_op = (w_instr_signals[10] | w_instr_signals[11]) ? 4'b0000 : i_opcode;

    // レジスタ書き込み許可 (add, sub, and, or, xor, not, sra, sla, addi, loadi, load, jal, jalr)
    // 書き込みを行わない命令: store(11), blt(12), bz(13)
    // Mask: 0xC7FF (1100_0111_1111_1111)
    control_unit_gate_or u_gate_reg_wen (
        .i_instr_signals (w_instr_signals),
        .i_mask          (16'hC7FF),
        .o_gate_out      (o_reg_wen)
    );

    // データメモリ書き込み許可 (storeのみ)
    // Mask: 0x0800 (0000_1000_0000_0000)
    control_unit_gate_or u_gate_dmem_wen (
        .i_instr_signals (w_instr_signals),
        .i_mask          (16'h0800),
        .o_gate_out      (o_dmem_wen)
    );

    // ALU入力選択 (0:rs2, 1:imm)
    // 対象命令: addi(8), load(10), store(11), jalr(15)
    // Mask: 0x8D00 (1000_1101_0000_0000)
    control_unit_gate_or u_gate_alu_src (
        .i_instr_signals (w_instr_signals),
        .i_mask          (16'h8D00),
        .o_gate_out      (o_alu_src_sel)
    );

    // 書き戻しデータ選択信号の生成
    control_unit_gate_or u_gate_wb_mem ( .i_instr_signals(w_instr_signals), .i_mask(16'h0400), .o_gate_out(w_wb_mem) );
    control_unit_gate_or u_gate_wb_pc  ( .i_instr_signals(w_instr_signals), .i_mask(16'hC000), .o_gate_out(w_wb_pc)  );
    control_unit_gate_or u_gate_wb_imm ( .i_instr_signals(w_instr_signals), .i_mask(16'h0200), .o_gate_out(w_wb_imm) );

    // 00:ALU結果, 01:メモリ読み出し, 10:PC+2, 11:即値(loadi用)
    assign o_wb_sel = (w_wb_imm) ? 2'b11 :
                      (w_wb_pc)  ? 2'b10 :
                      (w_wb_mem) ? 2'b01 : 2'b00;

    // 分岐・ジャンプ制御信号
    control_unit_gate_or u_gate_blt ( .i_instr_signals(w_instr_signals), .i_mask(16'h1000), .o_gate_out(o_is_branch_blt) );
    control_unit_gate_or u_gate_bz  ( .i_instr_signals(w_instr_signals), .i_mask(16'h2000), .o_gate_out(o_is_branch_bz)  );
    control_unit_gate_or u_gate_jim ( .i_instr_signals(w_instr_signals), .i_mask(16'h4000), .o_gate_out(o_is_jump_imm)   );
    control_unit_gate_or u_gate_jrg ( .i_instr_signals(w_instr_signals), .i_mask(16'h8000), .o_gate_out(o_is_jump_reg)   );

endmodule