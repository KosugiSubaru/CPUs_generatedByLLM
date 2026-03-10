「教育用CPU」という目的に合わせ、論理合成後の回路図（Schematic）で**「加算器」や「データ選択器（MUX）」がどのように構成されているか**を視覚的に追える階層構造を提案します。

`program_counter` サブモジュール内を、最小単位のビットセルから16ビット幅のコンポーネントへ、generate文を用いてボトムアップに構築します。

---

### 1. 提案する階層構造（ファイル構成）

「1ファイル1モジュール」の原則に従い、以下の7つのファイルで構成します。

| 階層レベル | ファイル名（モジュール名） | 役割の説明 |
| :--- | :--- | :--- |
| **Level 0** | `program_counter_full_adder.v` | 1ビットの全加算器。加算器の最小単位。 |
| **Level 0** | `program_counter_mux_2to1.v` | 1ビットの2入力セレクタ。MUXの最小単位。 |
| **Level 1** | `program_counter_adder_16bit.v` | generate文を用い、Level 0の全加算器を16個並列接続した16ビット加算器。 |
| **Level 1** | `program_counter_mux_2to1_16bit.v` | generate文を用い、Level 0のMUXを16個並列接続した16ビット幅セレクタ。 |
| **Level 2** | `program_counter_register.v` | 16ビットのD-FF。リセット時に`0`（または初期アドレス）に戻る機能を持つ。 |
| **Level 2** | `program_counter_logic.v` | 次のPC候補（PC+2, PC+imm, rs1+imm）を計算・選択する組合せ回路。 |
| **Level 3** | `program_counter.v` | **サブモジュールのトップ。** レジスタとロジックを接続し、PCを更新する。 |

---

### 2. 各サブモジュールの詳細とパタン構造化の定義

#### Level 0: 最小プリミティブ
*   **`program_counter_full_adder`**
    *   役割：`(A, B, CarryIn)` を入力し、`(Sum, CarryOut)` を出力する。
    *   視覚化の効果：回路図上で最も小さい加算の箱として表現される。
*   **`program_counter_mux_2to1`**
    *   役割：選択信号 `S` に基づき `D0` または `D1` を出力する。

#### Level 1: Nビット幅への拡張（generate文の活用）
*   **`program_counter_adder_16bit`**
    *   構造：`program_counter_full_adder` を `generate` 文で16回インスタンス化。
    *   パタン：下位ビットの `CarryOut` を上位ビットの `CarryIn` へ連鎖（Ripple Carry型）。
*   **`program_counter_mux_2to1_16bit`**
    *   構造：`program_counter_mux_2to1` を `generate` 文で16回インスタンス化。
    *   視覚化の効果：バス幅分のスイッチが並んでいる様子が回路図に反映される。

#### Level 2: 機能ブロック
*   **`program_counter_register`**
    *   役割：`i_clk` の立ち上がりで `i_next_pc` を `o_pc_now` に反映させる。
*   **`program_counter_logic`**
    *   構造：
        1.  `adder_16bit` を3つ使用し、`PC+2`, `PC+imm`, `rs1+imm` を同時計算。
        2.  `mux_2to1_16bit` を階層的に（木構造で）組み合わせ、制御信号に応じて1つの宛先を選択。
    *   視覚化の効果：**「分岐先アドレスが並列に計算され、最後に選択されている」** というシングルサイクルの特徴が視覚化される。

#### Level 3: program_counter (Top of Submodule)
*   役割：`program_counter_register` と `program_counter_logic` を接続。
*   入出力インターフェース：
    *   `input  i_clk, i_rst_n`
    *   `input  [1:0] i_pc_sel` (00:通常, 01:分岐/JAL, 10:JALR)
    *   `input  [15:0] i_imm, i_rs1_data`
    *   `output [15:0] o_pc_now, o_pc_next_seq` (JAL用戻りアドレスPC+2)

---

### 3. この構成による教育的メリット

1.  **抽象化の階段**: 「1ビットの計算」→「16ビットの計算」→「アドレスの選択」→「PCレジスタの更新」という、ハードウェア設計のボトムアップな流れをファイル構成そのもので示せます。
2.  **回路図の可読性**: 論理合成ツール（Vivado, Quartus, Yosys等）で回路図を開いた際、`program_counter_logic` の中に3つの大きな `adder_16bit` ブロックが見えるため、ISAの `PC<-PC+imm` や `PC<-rs1+imm` という振る舞いがどの回路に対応しているか一目瞭然となります。
3.  **MUXの理解**: 単なる `case` 文による記述ではなく、`2to1_16bit_mux` を階層化して使用することで、多入力セレクタがハードウェア的にどう構成されるかを明示できます。