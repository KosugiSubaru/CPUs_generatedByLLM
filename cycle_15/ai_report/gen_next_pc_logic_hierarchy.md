サブモジュール `next_pc_logic` について、次サイクルの命令アドレス計算（PC+2, PC+imm, rs1+imm）と、分岐条件の判定ロジックを構造化した階層設計を提案します。

この設計では、加算処理と選択処理を明確に分離し、論理合成後の回路図で「どの命令がどのアドレス計算パスを使用しているか」を視覚的に把握できるようにします。

---

### 1. 階層構造一覧

| 階層レベル | ファイル名 | 役割 |
| :--- | :--- | :--- |
| **Level 0** | `next_pc_logic.v` | 最上位。計算ユニット、判定ユニット、セレクタを統合する。 |
| **Level 1** | `next_pc_logic_calc_unit.v` | アドレス計算を担当。PC+2, PC+imm, rs1+imm の3つの加算器を持つ。 |
| **Level 1** | `next_pc_logic_branch_eval.v` | 条件分岐（blt, bz）とフラグを突き合わせ、分岐成立を判定する。 |
| **Level 1** | `next_pc_logic_mux_4to1_16bit.v` | 計算結果から最終的な次アドレスを1つ選択する。 |
| **Level 2** | `next_pc_logic_adder_16bit.v` | 16ビットの構造化加算器。 |
| **Level 2** | `next_pc_logic_mux_2to1_16bit.v` | 16ビットの2入力セレクタ。 |
| **Level 3** | `next_pc_logic_full_adder.v` | 1ビットの全加算器。 |
| **Level 4** | `next_pc_logic_half_adder.v` | 1ビットの半加算器。 |

---

### 2. 各モジュールの役割と階層の詳細説明

#### Level 0: 統合
- **`next_pc_logic.v`**
  - **役割:** 現在のPC、即値、レジスタ値、制御信号、およびフラグを入力とし、次の命令アドレス（`o_next_pc`）を決定します。
  - **視覚的特徴:** 合成図において、左側に「計算ブロック」、中央に「分岐判定ブロック」、右側に「選択ブロック（MUX）」が並ぶデータフローが確認できます。

#### Level 1: 計算・判定・選択
- **`next_pc_logic_calc_unit.v`**
  - **構造化:** **`generate` 文**を使用して、3つの独立した加算器（`next_pc_logic_adder_16bit`）を並列配置します。
  - **教育的意図:** プログラムの進捗（+2）と相対ジャンプ（+imm）が、物理的に別の加算器によって並列に計算されている様子を可視化します。
- **`next_pc_logic_branch_eval.v`**
  - **役割:** `bz` なら `Z` フラグ、`blt` なら `N ^ V` フラグを参照し、条件が満たされているか（Taken）を判定します。
  - **教育的意図:** ISA定義の「条件判定式」がどのようなゲート回路として実装されているかを示します。
- **`next_pc_logic_mux_4to1_16bit.v`**
  - **構造化:** `next_pc_logic_mux_2to1_16bit` を3つツリー状に組み合わせて構築します。

#### Level 2, 3 & 4: 演算のボトムアップ
- **`next_pc_logic_adder_16bit.v`**
  - **構造:** `generate` 文を用いて `next_pc_logic_full_adder` を16個直列に接続します。
  - **内容:** リプルキャリー加算器のパタン構造を実現します。
- **`next_pc_logic_full_adder.v` / `half_adder.v`**
  - **内容:** 基本ゲートレベルからの加算論理。

---

### 3. パタン構造化（generate文）の適用イメージ

`next_pc_logic_calc_unit.v` 内で、必要な3つのアドレス候補を同時に計算する例です。

```verilog
// next_pc_logic_calc_unit.v 内のイメージ
genvar i;
generate
    for (i = 0; i < 3; i = i + 1) begin : gen_pc_adders
        wire [15:0] w_a, w_b;
        // i=0: PC+2, i=1: PC+imm, i=2: rs1+imm の入力を割り当て
        next_pc_logic_adder_16bit u_adder (
            .i_a(w_a), .i_b(w_b), .o_sum(w_results[i])
        );
    end
endgenerate
```

### この構成のメリット
1.  **PC相対アドレス計算の可視化:** 
    `PC + imm` と `rs1 + imm` のパスが独立していることが一目で分かります。
2.  **フラグと分岐の関係性:** 
    `Flag Register` から届いた信号が `branch_eval` モジュールで処理され、最終的なMUXの選択信号になるまでの論理の流れが回路図上で追跡しやすくなります。
3.  **拡張性:** 
    もし新しいジャンプ命令（例：`bne`など）を追加する場合も、`branch_eval` 内に判定論理を追加するだけで対応できる「関心の分離」を学べます。