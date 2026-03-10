`pc_calc`（PC計算ユニット）は、次に実行する命令のアドレス（Next PC）を決定する非常に重要なコンポーネントです。ISAで定義されている「相対分岐」「レジスタによる絶対ジャンプ」「条件判定」を視覚化するため、以下の階層構造を提案します。

### 提案する階層構造

| 階層レベル | ファイル名（モジュール名） | 役割 |
| :--- | :--- | :--- |
| **Level 1 (Top)** | `pc_calc.v` | 全体の統合。分岐条件とジャンプ命令に基づき、最終的な `Next PC` を選択する。 |
| **Level 2 (Logic)** | `pc_calc_branch_logic.v` | 分岐命令（BLT, BZ）と保存されたフラグ（Z, N, V）を照らし合わせ、分岐の成否を判定する。 |
| **Level 2 (Func)** | `pc_calc_adder_16bit.v` | 分岐先アドレス（Base + Imm）を計算するための専用加算器。1bit FAを16個接続。 |
| **Level 2 (Func)** | `pc_calc_mux_2to1_16bit.v` | 16ビット幅の2入力セレクタ。ベースアドレス（PCかrs1か）や、最終結果（PC+2かTargetか）の選択に使用。 |
| **Level 3 (Leaf)** | `pc_calc_full_adder.v` | 1ビットの全加算器。加算器を構成する最小単位。 |

---

### 各モジュールの役割と教育的意図

#### 1. pc_calc_branch_logic.v (Level 2)
- **役割**: ISA定義にある `N^V` (BLT用) や `Z` (BZ用) の論理演算を行い、「今、分岐すべきかどうか」を1ビットの信号で出力します。
- **教育的意図**: 分岐条件がALUフラグとどのように連動しているかを、独立したロジックブロックとして視覚化します。

#### 2. pc_calc_adder_16bit.v (Level 2)
- **役割**: 16ビットの加算を行います。`generate` 文を用いて `pc_calc_full_adder` を16個直列に接続します。
- **教育的意図**: 相対アドレス計算が物理的な加算器によって行われていることを示します。

#### 3. pc_calc_mux_2to1_16bit.v (Level 2)
- **役割**: セレクタ信号に応じて2つの16ビット入力から1つを選びます。
- **教育的意図**: 
    - **Base MUX**: `JALR` の時は `rs1`、それ以外の分岐/ジャンプ時は `PC` を加算器のベースにする切り替えを可視化。
    - **Result MUX**: 「条件不成立ならPC+2」「成立なら計算したTarget」というPC更新の流れを可視化。

#### 4. pc_calc_full_adder.v (Level 3)
- **役割**: 1ビット加算の最小単位です。

#### 5. pc_calc.v (Level 1)
- **役割**: 上記のモジュールを接続します。
    - `BaseAddr` = (JumpReg命令 ?) `rs1_data` : `current_pc`
    - `TargetAddr` = `BaseAddr` + `immediate`
    - `BranchTaken` = `branch_logic` の出力 | `jump`命令 | `jump_reg`命令
    - `NextPC` = (`BranchTaken` ?) `TargetAddr` : `pc_plus_2`

---

### 階層化・パターン構造化のメリット

1.  **分岐アルゴリズムの可視化**: 論理合成後の回路図で、「ベース選択」「アドレス加算」「条件による結果選択」という分岐・ジャンプの3ステップが物理的なブロックの並びとして表示されます。
2.  **ISAとの対応**: `branch_logic` モジュール内がISA定義の `behavior` 欄と直結するため、設計の意図が伝わりやすくなります。
3.  **モジュールの再利用**: `2to1_mux` や `full_adder` を別ファイルに分けることで、パターン構造化（同じ部品を組み合わせて大きな機能を作る手法）を強調できます。

### ファイルリストのプレビュー
- `pc_calc.v`
- `pc_calc_branch_logic.v`
- `pc_calc_adder_16bit.v`
- `pc_calc_mux_2to1_16bit.v`
- `pc_calc_full_adder.v`