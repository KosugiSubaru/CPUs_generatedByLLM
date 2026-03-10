プログラムカウンタ（`program_counter`）は、単なる「レジスタ」ではなく、次の方針で階層化・パターン構造化を行います。

### 階層化の設計思想
1.  **視覚的理解**: 合成後のRTL Viewerで「値を保持するブロック（Register）」「計算するブロック（Adder）」「道筋を選ぶブロック（MUX）」が明確に分かれて見えるようにします。
2.  **パターン構造化**: 16ビットの演算や保持を、1ビットの基本素子（D-FF、Full Adder、MUX2）から`generate`文を用いて組み上げる構造にします。これにより、ビット幅が拡張された場合でも対応可能な、再利用性の高い設計パターンを提示します。

---

### 階層レベルと各ファイルの役割

| レベル | ファイル名（モジュール名） | 役割 |
| :--- | :--- | :--- |
| **L1** | `program_counter_top.v` | **最上位結合**: 以下のサブモジュールを接続し、PCの更新ロジック全体を構築する。 |
| **L2** | `program_counter_register_16bit.v` | **状態保持**: クロックに同期して16ビットの値を保持・出力する。 |
| **L2** | `program_counter_adder_16bit.v` | **アドレス加算**: PC+2、PC+imm、rs1+imm 等の計算を行う汎用加算器。 |
| **L2** | `program_counter_mux4_16bit.v` | **次PC選択**: 4つの候補（+2, 分岐, ジャンプ, リセット）から1つを選択する。 |
| **L3** | `program_counter_dff.v` | **最小単位(保持)**: 1ビットのD型フリップフロップ。 |
| **L3** | `program_counter_full_adder.v` | **最小単位(演算)**: 1ビットの全加算器。 |
| **L3** | `program_counter_mux2.v` | **最小単位(選択)**: 1ビットの2入力セレクタ。 |

---

### 各サブモジュールの詳細説明

#### 1. `program_counter_top.v` (Level 1)
CPU本体から「どの命令か（分岐かジャンプか）」や「即値」を受け取り、PCの値を更新する回路の親モジュールです。
- **内部接続**: `adder`を2つ（PC+2用、PC/RS1+imm用）と、`register`、`mux4`を接続します。
- **視覚的効果**: 合成後、PCのループ構造（出力が計算機を通って入力に戻る様子）が明確になります。

#### 2. `program_counter_register_16bit.v` (Level 2)
16ビットの値を保持します。
- **パターン構造**: `generate`文を用いて `program_counter_dff` を16個並列にインスタンス化します。

#### 3. `program_counter_adder_16bit.v` (Level 2)
16ビットの加算器です。PC+2の計算や、相対分岐の計算に使用します。
- **パターン構造**: `generate`文を用いて `program_counter_full_adder` を16個直列（キャリー伝搬）に接続してインスタンス化します。

#### 4. `program_counter_mux4_16bit.v` (Level 2)
次のPCを以下の4つの状態から選択します。
- `00`: PC + 2 (通常のインクリメント)
- `01`: PC + imm (相対分岐：`blt`, `bz`, `jal`)
- `10`: rs1 + imm (絶対分岐：`jalr`)
- `11`: 0 (リセット/初期化用)
- **パターン構造**: `generate`文を用いて `program_counter_mux2` をビット分組み合わせ、4入力1出力のセレクタを構築します。

#### 5. `program_counter_dff.v` (Level 3)
クロックの立ち上がりで入力を出力に反映する最小単位です。教育用として、リセット信号付きで定義します。

#### 6. `program_counter_full_adder.v` (Level 3)
1ビットの全加算器です。
- 視覚化のため、論理ゲート（XOR, AND, OR）の組み合わせ、あるいは算術演算子によって定義します。

#### 7. `program_counter_mux2.v` (Level 3)
2つの入力から1つを選ぶ、1ビット幅の最小セレクタです。

---

### 提案するサブモジュールリスト

submodules:
program_counter_top: 各モジュールを統合し、次サイクルのPC値を決定・保持するトップレベル。
program_counter_register_16bit: generate文により1ビットD-FFを16個並べた、16ビット状態保持レジスタ。
program_counter_adder_16bit: generate文により1ビット全加算器を16個接続した、アドレス計算用加算器。
program_counter_mux4_16bit: generate文により1ビット2to1 MUXを組み合わせて構築した、4入力16ビットセレクタ。
program_counter_dff: 1ビットの値をクロック同期で保持する、PCレジスタの最小構成要素。
program_counter_full_adder: 1ビットの加算とキャリー出力を担当する、加算器の最小構成要素。
program_counter_mux2: 選択信号に応じて2つの入力から1つを選択する、セレクタの最小構成要素。