「pc_reg」について、ISAと回路の対応を視覚的に理解しやすくするため、**「1ビットのレジスタ」を最小単位とし、それを並列化して「16ビットのレジスタ」を構成する**パタン構造化を提案します。

これにより、論理合成後の回路図において、16個のフリップフロップが整然と並ぶ様子を視覚化できます。

### 1. 階層構造の概要

| 階層レベル | ファイル名 | モジュール名 | 役割 |
| :--- | :--- | :--- | :--- |
| Level 0 (最小単位) | `pc_reg_1bit.v` | `pc_reg_1bit` | 1ビット分のデータ保持（D-FlipFlop）。リセット時に0へ戻る基本素子。 |
| Level 1 (構成体) | `pc_reg_16bit.v` | `pc_reg_16bit` | `pc_reg_1bit`を16個並列に並べ、16ビットのPCレジスタを構成する。 |

---

### 2. 各モジュールの定義

#### ファイル1：pc_reg_1bit.v
教育用として、レジスタの最小単位（1ビット）を明示化します。

```verilog
// File: pc_reg_1bit.v
module pc_reg_1bit (
    input  wire i_clk,    // クロック
    input  wire i_rst_n,  // 非同期リセット（負論理）
    input  wire i_d,      // 次のアドレス値（1ビット）
    output reg  o_q       // 現在のアドレス値（1ビット）
);

    // 単一のフリップフロップとして動作
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_q <= 1'b0;
        end else begin
            o_q <= i_d;
        end
    end

endmodule
```

#### ファイル2：pc_reg_16bit.v
`generate`文を用いて、上記1ビットレジスタを16個展開します。これにより、回路図上で「16個の独立したビット保持素子が並んでいる」ことが視覚的に強調されます。

```verilog
// File: pc_reg_16bit.v
module pc_reg_16bit (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [15:0] i_pc_next,    // 次のPC値（組合せ回路からの入力）
    output wire [15:0] o_pc_current  // 現在のPC値（命令メモリへのアドレス）
);

    // 16ビット分をパタン構造化してインスタンス化
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_pc_bits
            pc_reg_1bit u_pc_bit (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_d     (i_pc_next[i]),
                .o_q     (o_pc_current[i])
            );
        end
    endgenerate

endmodule
```

---

### 3. この階層化による視覚的・教育的メリット

1.  **状態保持の明示化**: 
    CPUの中で「状態（値）」を保持しているのは、この細かなD-フリップフロップの集まりであるという事実を、ソースコードと合成後のブロック図（16個の同じ箱が並ぶ姿）の両面から理解できます。
2.  **信号の独立性の理解**: 
    16ビットのアドレスが、実は1ビットずつの独立した線の集合であり、それらが同時にクロックで更新される様子（同期回路の基本）を視覚的に示せます。
3.  **拡張性の示唆**: 
    もし将来的に「32ビットISA」へ拡張する場合、`generate`のループ回数を変更するだけで対応できるという、ハードウェア記述言語(HDL)特有の設計パタンを学ぶことができます。

### 相互作用の説明
この `pc_reg_16bit` は、外部の `pc_control` モジュールが計算した「次のアドレス（`PC+2` や分岐先の `PC+imm` など）」を `i_pc_next` から受け取ります。クロックの立ち上がりでその値が内部の16個のフリップフロップに書き込まれ、`o_pc_current` を通じて命令メモリ（imem）へと供給されます。