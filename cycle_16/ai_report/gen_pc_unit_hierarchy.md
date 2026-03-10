教育用CPUとして、回路図で見たときに「ビットごとの並び（パターン）」と「機能ごとの塊（階層）」が明確に分かれる設計を提案します。

`pc_unit`は、単に数値を保持するだけでなく、**「次のアドレスをどこから持ってくるか（選択）」**と**「アドレスの計算（加算）」**、そして**「状態の保持（レジスタ）」**の3要素で構成します。

---

### 1. 階層構造とファイル一覧

| 階層レベル | ファイル名 | 役割 |
| :--- | :--- | :--- |
| **L0 (Top)** | `pc_unit.v` | PCユニットの最上位。加算器、セレクタ、レジスタを接続し、PC更新ロジックを統合する。 |
| **L1 (Functional)** | `pc_unit_reg_16bit.v` | 16ビットの値をクロック同期で保持するレジスタ。 |
| | `pc_unit_adder_16bit.v` | 16ビットの加算器。次アドレス（PC+2, PC+imm等）の計算用。 |
| | `pc_unit_mux_3to1_16bit.v` | 次のPC値を「通常(+2)」「分岐/JAL(+imm)」「JALR(rs1+imm)」から選択する。 |
| **L2 (Pattern)** | `pc_unit_reg_1bit.v` | 1ビットのD-フリップフロップ。 |
| | `pc_unit_full_adder.v` | 1ビットの全加算器。 |
| | `pc_unit_mux_3to1_1bit.v` | 1ビット幅の3入力セレクタ。 |

---

### 2. 各モジュールの定義（ソースコード）

#### L2: パターン構造化用モジュール

**pc_unit_reg_1bit.v**
```verilog
module pc_unit_reg_1bit (
    input  wire i_clk,
    input  wire i_rst_n,
    input  wire i_d,
    output reg  o_q
);
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) o_q <= 1'b0;
        else          o_q <= i_d;
    end
endmodule
```

**pc_unit_full_adder.v**
```verilog
module pc_unit_full_adder (
    input  wire i_a,
    input  wire i_b,
    input  wire i_cin,
    output wire o_sum,
    output wire o_cout
);
    assign o_sum  = i_a ^ i_b ^ i_cin;
    assign o_cout = (i_a & i_b) | (i_cin & (i_a ^ i_b));
endmodule
```

**pc_unit_mux_3to1_1bit.v**
```verilog
module pc_unit_mux_3to1_1bit (
    input  wire [1:0] i_sel,
    input  wire i_d0, // PC+2
    input  wire i_d1, // PC+imm
    input  wire i_d2, // rs1+imm
    output wire o_q
);
    assign o_q = (i_sel == 2'b00) ? i_d0 :
                 (i_sel == 2'b01) ? i_d1 :
                 (i_sel == 2'b10) ? i_d2 : i_d0;
endmodule
```

---

#### L1: 機能ブロック（generate文による構造化）

**pc_unit_reg_16bit.v**
```verilog
module pc_unit_reg_16bit (
    input  wire i_clk,
    input  wire i_rst_n,
    input  wire [15:0] i_data,
    output wire [15:0] o_pc
);
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : reg_array
            pc_unit_reg_1bit u_reg (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_d     (i_data[i]),
                .o_q     (o_pc[i])
            );
        end
    endgenerate
endmodule
```

**pc_unit_adder_16bit.v**
```verilog
module pc_unit_adder_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    output wire [15:0] o_sum
);
    wire [16:0] carry;
    assign carry[0] = 1'b0;
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : adder_array
            pc_unit_full_adder u_fa (
                .i_a    (i_a[i]),
                .i_b    (i_b[i]),
                .i_cin  (carry[i]),
                .o_sum  (o_sum[i]),
                .o_cout (carry[i+1])
            );
        end
    endgenerate
endmodule
```

**pc_unit_mux_3to1_16bit.v**
```verilog
module pc_unit_mux_3to1_16bit (
    input  wire [1:0]  i_sel,
    input  wire [15:0] i_d0,
    input  wire [15:0] i_d1,
    input  wire [15:0] i_d2,
    output wire [15:0] o_data
);
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : mux_array
            pc_unit_mux_3to1_1bit u_mux (
                .i_sel (i_sel),
                .i_d0  (i_d0[i]),
                .i_d1  (i_d1[i]),
                .i_d2  (i_d2[i]),
                .o_q   (o_data[i])
            );
        end
    endgenerate
endmodule
```

---

#### L0: PCユニット統合

**pc_unit.v**
```verilog
module pc_unit (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [1:0]  i_pc_sel,    // 00:Normal, 01:Branch/JAL, 10:JALR
    input  wire [15:0] i_imm,       // 符号拡張済み即値
    input  wire [15:0] i_rs1_data,  // JALR用
    output wire [15:0] o_pc,        // 命令メモリ(imem)へ
    output wire [15:0] o_pc_plus_2  // jal/jalrの戻りアドレス用(rdに書き込む値)
);
    wire [15:0] w_current_pc;
    wire [15:0] w_next_pc;
    wire [15:0] w_pc_plus_imm;
    wire [15:0] w_rs1_plus_imm;

    assign o_pc = w_current_pc;

    // 現在のPCを保持するレジスタ
    pc_unit_reg_16bit u_reg_pc (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_data  (w_next_pc),
        .o_pc    (w_current_pc)
    );

    // PC + 2 の計算
    pc_unit_adder_16bit u_adder_plus_2 (
        .i_a   (w_current_pc),
        .i_b   (16'd2),
        .o_sum (o_pc_plus_2)
    );

    // PC + imm の計算 (Branch / JAL用)
    pc_unit_adder_16bit u_adder_plus_imm (
        .i_a   (w_current_pc),
        .i_b   (i_imm),
        .o_sum (w_pc_plus_imm)
    );

    // rs1 + imm の計算 (JALR用)
    pc_unit_adder_16bit u_adder_jalr (
        .i_a   (i_rs1_data),
        .i_b   (i_imm),
        .o_sum (w_rs1_plus_imm)
    );

    // 次のPCを選択
    pc_unit_mux_3to1_16bit u_mux_next_pc (
        .i_sel  (i_pc_sel),
        .i_d0   (o_pc_plus_2),    // 通常
        .i_d1   (w_pc_plus_imm),  // 分岐・JAL
        .i_d2   (w_rs1_plus_imm), // JALR
        .o_data (w_next_pc)
    );

endmodule
```

---

### 3. 設計のポイント（教育的効果）

1.  **視覚的なビット整列**: `generate`文を用いて1ビットのコンポーネントを16個並べることで、論理合成ツール（VivadoやQuartusなど）のNetlist Viewerで見た際に、**「16個の同じ素子が整然と並んでいる様子」**が視覚的に確認できます。これは、データパスの概念を理解するのに非常に有効です。
2.  **ISAとの対応**: `pc_unit.v`の中で「PC+2」「PC+imm」「rs1+imm」という3つの加算器が並んでいることで、ISAで定義された動作（behavior）がそのままハードウェアの塊として存在していることが分かります。
3.  **役割の明確化**:
    *   L2（1ビット単位）は「論理ゲート」のレベル。
    *   L1（16ビット単位）は「再利用可能な部品（バス幅に応じた部品）」のレベル。
    *   L0（統合）は「CPUの機能仕様」を実現するレベル。
    このように段階を踏むことで、複雑なデジタル回路が単純なものの積み重ねであることを強調しています。