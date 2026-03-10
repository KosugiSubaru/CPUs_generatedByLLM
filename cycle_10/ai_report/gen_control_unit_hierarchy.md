`control_unit`は、命令のOpcode（4bit）を解読し、CPU各部のセレクタや書き込み許可信号を制御する「デコーダ回路」の集合体です。教育的な視点から、**「4bitの符号がどのように16本の命令有効線になり、それがどのように制御信号へ変換されるか」**を視覚化する階層構造を提案します。

### 提案する階層構造

| 階層レベル | ファイル名（モジュール名） | 役割 |
| :--- | :--- | :--- |
| **Level 1 (Top)** | `control_unit.v` | 全体の統合。Opcodeを入力し、各制御信号を出力する。 |
| **Level 2 (Func)** | `control_unit_decoder_4to16.v` | 4bitのOpcodeを、16本の「命令識別信号（One-hot）」に変換する。 |
| **Level 2 (Func)** | `control_unit_gate_matrix.v` | 16本の命令識別信号を束ねて、`reg_write`等の具体的な制御信号を生成する。 |
| **Level 3 (Leaf)** | `control_unit_decoder_2to4.v` | デコーダの基本単位。2bit入力から4bitの有効信号を作る。 |

---

### 各ファイルの役割と構造

#### 1. control_unit_decoder_2to4.v (Level 3)
デコーダの最小構成単位です。
- **役割**: 2ビットの入力をデコードし、4ビットのうち1本だけをハイ（1）にします。

#### 2. control_unit_decoder_4to16.v (Level 2)
`generate`文を活用したパターン構造化の核となるモジュールです。
- **役割**: `control_unit_decoder_2to4` を 4つ並列に配置し、上位2bitでどのデコーダを有効にするか（イネーブル制御）を決定することで、4bit→16bitデコーダを構成します。
- **視覚的効果**: 論理合成後の回路図で、4つの小さなブロックが整列して1つの大きなデコーダを形成している様子が見えます。

#### 3. control_unit_gate_matrix.v (Level 2)
制御信号生成の「ロジック・マトリクス」です。
- **役割**: 16本の命令有効信号（`inst_add`, `inst_sub`, `inst_load`等）を入力とし、各制御信号を生成します。
- **実装例**: 
    - `assign o_reg_write = inst_add | inst_sub | inst_and | ... (書き込みが発生する命令をすべてOR接続)`
- **視覚的効果**: 「どの命令がどの信号を有効にするか」が、回路図上の大きなORゲートの束として視覚的に理解できます。

#### 4. control_unit.v (Level 1)
デコーダとマトリクスを接続するトップです。
- **ポート定義の例**:
    - 入力: `i_opcode[3:0]`
    - 出力: `o_alu_op`, `o_reg_write`, `o_mem_write`, `o_alu_src`, `o_result_src`, `o_branch`, `o_jump` 等。

---

### 階層化とパターン構造化のメリット

1.  **ISAとの対応**: `gate_matrix` 内の `assign` 文が、そのままISA仕様書の表（どの命令でどの信号が1になるか）と1対1で対応するため、学習者がコードと仕様を照らし合わせやすくなります。
2.  **回路の対称性**: `generate` 文でデコーダを作ることで、回路図上にグリッド状の規則正しいパターンが現れ、デジタル回路の美しさと合理性を視覚的に示せます。
3.  **デバッグの容易性**: 16本の命令有効信号（内部ワイヤ）をデバッグポートに出すことで、「今、CPUがどの命令を実行していると認識しているか」を波形上で容易に確認できます。

### ファイルリストのプレビュー
- `control_unit.v`
- `control_unit_decoder_4to16.v`
- `control_unit_gate_matrix.v`
- `control_unit_decoder_2to4.v`