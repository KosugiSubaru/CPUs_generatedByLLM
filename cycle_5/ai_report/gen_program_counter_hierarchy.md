教育用シングルサイクルCPUにおいて、プログラムカウンタ（PC）周りは「次に実行する命令のアドレスをどう決定するか」というCPUの意志決定プロセスを可視化する重要なパーツです。

ご提示いただいたISAの挙動（通常歩進、相対分岐、レジスタ間接ジャンプ）に基づき、以下の階層構造とファイル構成を提案します。

---

### 1. 階層構造の概要

PCユニットを「状態（レジスタ）」「演算（アダー）」「選択（マルチプレクサ）」の3つの要素に分解し、さらにビットレベルでのパターン構造化（generate文の活用）を行います。

- **Level 1: Top Module**
    - `program_counter_top`: ユニット全体をまとめ、外部（imemやControl Unit）と接続。
- **Level 2: Intermediate Modules**
    - `program_counter_register_nbit`: 16ビットの同期レジスタ。
    - `program_counter_adder_nbit`: 16ビットの加算器（PC+2用や分岐先計算用）。
    - `program_counter_mux_next`: 次のPC値を決定するセレクタ。
- **Level 3: Leaf Modules (Pattern Units)**
    - `program_counter_register_1bit`: 1ビットのD-FF。
    - `program_counter_adder_1bit`: 1ビットの全加算器（Full Adder）。

---

### 2. サブモジュールのリストと役割

各ファイルに1モジュールのみを定義します。

| ファイル名 / モジュール名 | 階層 | 役割の説明 |
| :--- | :---: | :--- |
| **program_counter_top.v** | 1 | **最上位構成:** 下位モジュールを結合し、現在のPC出力と次PCの更新ロジックを統合する。 |
| **program_counter_register_nbit.v** | 2 | **16bitレジスタ:** `generate`文を用いて1bit FFを16個並べ、クロック同期でPC値を保持する。 |
| **program_counter_register_1bit.v** | 3 | **1bit FF:** 非同期リセット付きのD-フリップフロップ。レジスタの最小単位。 |
| **program_counter_adder_nbit.v** | 2 | **16bit加算器:** `generate`文を用いて1bit全加算器を16個接続（Ripple Carry形式）。PC+2やPC+immの計算に使用。 |
| **program_counter_adder_1bit.v** | 3 | **1bit全加算器:** 1ビットの加算とキャリー出力を担当する演算の最小単位。 |
| **program_counter_mux_next.v** | 2 | **次アドレス選択:** 制御信号に基づき「PC+2」「PC+imm(相対)」「rs1+imm(絶対)」の中から次のPC値を選択する。 |

---

### 3. パターン構造化の具体例（実装イメージ）

論理合成後の回路図で「同じ構造の並び」を視覚化するため、以下のように`generate`文を使用します。

#### 例：`program_counter_register_nbit.v` 内での展開
```verilog
// 1bitのFFを16個並べて16bitレジスタを構成
genvar i;
generate
    for (i = 0; i < 16; i = i + 1) begin : gen_pc_reg
        program_counter_register_1bit u_reg_bit (
            .i_clk   (i_clk),
            .i_rst_n (i_rst_n),
            .i_d     (w_next_pc[i]),
            .o_q     (o_current_pc[i])
        );
    end
endgenerate
```

#### 例：`program_counter_adder_nbit.v` 内での展開
```verilog
// 1bit全加算器を16個繋いで16bit加算器を構成
genvar i;
wire [16:0] carry;
assign carry[0] = 1'b0; // キャリーイン初期値
generate
    for (i = 0; i < 16; i = i + 1) begin : gen_pc_adder
        program_counter_adder_1bit u_adder_bit (
            .i_a     (i_a[i]),
            .i_b     (i_b[i]),
            .i_cin   (carry[i]),
            .o_sum   (o_sum[i]),
            .o_cout  (carry[i+1])
        );
    end
endgenerate
```

---

### 4. 教育的利点

1.  **回路図の直感性:** 合成後の回路図を開くと、まず大きなブロック（Top）があり、その中に16個の小さな四角（1bitモジュール）が規則正しく並んでいる様子が見えます。これは「データ幅が16ビットである」ことを物理的に理解する助けになります。
2.  **MUXの分離:** 「次のPCを何にするか」というロジックを `program_counter_mux_next` として独立させることで、条件分岐（`bz`, `blt`）やジャンプ（`jal`, `jalr`）の際に、どのパスが選択されるかをデバッグ信号で追いやすくなります。
3.  **拡張性:** 将来的にトラップや例外処理を追加する場合も、MUXの入力を増やすだけで対応できるため、アーキテクチャの進化を教えやすくなります。