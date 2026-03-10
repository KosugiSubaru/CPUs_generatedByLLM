`ifndef SVA_CPU_SV
`define SVA_CPU_SV

// `timescale 1ns/1ps

// ALU命令のレジスタファイル検証用SVA（Verilator対応版）
module sva_cpu (
    input wire        i_clk,
    input wire        i_rst_n,
    input wire [15:0] w_debug_instr,
    input wire [3:0]  w_debug_rs1_addr,
    input wire [15:0] w_debug_rs1_data,
    input wire [3:0]  w_debug_rs2_addr,
    input wire [15:0] w_debug_rs2_data,
    input wire [3:0]  w_debug_rd_addr,
    input wire [15:0] w_debug_rd_data,
    input wire [15:0] w_debug_adder_to_dmem,
    input wire [15:0] w_debug_data_to_dmem,
    input wire [15:0] w_debug_data_from_dmem,
    input wire        w_debug_dmem_wen,
    input wire        w_debug_regfile_wen,
    input wire        w_debug_zero_flag,
    input wire        w_debug_sign_flag,
    input wire        w_debug_overflow_flag,
    input wire [15:0] w_debug_now_pc,
    input wire [15:0] w_debug_next_pc
//    input wire [15:0] w_debug_imem_addr
);

    // オペコード定義（ISAに合わせて調整してください）
    localparam [3:0] OP_ADD  = 4'b0000;
    localparam [3:0] OP_SUB  = 4'b0001;
    localparam [3:0] OP_AND  = 4'b0010;
    localparam [3:0] OP_OR   = 4'b0011;
    localparam [3:0] OP_XOR  = 4'b0100;
    localparam [3:0] OP_NOT  = 4'b0101;
    localparam [3:0] OP_SLA  = 4'b0111; // Shift Left Arithmetic
    localparam [3:0] OP_SRA  = 4'b0110; // Shift Right Arithmetic
    localparam [3:0] OP_ADDI = 4'b1000; // ADD Immediate
    localparam [3:0] OP_LOAD = 4'b1001; // LOAD
    localparam [3:0] OP_LOADI= 4'b1010; // LOAD Immediate
    localparam [3:0] OP_STORE= 4'b1011; // STORE
    localparam [3:0] OP_BLT  = 4'b1100; // BLT
    localparam [3:0] OP_BEQ  = 4'b1101; // BEQ
    localparam [3:0] OP_JAL  = 4'b1110; // JAL
    localparam [3:0] OP_JALR = 4'b1111; // JALR

    // ログファイルハンドル
    integer log_file;
    
    initial begin
        log_file = $fopen("sva_verification.log", "w");
        if (log_file == 0) begin
            $display("Error: Could not open log file");
            $finish;
        end
        $fwrite(log_file, "========================================\n");
        $fwrite(log_file, "  SVA Verification Log\n");
        $fwrite(log_file, "  Start Time: %0t\n", $time);
        $fwrite(log_file, "========================================\n");
    end
    
    final begin
        $fwrite(log_file, "========================================\n");
        $fwrite(log_file, "  Simulation End Time: %0t\n", $time);
        $fwrite(log_file, "========================================\n");
        $fclose(log_file);
    end

    // 即値命令における、即値抽出、符号拡張
    reg [15:0] imm_value;
    always@(*) begin
        case (w_debug_instr[3:0])
            OP_ADDI:  imm_value = {{12{w_debug_instr[7]}}, w_debug_instr[7:4]}; // 符号拡張
            OP_LOAD:  imm_value = {{12{w_debug_instr[7]}}, w_debug_instr[7:4]}; // 符号拡張
            OP_LOADI: imm_value = {{8{w_debug_instr[11]}}, w_debug_instr[11:4]}; // 符号拡張
            OP_STORE: imm_value = {{12{w_debug_instr[15]}}, w_debug_instr[15:12]}; // 符号拡張
            OP_BLT:   imm_value = {{8{w_debug_instr[15]}}, w_debug_instr[15:8]}; // 符号拡張
            OP_BEQ:   imm_value = {{8{w_debug_instr[15]}}, w_debug_instr[15:8]}; // 符号拡張
            OP_JAL:   imm_value = {{8{w_debug_instr[11]}}, w_debug_instr[11:4]}; // 符号拡張
            OP_JALR:  imm_value = {{12{w_debug_instr[7]}}, w_debug_instr[7:4]}; // 符号拡張
            default:  imm_value = 16'h0000;
        endcase
    end


    // 期待値の計算（組み合わせ回路・同一サイクル）
    reg signed [15:0] expected_result;
    reg [15:0] expected_result_store;
    reg [15:0] expected_result_load;
    always @(*) begin
        case (w_debug_instr[3:0])
            OP_ADD:   expected_result = w_debug_rs1_data + w_debug_rs2_data;
            OP_SUB:   expected_result = w_debug_rs1_data - w_debug_rs2_data;
            OP_AND:   expected_result = w_debug_rs1_data & w_debug_rs2_data;
            OP_OR:    expected_result = w_debug_rs1_data | w_debug_rs2_data;
            OP_XOR:   expected_result = w_debug_rs1_data ^ w_debug_rs2_data;
            OP_NOT:   expected_result = ~w_debug_rs1_data;
            OP_SLA:   expected_result = w_debug_rs1_data <<< w_debug_rs2_data[3:0];
            OP_SRA:   expected_result = $signed(w_debug_rs1_data) >>> w_debug_rs2_data[3:0];
            OP_ADDI:  expected_result = w_debug_rs1_data + imm_value;
            OP_LOAD:  expected_result = w_debug_rs1_data + imm_value;
            OP_LOADI: expected_result = imm_value;
            OP_STORE: expected_result = w_debug_rs1_data + imm_value;
            OP_BLT:   expected_result = w_debug_now_pc + imm_value;
            OP_BEQ:   expected_result = w_debug_now_pc + imm_value;
            OP_JAL:   expected_result = w_debug_now_pc + imm_value;
            OP_JALR:  expected_result = w_debug_rs1_data + imm_value;
            default:  expected_result = 16'h0000;
        endcase
        
        expected_result_store = w_debug_rs2_data;
        expected_result_load  = w_debug_data_from_dmem;
    end


    //==========================================================================
    // 基本的なアドレス・データチェック
    //==========================================================================
    
    // レジスタx0は常に0であることをチェック
    assert property (@(posedge i_clk) disable iff (!i_rst_n)
        (w_debug_rs1_addr == 0) |-> (w_debug_rs1_data == 0)
    ) else $error("[TIME=%0t] Register x0 is not zero (RS1): 0x%04h", $time, w_debug_rs1_data);
    
    assert property (@(posedge i_clk) disable iff (!i_rst_n)
        (w_debug_rs2_addr == 0) |-> (w_debug_rs2_data == 0)
    ) else $error("[TIME=%0t] Register x0 is not zero (RS2): 0x%04h", $time, w_debug_rs2_data);

    //==========================================================================
    // 命令動作検証（シングルサイクル：同一クロック内で検証）
    //==========================================================================
    
    // ADD命令の検証
    assert property (@(posedge i_clk) disable iff (!i_rst_n)
        (w_debug_instr[3:0] == OP_ADD) |-> 
        ((w_debug_rd_data == expected_result) && w_debug_regfile_wen && (w_debug_dmem_wen == 0))
    ) else begin
        $error("[TIME=%0t] ADD failed: R%0d = 0x%04h, expected 0x%04h (0x%04h + 0x%04h)", 
                  $time, w_debug_rd_addr, w_debug_rd_data, expected_result, 
                  w_debug_rs1_data, w_debug_rs2_data);
    end

    // SUB命令の検証
    assert property (@(posedge i_clk) disable iff (!i_rst_n)
        (w_debug_instr[3:0] == OP_SUB) |-> 
        ((w_debug_rd_data == expected_result) && w_debug_regfile_wen && (w_debug_dmem_wen == 0))
    ) else $error("[TIME=%0t] SUB failed: R%0d = 0x%04h, expected 0x%04h (0x%04h - 0x%04h), zero_flag=%0b, sign_flag=%0b, overflow_flag=%0b", 
                  $time, w_debug_rd_addr, w_debug_rd_data, expected_result, 
                  w_debug_rs1_data, w_debug_rs2_data, w_debug_zero_flag, w_debug_sign_flag, w_debug_overflow_flag);

    // AND命令の検証
    assert property (@(posedge i_clk) disable iff (!i_rst_n)
        (w_debug_instr[3:0] == OP_AND) |-> 
        ((w_debug_rd_data == expected_result) && w_debug_regfile_wen && (w_debug_dmem_wen == 0))
    ) else $error("[TIME=%0t] AND failed: R%0d = 0x%04h, expected 0x%04h (0x%04h & 0x%04h)", 
                  $time, w_debug_rd_addr, w_debug_rd_data, expected_result, 
                  w_debug_rs1_data, w_debug_rs2_data);

    // OR命令の検証
    assert property (@(posedge i_clk) disable iff (!i_rst_n)
        (w_debug_instr[3:0] == OP_OR) |-> 
        ((w_debug_rd_data == expected_result) && w_debug_regfile_wen && (w_debug_dmem_wen == 0))
    ) else $error("[TIME=%0t] OR failed: R%0d = 0x%04h, expected 0x%04h (0x%04h | 0x%04h)", 
                  $time, w_debug_rd_addr, w_debug_rd_data, expected_result, 
                  w_debug_rs1_data, w_debug_rs2_data);

    // XOR命令の検証
    assert property (@(posedge i_clk) disable iff (!i_rst_n)
        (w_debug_instr[3:0] == OP_XOR) |-> 
        ((w_debug_rd_data == expected_result) && w_debug_regfile_wen && (w_debug_dmem_wen == 0))
    ) else $error("[TIME=%0t] XOR failed: R%0d = 0x%04h, expected 0x%04h (0x%04h ^ 0x%04h)", 
                  $time, w_debug_rd_addr, w_debug_rd_data, expected_result, 
                  w_debug_rs1_data, w_debug_rs2_data);

    // NOT命令の検証
    assert property (@(posedge i_clk) disable iff (!i_rst_n)
        (w_debug_instr[3:0] == OP_NOT) |-> 
        ((w_debug_rd_data == expected_result) && w_debug_regfile_wen && (w_debug_dmem_wen == 0))
    ) else $error("[TIME=%0t] NOT failed: R%0d = 0x%04h, expected 0x%04h (~0x%04h)", 
                  $time, w_debug_rd_addr, w_debug_rd_data, expected_result, 
                  w_debug_rs1_data);

    // SLA命令の検証
    assert property (@(posedge i_clk) disable iff (!i_rst_n)
        (w_debug_instr[3:0] == OP_SLA) |-> 
        ((w_debug_rd_data == expected_result) && w_debug_regfile_wen && (w_debug_dmem_wen == 0))
    ) else $error("[TIME=%0t] SLA failed: R%0d = 0x%04h, expected 0x%04h (0x%04h <<< %0d)", 
                  $time, w_debug_rd_addr, w_debug_rd_data, expected_result, 
                  w_debug_rs1_data, w_debug_rs2_data[3:0]);

    // SRA命令の検証
    assert property (@(posedge i_clk) disable iff (!i_rst_n)
        (w_debug_instr[3:0] == OP_SRA) |-> 
        ((w_debug_rd_data == expected_result) && w_debug_regfile_wen && (w_debug_dmem_wen == 0))
    ) else $error("[TIME=%0t] SRA failed: R%0d = 0x%04h, expected 0x%04h (0x%04h >>> %0d)", 
                  $time, w_debug_rd_addr, w_debug_rd_data, expected_result, 
                  w_debug_rs1_data, w_debug_rs2_data[3:0]);

    // ADDI命令の検証
    assert property (@(posedge i_clk) disable iff (!i_rst_n)
        (w_debug_instr[3:0] == OP_ADDI) |-> 
        ((w_debug_rd_data == expected_result) && w_debug_regfile_wen && (w_debug_dmem_wen == 0))
    ) else $error("[TIME=%0t] ADDI failed: R%0d = 0x%04h, expected 0x%04h (0x%04h + 0x%04h)", 
                  $time, w_debug_rd_addr, w_debug_rd_data, expected_result, 
                  w_debug_rs1_data, imm_value);

    // LOAD命令の検証（アドレス計算）
    assert property (@(posedge i_clk) disable iff (!i_rst_n)
        (w_debug_instr[3:0] == OP_LOAD) |-> 
        ((w_debug_adder_to_dmem == expected_result))
    ) else $error("[TIME=%0t] LOAD address calculation failed: Addr = 0x%04h, expected 0x%04h (0x%04h + 0x%04h)", 
                  $time, w_debug_adder_to_dmem, expected_result, 
                  w_debug_rs1_data, imm_value);
                
    // LOAD命令の検証（データ読み込み）
    assert property (@(posedge i_clk) disable iff (!i_rst_n)
        (w_debug_instr[3:0] == OP_LOAD) |-> 
        ((w_debug_rd_data == expected_result_load) && w_debug_regfile_wen && (w_debug_dmem_wen == 0))
    ) else $error("[TIME=%0t] LOAD data read failed: R%0d = 0x%04h, expected 0x%04h (Mem Data)", 
                  $time, w_debug_rd_addr, w_debug_rd_data, expected_result_load);

    // LOADI命令の検証
    assert property (@(posedge i_clk) disable iff (!i_rst_n)
        (w_debug_instr[3:0] == OP_LOADI) |-> 
        ((w_debug_rd_data == expected_result) && w_debug_regfile_wen && (w_debug_dmem_wen == 0))
    ) else $error("[TIME=%0t] LOADI failed: R%0d = 0x%04h, expected 0x%04h (0x%04h)", 
                  $time, w_debug_rd_addr, w_debug_rd_data, expected_result, imm_value);

    // STORE命令の検証(書き込みデータ)
    assert property (@(posedge i_clk) disable iff (!i_rst_n)
        (w_debug_instr[3:0] == OP_STORE) |-> 
        ((w_debug_data_to_dmem == expected_result_store) && w_debug_dmem_wen && (w_debug_regfile_wen == 0))
    ) else $error("[TIME=%0t] STORE data write failed: Data = 0x%04h, expected 0x%04h (R%0d Data), WEN=%0b", 
                  $time, w_debug_data_to_dmem, expected_result_store, 
                  w_debug_rs2_addr, w_debug_dmem_wen);
    
    // STORE命令の検証(アドレス計算)
    assert property (@(posedge i_clk) disable iff (!i_rst_n)
        (w_debug_instr[3:0] == OP_STORE) |-> 
        ((w_debug_adder_to_dmem == expected_result))
    ) else $error("[TIME=%0t] STORE address calculation failed: Addr = 0x%04h, expected 0x%04h (0x%04h + 0x%04h)", 
                  $time, w_debug_adder_to_dmem, expected_result, 
                  w_debug_rs1_data, imm_value);

    // BLT命令の検証（分岐する場合）
    assert property (@(posedge i_clk) disable iff (!i_rst_n)
        (w_debug_instr[3:0] == OP_BLT) && 
        ((w_debug_rs1_data) < (w_debug_rs2_data)) |-> 
        ((w_debug_next_pc == expected_result) && (w_debug_regfile_wen == 0) && (w_debug_dmem_wen == 0))
    ) else $error("[TIME=%0t] BLT taken check failed: sign_flag=%0b, overflow_flag=%0b, w_debug_next_pc=0x%04h, expected=0x%04h, \
                    w_debug_sign_flag=%0b, w_debug_overflow_flag=%0b", 
                  $time, w_debug_sign_flag, w_debug_overflow_flag, w_debug_next_pc, expected_result, w_debug_sign_flag, w_debug_overflow_flag);

    // BLT命令の検証（分岐しない場合）
    assert property (@(posedge i_clk) disable iff (!i_rst_n)
        (w_debug_instr[3:0] == OP_BLT) && 
        ((w_debug_rs1_data) >= (w_debug_rs2_data)) |-> 
        ((w_debug_next_pc == (w_debug_now_pc)+2) && (w_debug_regfile_wen == 0) && (w_debug_dmem_wen == 0))
    ) else $error("[TIME=%0t] BLT not taken check failed: sign_flag=%0b, overflow_flag=%0b, w_debug_next_pc=0x%04h, expected=0x%04h,\
                    w_debug_sign_flag=%0b, w_debug_overflow_flag=%0b", 
                  $time, w_debug_sign_flag, w_debug_overflow_flag, w_debug_next_pc, (w_debug_now_pc), w_debug_sign_flag, w_debug_overflow_flag);

    // BEQ命令の検証（分岐する場合）
    assert property (@(posedge i_clk) disable iff (!i_rst_n)
        (w_debug_instr[3:0] == OP_BEQ) && 
        ((w_debug_rs1_data) == (w_debug_rs2_data)) |-> 
        ((w_debug_next_pc == expected_result) && (w_debug_regfile_wen == 0) && (w_debug_dmem_wen == 0))
    ) else $error("[TIME=%0t] BEQ taken check failed: zero_flag=%0b, w_debug_next_pc=0x%04h, expected=0x%04h, \
                    w_debug_zero_flag=%0b", 
                  $time, w_debug_zero_flag, w_debug_next_pc, expected_result, w_debug_zero_flag);

    // BEQ命令の検証（分岐しない場合）
    assert property (@(posedge i_clk) disable iff (!i_rst_n)
        (w_debug_instr[3:0] == OP_BEQ) && 
        ((w_debug_rs1_data) != (w_debug_rs2_data)) |-> 
        ((w_debug_next_pc == (w_debug_now_pc)+2) && (w_debug_regfile_wen == 0) && (w_debug_dmem_wen == 0))
    ) else $error("[TIME=%0t] BEQ not taken check failed: zero_flag=%0b, w_debug_next_pc=0x%04h, expected=0x%04h, \
                    w_debug_zero_flag=%0b",
                  $time, w_debug_zero_flag, w_debug_next_pc, (w_debug_now_pc), w_debug_zero_flag);

    // JAL命令の検証（ジャンプ先アドレス計算）
    assert property (@(posedge i_clk) disable iff (!i_rst_n)
        (w_debug_instr[3:0] == OP_JAL) |-> 
        (w_debug_next_pc == expected_result)
    ) else $error("[TIME=%0t] JAL address calculation failed: PC = 0x%04h, expected 0x%04h", 
                  $time, w_debug_next_pc, expected_result);

    // JAL命令の検証（リンクアドレス保存）
    assert property (@(posedge i_clk) disable iff (!i_rst_n)
        (w_debug_instr[3:0] == OP_JAL) |-> 
        ((w_debug_rd_data == (w_debug_now_pc + 2)) && w_debug_regfile_wen && (w_debug_dmem_wen == 0))
    ) else $error("[TIME=%0t] JAL link address save failed: R%0d = 0x%04h, expected 0x%04h", 
                  $time, w_debug_rd_addr, w_debug_rd_data, (w_debug_now_pc + 2));

    // JALR命令の検証（ジャンプ先アドレス計算）
    assert property (@(posedge i_clk) disable iff (!i_rst_n)
        (w_debug_instr[3:0] == OP_JALR) |-> 
        (w_debug_next_pc == expected_result)
    ) else $error("[TIME=%0t] JALR address calculation failed: PC = 0x%04h, expected 0x%04h", 
                  $time, w_debug_next_pc, expected_result);

    // JALR命令の検証（リンクアドレス保存）
    assert property (@(posedge i_clk) disable iff (!i_rst_n)
        (w_debug_instr[3:0] == OP_JALR) |-> 
        ((w_debug_rd_data == (w_debug_now_pc + 2)) && w_debug_regfile_wen && (w_debug_dmem_wen == 0))
    ) else $error("[TIME=%0t] JALR link address save failed: R%0d = 0x%04h, expected 0x%04h", 
                  $time, w_debug_rd_addr, w_debug_rd_data, (w_debug_now_pc + 2));

    
    //==========================================================================
    // プログラムカウンタの検証（次の命令アドレス）
    //==========================================================================

    // SVAの|=>を用いて、次のクロックでのpcを検証する
    // ジャンプする場合としない場合の両方をカバー

    // ジャンプ命令の場合
    assert property (@(posedge i_clk) disable iff (!i_rst_n)
        ((w_debug_instr[3:0] == OP_JAL) || (w_debug_instr[3:0] == OP_JALR)) |=>
        (w_debug_now_pc == $past(expected_result))
    ) else $error("[TIME=%0t] PC update failed for jump/branch instruction: now_pc=0x%04h, expected=0x%04h", 
                  $time, w_debug_now_pc, $past(expected_result));

    // 分岐命令で分岐する場合
    assert property (@(posedge i_clk) disable iff (!i_rst_n)
        ((w_debug_instr[3:0] == OP_BLT) && (w_debug_rs1_data < w_debug_rs2_data) ||
         (w_debug_instr[3:0] == OP_BEQ) && (w_debug_rs1_data == w_debug_rs2_data)) |=>
        (w_debug_now_pc == $past(expected_result))
    ) else $error("[TIME=%0t] PC update failed for taken branch instruction: now_pc=0x%04h, expected=0x%04h", 
                  $time, w_debug_now_pc, $past(expected_result));

    // 分岐命令で分岐しない場合
    assert property (@(posedge i_clk) disable iff (!i_rst_n)
        ((w_debug_instr[3:0] == OP_BLT) && (w_debug_rs1_data >= w_debug_rs2_data) ||
         (w_debug_instr[3:0] == OP_BEQ) && (w_debug_rs1_data != w_debug_rs2_data)) |=>
        (w_debug_now_pc == $past(w_debug_now_pc) + 2)
    ) else $error("[TIME=%0t] PC update failed for not taken branch instruction: now_pc=0x%04h, expected=0x%04h", 
                  $time, w_debug_now_pc, $past(w_debug_now_pc) + 2);

    // それ以外の命令の場合
    assert property (@(posedge i_clk) disable iff (!i_rst_n)
        !((w_debug_instr[3:0] == OP_JAL) || (w_debug_instr[3:0] == OP_JALR) || (w_debug_instr[3:0] == OP_BLT) || (w_debug_instr[3:0] == OP_BEQ)) |=>
        (w_debug_now_pc == $past(w_debug_now_pc) + 2)
    ) else $error("[TIME=%0t] PC update failed for non-jump/branch instruction: now_pc=0x%04h, expected=0x%04h", 
                  $time, w_debug_now_pc, $past(w_debug_now_pc) + 2);



    //==========================================================================
    // 情報表示（正常動作時）
    //==========================================================================
    
    always @(posedge i_clk) begin
        if (i_rst_n) begin
            case (w_debug_instr[3:0])
                OP_ADD: if ((w_debug_rd_data == expected_result) && w_debug_regfile_wen && (w_debug_dmem_wen == 0)) begin
                    $display("[SVA OK] Time=%0t: ADD R%0d = 0x%04h (0x%04h + 0x%04h)", 
                             $time, w_debug_rd_addr, w_debug_rd_data, w_debug_rs1_data, w_debug_rs2_data);
                    $fwrite(log_file, "[OK][TIME=%0t] ADD R%0d = 0x%04h (0x%04h + 0x%04h)\n", 
                             $time, w_debug_rd_addr, w_debug_rd_data, w_debug_rs1_data, w_debug_rs2_data);
                end
                OP_SUB: if ((w_debug_rd_data == expected_result) && w_debug_regfile_wen && (w_debug_dmem_wen == 0))
                    $display("[SVA OK] Time=%0t: SUB R%0d = 0x%04h (0x%04h - 0x%04h) zero_flag=%0b, sign_flag=%0b, overflow_flag=%0b", 
                             $time, w_debug_rd_addr, w_debug_rd_data, w_debug_rs1_data, w_debug_rs2_data, w_debug_zero_flag, w_debug_sign_flag, w_debug_overflow_flag);
                OP_AND: if ((w_debug_rd_data == expected_result) && w_debug_regfile_wen && (w_debug_dmem_wen == 0))
                    $display("[SVA OK] Time=%0t: AND R%0d = 0x%04h (0x%04h & 0x%04h)", 
                             $time, w_debug_rd_addr, w_debug_rd_data, w_debug_rs1_data, w_debug_rs2_data);
                OP_OR:  if ((w_debug_rd_data == expected_result) && w_debug_regfile_wen && (w_debug_dmem_wen == 0))
                    $display("[SVA OK] Time=%0t: OR  R%0d = 0x%04h (0x%04h | 0x%04h)", 
                             $time, w_debug_rd_addr, w_debug_rd_data, w_debug_rs1_data, w_debug_rs2_data);
                OP_XOR: if ((w_debug_rd_data == expected_result) && w_debug_regfile_wen && (w_debug_dmem_wen == 0))
                    $display("[SVA OK] Time=%0t: XOR R%0d = 0x%04h (0x%04h ^ 0x%04h)", 
                             $time, w_debug_rd_addr, w_debug_rd_data, w_debug_rs1_data, w_debug_rs2_data);
                OP_NOT: if ((w_debug_rd_data == expected_result) && w_debug_regfile_wen && (w_debug_dmem_wen == 0))
                    $display("[SVA OK] Time=%0t: NOT R%0d = 0x%04h (~0x%04h)", 
                             $time, w_debug_rd_addr, w_debug_rd_data, w_debug_rs1_data);
                OP_SLA: if ((w_debug_rd_data == expected_result) && w_debug_regfile_wen && (w_debug_dmem_wen == 0))
                    $display("[SVA OK] Time=%0t: SLA R%0d = 0x%04h (0x%04h <<< %0d)", 
                             $time, w_debug_rd_addr, w_debug_rd_data, w_debug_rs1_data, w_debug_rs2_data[3:0]);
                OP_SRA: if ((w_debug_rd_data == expected_result) && w_debug_regfile_wen && (w_debug_dmem_wen == 0))
                    $display("[SVA OK] Time=%0t: SRA R%0d = 0x%04h (0x%04h >>> %0d)", 
                             $time, w_debug_rd_addr, w_debug_rd_data, w_debug_rs1_data, w_debug_rs2_data[3:0]);
                OP_ADDI: if ((w_debug_rd_data == expected_result) && w_debug_regfile_wen && (w_debug_dmem_wen == 0))
                    $display("[SVA OK] Time=%0t: ADDI R%0d = 0x%04h (0x%04h + 0x%04h)", 
                             $time, w_debug_rd_addr, w_debug_rd_data, w_debug_rs1_data, imm_value);
                OP_LOAD: if ((w_debug_adder_to_dmem == expected_result) && w_debug_regfile_wen && (w_debug_dmem_wen == 0))
                    $display("[SVA OK] Time=%0t: LOAD Addr = 0x%04h (0x%04h + 0x%04h)", 
                             $time, w_debug_adder_to_dmem, w_debug_rs1_data, imm_value);
                OP_LOADI: if ((w_debug_rd_data == expected_result) && w_debug_regfile_wen && (w_debug_dmem_wen == 0))
                    $display("[SVA OK] Time=%0t: LOADI R%0d = 0x%04h (0x%04h)", 
                             $time, w_debug_rd_addr, w_debug_rd_data, imm_value);
                OP_STORE: if ((w_debug_data_to_dmem == expected_result_store) &&
                              (w_debug_adder_to_dmem == expected_result) &&
                              w_debug_dmem_wen)
                    $display("[SVA OK] Time=%0t: STORE Addr = 0x%04h, Data = 0x%04h (R%0d Data), WEN=%0b",
                             $time, w_debug_adder_to_dmem, w_debug_data_to_dmem, w_debug_rs2_addr, w_debug_dmem_wen);
                OP_BLT: if ((w_debug_rs1_data < w_debug_rs2_data) &&
                                (w_debug_next_pc == expected_result) && (w_debug_regfile_wen == 0) && (w_debug_dmem_wen == 0))
                    $display("[SVA OK] Time=%0t: BLT taken to PC = 0x%04h, sign_flag=%0b, overflow_flag=%0b", 
                             $time, w_debug_next_pc, w_debug_sign_flag, w_debug_overflow_flag);
                        else if ((w_debug_rs1_data >= w_debug_rs2_data) &&
                                (w_debug_next_pc == (w_debug_now_pc)+2) && (w_debug_regfile_wen == 0) && (w_debug_dmem_wen == 0))
                    $display("[SVA OK] Time=%0t: BLT not taken, PC = 0x%04h, sign_flag=%0b, overflow_flag=%0b", 
                             $time, w_debug_next_pc, w_debug_sign_flag, w_debug_overflow_flag);
                OP_BEQ:  if ( ((w_debug_rs1_data) == (w_debug_rs2_data)) &&
                                (w_debug_next_pc == expected_result) && (w_debug_regfile_wen == 0) && (w_debug_dmem_wen == 0))
                    $display("[SVA OK] Time=%0t: BEQ taken to PC = 0x%04h, zero_flag=%0b", 
                             $time, w_debug_next_pc, w_debug_zero_flag);
                        else if ( ((w_debug_rs1_data) != (w_debug_rs2_data)) &&
                                (w_debug_next_pc == (w_debug_now_pc)+2) && (w_debug_regfile_wen == 0) && (w_debug_dmem_wen == 0))
                    $display("[SVA OK] Time=%0t: BEQ not taken, PC = 0x%04h, zero_flag=%0b", 
                             $time, w_debug_next_pc, w_debug_zero_flag);
                OP_JAL: if ((w_debug_next_pc == expected_result) && (w_debug_regfile_wen == 1) && (w_debug_dmem_wen == 0) &&
                             (w_debug_rd_data == (w_debug_now_pc + 2)))
                    $display("[SVA OK] Time=%0t: JAL to PC = 0x%04h, link R%0d = 0x%04h", 
                             $time, w_debug_next_pc, w_debug_rd_addr, w_debug_rd_data);
                OP_JALR: if ((w_debug_next_pc == expected_result) && (w_debug_regfile_wen == 1) && (w_debug_dmem_wen == 0) &&
                              (w_debug_rd_data == (w_debug_now_pc + 2)))
                    $display("[SVA OK] Time=%0t: JALR to PC = 0x%04h, link R%0d = 0x%04h", 
                             $time, w_debug_next_pc, w_debug_rd_addr, w_debug_rd_data);
                default: ;
            endcase
        end
    end

endmodule

`endif
