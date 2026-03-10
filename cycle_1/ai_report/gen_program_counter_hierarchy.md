「program_counter」モジュールを、教育的な視覚化と構造化を両立させた階層構造で提案します。

16ビットのアドレス計算と保持を行うため、**「1ビット単位の部品をgenerate文で並列化する」**というパターン構造化を採用します。これにより、回路図（Netlistビューア）で見た際に、16個の同じ構造が整然と並ぶ様子が確認でき、ビット幅と回路の関係を直感的に理解できるようになります。

---

### 1. 階層構造とファイル一覧

| 階層レベル | ファイル名 | 役割 |
| :--- | :--- | :--- |
| **Level 0 (基本素子)** | `program_counter_bit_register.v` | 1ビット分のデータ保持を行うD-FF。 |
| | `program_counter_mux_4to1_1bit.v` | 次のPC値を選択する1ビット幅の4入力セレクタ。 |
| | `program_counter_half_adder.v` | 加算器の最小単位。 |
| | `program_counter_full_adder.v` | 半加算器2つを組み合わせた全加算器。 |
| **Level 1 (構造化ユニット)** | `program_counter_nbit_register.v` | `generate`を用いて16ビット幅にしたレジスタ。 |
| | `program_counter_nbit_mux.v` | `generate`を用いて16ビット幅にしたセレクタ。 |
| | `program_counter_adder_16bit.v` | `generate`を用いて全加算器を連結した16ビット加算器。 |
| **Level 2 (サブモジュール・トップ)** | `program_counter.v` | 上記を組み合わせ、PCの保持と次のアドレス計算を行う。 |

---

### 2. 各モジュールの詳細と実装イメージ

#### Level 0: 基本素子
最小単位のロジックを定義します。

*   **program\_counter\_bit\_register.v**
    *   `input clk, rst_n, i_d`, `output o_q`
    *   リセット付きの1ビットD-FFです。
*   **program\_counter_mux_4to1_1bit.v**
    *   `input [1:0] sel`, `input [3:0] i_data`, `output o_data`
    *   「PC+2」「Branch/JAL先」「JALR先」などを選択する1ビット回路です。
*   **program\_counter_half_adder.v / full_adder.v**
    *   加算の論理ゲートを明示的に記述します。

#### Level 1: パターン構造化（generate文の活用）
ビット幅を拡張する層です。回路図上で16個のインスタンスが並びます。

*   **program\_counter_nbit_register.v**
    *   **実装**: `generate`文で `program_counter_bit_register` を16回呼び出します。
    *   **教育効果**: レジスタが1ビットずつのフリップフロップの集合であることを視覚化します。
*   **program\_counter_adder_16bit.v**
    *   **実装**: `generate`文で `program_counter_full_adder` を16個直列（リップルキャリー）に接続します。
    *   **教育効果**: 16ビットの加算がどのように下位ビットからのキャリー（繰り上がり）で構成されるかを示します。

#### Level 2: サブモジュール・トップ
これらの部品を統合して、PC制御の全体像を作ります。

*   **program\_counter.v**
    *   **内部構成**:
        1.  **PCレジスタ**: 現在のアドレスを保持。
        2.  **Adder A (PC+2用)**: `program_counter_adder_16bit` を使用。
        3.  **Adder B (Offset計算用)**: `(PC or rs1) + Imm` を計算。
        4.  **Next PC MUX**: `program_counter_nbit_mux` を使用。
    *   **選択ロジック**:
        *   通常時：`PC + 2`
        *   `blt/bz` 成立時 ＆ `jal`：`PC + Imm`
        *   `jalr`：`rs1 + Imm`

---

### 3. モジュール間の相互作用（情報の流れ）

1.  **保持 (Register)**:
    `program_counter_nbit_register` が現在のPC値を保持し、`o_addr_to_imem` として出力します。
2.  **計算 (Adders)**:
    *   一つ目の16bit加算器が `PC + 2` を計算します。
    *   二つ目の16bit加算器が「分岐先アドレス」を計算します。ISAに基づき、ベース（PCまたはrs1）に符号拡張された即値（Imm）を足します。
3.  **選択 (MUX)**:
    CPUトップのデコーダーおよびフラグ判定結果（`branch_taken`信号など）を受け取り、次のPCを決定します。
4.  **更新**:
    クロックの立ち上がりで、選択された「Next PC」がレジスタに格納されます。

### この設計のメリット
*   **視覚的理解**: 合成後のツールで、16個の全加算器が鎖のように繋がっている様子や、16個のMUXが並んでいる様子が綺麗に表示されます。
*   **ISAとの対応**: 「なぜPC+2なのか」「なぜJALRはrs1をベースにするのか」というISAの挙動が、そのまま物理的な加算器とセレクタの配線として現れます。
*   **デバッグ性**: 各ビットの状態を個別に観測できるため、教育時の説明が容易になります。