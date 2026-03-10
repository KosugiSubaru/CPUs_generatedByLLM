サブモジュール「pc_reg」について、教育的な視覚効果（回路図でのブロック化）と、パターン構造化（generate文の活用）を両立させた階層化を提案します。

この設計では、16ビットのレジスタを「1ビットのDフリップフロップ」から「4ビットのグループ（ニブル）」、そして「16ビット全体」へと段階的にビルドアップします。これにより、論理合成後の回路図において、ビットごとの構造が整然と配置され、ハードウェアの物理的な構成を直感的に理解できるようになります。

---

### 1. 階層構造の説明

| 階層レベル | ファイル名 | モジュール名 | 役割 |
| :--- | :--- | :--- | :--- |
| **Level 0** | `pc_reg_dff.v` | `pc_reg_dff` | 最最小単位。1ビットのD-FF。リセット機能（`i_rst_n`）を持つ。 |
| **Level 1** | `pc_reg_4bit.v` | `pc_reg_4bit` | **パターン構造化単位**。`pc_reg_dff`を4個並べた4ビットレジスタ。 |
| **Level 2** | `pc_reg_16bit.v` | `pc_reg_16bit` | **pc_regの実体**。`pc_reg_4bit`を4個並べて16ビットを構成する。 |

---

### 2. 各モジュールの定義

#### Level 0: 1ビットDフリップフロップ
ビットレベルの挙動を定義します。

```verilog
// pc_reg_dff.v
module pc_reg_dff (
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

#### Level 1: 4ビット・レジスタ・ユニット
`generate`文を用いて、最小単位を構造化します。これにより回路図上で4ビットずつの「箱」として視覚化されます。

```verilog
// pc_reg_4bit.v
module pc_reg_4bit (
    input  wire       i_clk,
    input  wire       i_rst_n,
    input  wire [3:0] i_d,
    output wire [3:0] o_q
);
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : bit_slice
            pc_reg_dff u_dff (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_d     (i_d[i]),
                .o_q     (o_q[i])
            );
        end
    endgenerate
endmodule
```

#### Level 2: 16ビット・プログラムカウンタ（pc_reg本体）
上位モジュール（CPUトップ）から呼び出される実体です。4ビット単位でインスタンス化することで、16ビット一括で書くよりもデバッグや視覚化の際に「どのニブル（上位/下位）を扱っているか」が明確になります。

```verilog
// pc_reg_16bit.v
module pc_reg_16bit (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [15:0] i_next_pc,
    output wire [15:0] o_now_pc
);
    genvar j;
    generate
        for (j = 0; j < 4; j = j + 1) begin : nibble_slice
            pc_reg_4bit u_pc_nibble (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_d     (i_next_pc[j*4 +: 4]),
                .o_q     (o_now_pc [j*4 +: 4])
            );
        end
    endgenerate
endmodule
```

---

### 3. 提案のメリット（教育的意図）

1.  **ビット展開の視覚化**:
    論理合成ツール（Vivado, Quartus, Yosys等）でSchematicを表示した際、`nibble_slice[0]`〜`[3]`という4つのブロックが表示され、その中にさらに`bit_slice[0]`〜`[3]`が並びます。「16ビットレジスタは1ビットのフリップフロップが16個並んでいるだけである」という基本概念を視覚的に強調できます。
2.  **階層レベルの適切な維持**:
    `next_pc_logic`（PCの計算・選択）をこの`pc_reg`内に含めず、純粋な「値を保持する機能」に限定することで、**状態（レジスタ）と組み合わせ回路（演算）の分離**を明示的に学べます。
3.  **スケーラビリティの理解**:
    `generate`文を使うことで、もし将来的に32ビットや64ビットへISAを拡張する場合でも、ループ回数を変えるだけで対応できる設計パターンを提示しています。