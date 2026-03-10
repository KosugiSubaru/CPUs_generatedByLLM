サブモジュール「pc_reg」および、それに関連するPC更新ロジック（次アドレス選択）の階層化とパターン構造化を提案します。

教育用として「1ビットの要素が組み合わさって16ビットの構造を作る」様子、および「単純な選択肢が組み合わさって複雑な条件分岐を作る」様子を視覚化することを目的としています。

---

### 1. 階層構造の定義

PCユニットを、**「保持（Storage）」**と**「選択（Selection）」**の2つのパターンに分け、それぞれを1ビット単位から階層化します。

| 階層レベル | ファイル名 | 役割 |
| :--- | :--- | :--- |
| **Level 3 (Leaf)** | `pc_reg_bit.v` | 1ビットのD-FF（非同期リセット付き）。最下位の記憶素子。 |
| | `pc_reg_mux2_1bit.v` | 1ビットの2入力MUX。基本の選択素子。 |
| **Level 2 (Structure)** | `pc_reg_mux4_1bit.v` | `pc_reg_mux2_1bit`を3つ組み合わせ、1ビットの4入力MUXを構成。 |
| **Level 1 (Top-slice)** | `pc_reg.v` | `pc_reg_bit`を16個並列配置し、16ビットのレジスタを構成。 |
| | `pc_reg_mux4_16bit.v` | `pc_reg_mux4_1bit`を16個並列配置し、16ビットの4入力MUXを構成。 |

---

### 2. 各モジュールの実装と解説

#### (1) pc_reg_bit.v
1ビットを保持する最小単位です。
```verilog
module pc_reg_bit (
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

#### (2) pc_reg_mux2_1bit.v
2つの入力から1つを選ぶ、MUXの最小単位です。
```verilog
module pc_reg_mux2_1bit (
    input  wire i_sel,
    input  wire i_d0,
    input  wire i_d1,
    output wire o_data
);
    assign o_data = i_sel ? i_d1 : i_d0;
endmodule
```

#### (3) pc_reg_mux4_1bit.v
`pc_reg_mux2_1bit`を組み合わせ、4つの入力（PC+2, 分岐先, JALR先など）を扱えるようにします。これは「ハーフアダーを組み合わせてフルアダーを作る」設計思想に対応します。
```verilog
module pc_reg_mux4_1bit (
    input  wire [1:0] i_sel,
    input  wire i_d0, i_d1, i_d2, i_d3,
    output wire o_data
);
    wire w_mux_l, w_mux_h;

    // 階層化呼び出し: 2入力MUXを組み合わせて4入力MUXを構成
    pc_reg_mux2_1bit u_mux_l (.i_sel(i_sel[0]), .i_d0(i_d0), .i_d1(i_d1), .o_data(w_mux_l));
    pc_reg_mux2_1bit u_mux_h (.i_sel(i_sel[0]), .i_d0(i_d2), .i_d1(i_d3), .o_data(w_mux_h));
    pc_reg_mux2_1bit u_mux_out(.i_sel(i_sel[1]), .i_d0(w_mux_l), .i_d1(w_mux_h), .o_data(o_data));

endmodule
```

#### (4) pc_reg.v
`generate`文を用い、1ビット素子から16ビットレジスタを構造化します。
```verilog
module pc_reg (
    input  wire        i_clk,
    input  wire        i_rst_n,
    input  wire [15:0] i_next_pc,
    output wire [15:0] o_current_pc
);
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_pc_bits
            pc_reg_bit u_bit (
                .i_clk   (i_clk),
                .i_rst_n (i_rst_n),
                .i_d     (i_next_pc[i]),
                .o_q     (o_current_pc[i])
            );
        end
    endgenerate
endmodule
```

#### (5) pc_reg_mux4_16bit.v
16ビット幅の4入力MUXです。`i_sel`信号に従い、`PC+2`、`PC+imm`（Branch/JAL）、`rs1+imm`（JALR）を選択する際に使用します。
```verilog
module pc_reg_mux4_16bit (
    input  wire [1:0]  i_sel,
    input  wire [15:0] i_d0, i_d1, i_d2, i_d3,
    output wire [15:0] o_data
);
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_mux_array
            pc_reg_mux4_1bit u_mux4 (
                .i_sel  (i_sel),
                .i_d0   (i_d0[i]),
                .i_d1   (i_d1[i]),
                .i_d2   (i_d2[i]),
                .i_d3   (i_d3[i]),
                .o_data (o_data[i])
            );
        end
    endgenerate
endmodule
```

---

### 3. この階層化によるメリット

1.  **視覚的理解（回路図）**:
    論理合成ツール（VivadoやQuartusなど）でSchematicを表示した際、16個の小さなブロックが並んでいる様子が見え、ビット幅という概念が物理的に理解しやすくなります。
2.  **ISAとの対応**:
    PCの更新ルール（通常、条件分岐、絶対分岐）をMUXの入力切り替えとして視覚化できます。
    - `00`: PC+2 (通常)
    - `01`: PC+imm (bz, blt, jal)
    - `10`: rs1+imm (jalr)
3.  **拡張性**:
    今後、例外処理や割り込みによるPCのジャンプ先を追加したい場合、MUXの入力を増やす（Level 2の改造）だけで、他のビット幅ロジックに影響を与えず対応可能です。