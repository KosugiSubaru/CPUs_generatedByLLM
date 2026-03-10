サブモジュール `program_counter` を、教育的な視点（1bitの積み重ねで16bitが構成される様子）を強調し、論理合成後の回路図で「レジスタ」と「インクリメンタ（PC+2）」が明確に分離して見えるように構造化します。

### 提案する階層構造

| 階層レベル | ファイル名（モジュール名） | 役割 |
| :--- | :--- | :--- |
| **Level 1 (Top)** | `program_counter.v` | PCユニットの最上位。PCの保持とPC+2の計算を統合。 |
| **Level 2 (Func)** | `program_counter_reg_16bit.v` | 16bit幅のレジスタ（状態保持）。1bit D-FFを16個並列化。 |
| **Level 2 (Func)** | `program_counter_adder_16bit.v` | 16bit幅の加算器。1bitフルアダーを16個直列化（RCA）。 |
| **Level 3 (Leaf)** | `program_counter_dff.v` | クロック同期の1bit D-フリップフロップ。 |
| **Level 3 (Leaf)** | `program_counter_full_adder.v` | 1bitの全加算器（論理演算の最小単位）。 |

---

### 各モジュールの定義

#### 1. program_counter_dff.v (Level 3)
回路の最小単位となる1bitの記憶素子です。
```verilog
module program_counter_dff (
    input  wire i_clk,
    input  wire i_rst_n,
    input  wire i_d,
    output reg  o_q
);
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_q <= 1'b0;
        end else begin
            o_q <= i_d;
        end
    end
endmodule
```

#### 2. program_counter_full_adder.v (Level 3)
インクリメンタ（PC+2）を構成するための1bit加算回路です。
```verilog
module program_counter_full_adder (
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

#### 3. program_counter_reg_16bit.v (Level 2)
`generate`文を用いて、1bit D-FFを16ビット分並列に配置します。
```verilog
module program_counter_reg_16bit (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [15:0] i_data,
    output wire [15:0] o_data
);
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_pc_reg
            program_counter_dff u_dff (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_d     (i_data[i]),
                .o_q     (o_data[i])
            );
        end
    endgenerate
endmodule
```

#### 4. program_counter_adder_16bit.v (Level 2)
`generate`文を用いて、1bitフルアダーを16個接続し、リプルキャリー加算器を構成します。
```verilog
module program_counter_adder_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    output wire [15:0] o_sum
);
    wire [16:0] w_carry;
    assign w_carry[0] = 1'b0; // Carry-in is 0

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_pc_adder
            program_counter_full_adder u_fa (
                .i_a    (i_a[i]),
                .i_b    (i_b[i]),
                .i_cin  (w_carry[i]),
                .o_sum  (o_sum[i]),
                .o_cout (w_carry[i+1])
            );
        end
    endgenerate
endmodule
```

#### 5. program_counter.v (Level 1)
最上位モジュールで、PCの保持と、次命令のアドレス（PC+2）の算出を行います。
```verilog
module program_counter (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [15:0] i_next_pc,    // pc_calcから計算済みの次のPCを受け取る
    output wire [15:0] o_pc,         // 命令メモリへの現在のアドレス
    output wire [15:0] o_pc_plus_2   // jal/jalr命令用の戻りアドレス(PC+2)
);

    // PC本体 (Register)
    program_counter_reg_16bit u_pc_reg (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_data  (i_next_pc),
        .o_data  (o_pc)
    );

    // インクリメンタ (PC + 2)
    // 16bit加算器を使用して、定数2を加算する様子を視覚化
    program_counter_adder_16bit u_pc_inc (
        .i_a   (o_pc),
        .i_b   (16'd2),
        .o_sum (o_pc_plus_2)
    );

endmodule
```

---

### 説明と相互作用

1.  **視覚的理解**: 論理合成ツール（VivadoやQuartus等）で回路図を表示した際、`program_counter` の中に `u_pc_reg`（四角いレジスタ群）と `u_pc_inc`（加算器ネットワーク）が並んでいるのが一目でわかります。
2.  **パタン構造化**: `generate` 文を用いることで、16ビットという幅が1ビットの繰り返しであることをコードと回路の両面で示しています。
3.  **役割**:
    *   **Level 1 (`program_counter`)**: CPU全体から見て「現在のPC」と「デフォルトの次のPC」を提供する窓口です。
    *   **Level 2 (`reg_16bit`, `adder_16bit`)**: PCの「記憶」という機能と「計算」という機能を分離します。
    *   **Level 3 (`dff`, `full_adder`)**: デジタル回路の最小構成要素まで落とし込むことで、教育的な透明性を確保します。
4.  **動作**: クロック立ち上がりごとに `i_next_pc` が `u_pc_reg` に取り込まれます。取り込まれた値は即座に `u_pc_inc` を通り、`o_pc_plus_2` として出力されます。これは `jal` 命令などで `rd` に書き込むデータとして利用されます。