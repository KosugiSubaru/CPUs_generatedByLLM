`register_file`は、CPU内で最も「同じ構造の繰り返し」が多い部分です。教育用として、16個のレジスタが整列している様子や、マルチプレクサ（MUX）によってデータが選ばれる仕組みを視覚化するため、以下の階層構造を提案します。

特に、**「R0は常に0を返す」というISAの制約**を回路レベルで視覚化することに重点を置いています。

### 提案する階層構造

| 階層レベル | ファイル名（モジュール名） | 役割 |
| :--- | :--- | :--- |
| **Level 1 (Top)** | `register_file.v` | 全体の統合。書き込みデコーダ、レジスタ配列、読み出しMUXを接続する。 |
| **Level 2 (Func)** | `register_file_decoder_4to16.v` | `rd`アドレスを16本の書き込み有効信号（Enable）に変換する。 |
| **Level 2 (Func)** | `register_file_array.v` | 16個の16bitレジスタ（R0～R15）の実体。R0が定数0であることを示す。 |
| **Level 2 (Func)** | `register_file_mux_16to1.v` | 16本のバスから1本を選択する。4to1 MUXを4+1個組み合わせて構成。 |
| **Level 3 (Func)** | `register_file_reg_16bit.v` | 16bit幅のレジスタ1個分。1bit D-FFを16個並列化したもの。 |
| **Level 3 (Leaf)** | `register_file_mux_4to1.v` | 4入力1出力の16bit幅MUX。MUX階層化の基本単位。 |
| **Level 4 (Leaf)** | `register_file_dff_en.v` | 書き込み有効（Enable）信号付きの1bit D-フリップフロップ。 |

---

### 各モジュールの役割と教育的意図

#### 1. register_file_decoder_4to16.v (Level 2)
- **役割**: 書き込み先アドレス（`rd`）をデコードし、特定のレジスタだけの「書き込みスイッチ」をONにする信号を作ります。

#### 2. register_file_array.v (Level 2)
- **役割**: `generate`文を用いて `register_file_reg_16bit` を15個配置します。
- **教育的意図**: **R0だけはレジスタを配置せず `16'h0000` を定数出力**させることで、ISAの「ゼロレジスタ」が物理的な配線としてどう実現されているかを視覚的に示します。

#### 3. register_file_mux_16to1.v (Level 2)
- **役割**: `register_file_mux_4to1` を階層的に組み合わせて、16個のレジスタ出力から1つを抽出します。
- **教育的意図**: 大規模なMUXが小さなMUXのツリー構造でできていることを示し、回路図の複雑さを軽減します。

#### 4. register_file_reg_16bit.v (Level 3)
- **役割**: 16ビットのデータをクロック同期で保存する単位ブロックです。

#### 5. register_file_mux_4to1.v (Level 3)
- **役割**: セレクタ信号（2bit）に基づき、4つの16bit入力から1つを選びます。

#### 6. register_file_dff_en.v (Level 4)
- **役割**: 回路の最小単位です。`Enable`が1のときだけ、クロックの立ち上がりで入力を記憶します。

---

### 階層化・パターン構造化のメリット

1.  **「ゼロレジスタ」の可視化**: R0がただの「0への配線」であり、R1-R15が「記憶素子の塊」である対比が、回路図上のブロックの有無として現れます。
2.  **配線の整理**: 16本の16bitバス（計256本）という膨大な配線を、`array`モジュールや階層化された`mux`の中に閉じ込めることで、最上位の `register_file.v` をスッキリと保ちます。
3.  **書き込みと読み出しの分離**: 「書き込みはクロック同期（デコーダ経由）」「読み出しは非同期（MUX経由）」というCPUの基本原理が、独立したブロックとして分かれているため理解しやすくなります。

### ファイルリストのプレビュー
- `register_file.v`
- `register_file_decoder_4to16.v`
- `register_file_array.v`
- `register_file_mux_16to1.v`
- `register_file_reg_16bit.v`
- `register_file_mux_4to1.v`
- `register_file_dff_en.v`