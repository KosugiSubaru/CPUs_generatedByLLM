教育用シングルサイクルCPUにおいて、プログラムカウンタ（PC）は「次に実行するアドレスを管理する」極めて重要な役割を持ちます。ISAの仕様（相対分岐、絶対ジャンプ、PC+2）を視覚的に理解しやすくするため、**ビットスライス構造**を用いたパタン構造化を提案します。

### 1. 階層構造（Hierarchy）の定義

回路図で「箱（モジュール）」として認識できるよう、以下の3つのレベルで構成します。

*   **Level 0 (Primitive):** 最小単位（1bit DFF、1bit 加算器、1bit MUX）
*   **Level 1 (Structural):** Level 0を`generate`文で連結した16bit構造体
*   **Level 2 (Top/Logic):** 16bit構造体を組み合わせてPCの動作を実現する制御層

---

### 2. ファイル構成と役割

1ファイル1モジュールの原則に基づき、以下の7つのファイルで構成します。

| ファイル名（モジュール名） | 役割説明 | 階層レベル |
| :--- | :--- | :--- |
| `program_counter_dff.v` | リセット付1bit D-フリップフロップ。PCの最小記憶単位。 | Level 0 |
| `program_counter_full_adder.v` | 1bit フルアダー。加算処理の最小単位。 | Level 0 |
| `program_counter_mux2.v` | 1bit 2-to-1 セレクタ。信号選択の最小単位。 | Level 0 |
| `program_counter_reg_16bit.v` | `dff`を16個`generate`で並べ、16bitレジスタを構成。 | Level 1 |
| `program_counter_adder_16bit.v` | `full_adder`を16個連結し、16bit加算器を構成。 | Level 1 |
| `program_counter_mux2_16bit.v` | `mux2`を16個並べ、16bit幅のデータ切替器を構成。 | Level 1 |
| `program_counter.v` | 上記を組み合わせ、PC+2、分岐、ジャンプのロジックを構成。 | Level 2 |

---

### 3. 各モジュールの実装イメージとパタン構造化

#### Level 1: `generate`文による構造化の例
`program_counter_adder_16bit.v` では、以下のように1bitのフルアダーを連結します。これにより、回路図上で「1bitの積み重ねで16bit演算が行われている」様子が視覚化されます。

```verilog
// program_counter_adder_16bit.v 内のイメージ
genvar i;
generate
    for (i = 0; i < 16; i = i + 1) begin : adder_gen
        program_counter_full_adder u_fa (
            .i_a    (i_a[i]),
            .i_b    (i_b[i]),
            .i_cin  (i == 0 ? 1'b0 : w_carry[i-1]),
            .o_sum  (o_sum[i]),
            .o_cout (w_carry[i])
        );
    end
endgenerate
```

#### Level 2: `program_counter.v` での相互作用
このトップレベルでは、ISAの動作（PC+2、Branch、JAL、JALR）をデータパスとして視覚化します。

1.  **PCレジスタ:** 現在のアドレスを保持。
2.  **次アドレス計算器 (Adder A):** 常に `PC + 2` を計算。
3.  **分岐/ジャンプ計算器 (Adder B):** `Base + Offset` を計算。
    *   `Base`: `jalr`なら`rs1`、それ以外（`blt`, `bz`, `jal`）なら`PC`を選択。
    *   `Offset`: デコーダが生成した符号拡張済み即値。
4.  **最終選択 (MUX):** 分岐条件成立時やジャンプ命令時は `Adder B` の結果を、通常時は `Adder A` の結果を選択して、PCレジスタに入力する。

---

### 4. 視覚的理解を助ける工夫

論理合成後の回路図（RTL Viewer等）で見た際、以下のような「ブロックの塊」が見えるようになります。

*   **PC本体:** 16個のDFFが並ぶ大きな箱。
*   **2つの加算器:** PCを歩進させるための専用アダーと、ジャンプ先を計算する汎用アダーが並列に存在。
*   **セレクタ群:** 
    *   「`PC` か `rs1` か」を選ぶ箱（JALRの理解）
    *   「`通常` か `ジャンプ/分岐` か」を選ぶ箱（制御フローの理解）

この「物理的な箱のつながり」を意識した階層化により、学生は「なぜプログラムが順番に実行されるのか」「なぜ分岐命令はジャンプ先を計算する必要があるのか」を、コードではなく**回路の形として直感的に理解**することが可能になります。