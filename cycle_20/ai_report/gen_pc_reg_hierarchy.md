サブモジュール「**pc_reg**」について、回路図での視覚化と、16ビット幅への拡張性を考慮した階層化・パターン構造化を提案します。

### 1. 階層構造の定義

`pc_reg` を以下の2レベルで構成します。16ビットのレジスタを「1ビットの記憶素子の集合」として定義することで、論理合成後の回路図においてビットごとの並びが視覚的に理解しやすくなります。

| レベル | ファイル名 | モジュール名 | 役割 |
| :--- | :--- | :--- | :--- |
| **Level 1** | `pc_reg.v` | `pc_reg` | **サブモジュール・トップ**。16ビットのPCレジスタ本体。`generate` 文を用いて1ビットレジスタを16個展開する。 |
| **Level 2** | `pc_reg_dff.v` | `pc_reg_dff` | **最小単位（リーフ）**。1ビットのDフリップフロップ。非同期リセット（`i_rst_n`）を備える。 |

---

### 2. 各モジュールの実装提案

#### Level 2: pc_reg_dff.v (最小単位)
記憶素子の最小単位です。教育用として、1ビットの状態保持が回路の基本であることを示します。

```verilog
// pc_reg_dff.v
module pc_reg_dff (
    input  wire i_clk,   // クロック
    input  wire i_rst_n, // 非同期リセット（アクティブL）
    input  wire i_d,     // データ入力
    output reg  o_q      // データ出力
);
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_q <= 16'b0;
        end else begin
            o_q <= i_d;
        end
    end
endmodule
```

#### Level 1: pc_reg.v (構造化トップ)
`generate` 文を使用し、Level 2 のモジュールを ISA のデータ幅（16ビット）分インスタンス化します。これにより、合成後の回路図では 16 個の DFF ブロックが並ぶ様子が視覚化されます。

```verilog
// pc_reg.v
module pc_reg (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [15:0] i_next_pc, // pc_logic等から計算された次のアドレス
    output wire [15:0] o_now_pc    // 命令メモリへ送る現在のアドレス
);

    // generate文による16ビット展開（パターン構造化）
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : g_pc_bits
            pc_reg_dff u_dff (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_d     (i_next_pc[i]),
                .o_q     (o_now_pc[i])
            );
        end
    endgenerate

endmodule
```

---

### 3. 設計のポイント

1.  **視覚的理解（ビットスライス構造）**:
    論理合成ツール（Vivado, Quartus, Yosys等）で回路図を表示した際、`pc_reg` ブロックの中に 16 個の `u_dff` ブロックが整列して表示されます。これにより、「16ビットレジスタとは、1ビットの箱が16個並んだものである」という概念を物理的に視覚化できます。
    
2.  **MUXの階層化方針（補足）**:
    今回の `pc_reg` は純粋な記憶保持のみを行うため内部に MUX を含みませんが、この方針に基づき、上位の `pc_logic`（次PC選択）等のモジュールでは、以下のような階層化を適用します：
    *   `pc_logic_mux4to1_1bit.v`（1ビットの4入力セレクタ）
    *   `pc_logic_mux4to1_16bit.v`（`generate` 文で16個並列化）
    これにより、複雑なデータパスも「1ビットの論理の集合」として整理されます。

3.  **パタン構造化のメリット**:
    `generate` 文を使用することで、ISA の仕様変更（例：32ビット化）が必要になった場合でも、ループ境界を変更するだけで回路構造を容易に拡張・変更可能です。