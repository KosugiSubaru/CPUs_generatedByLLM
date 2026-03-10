教育用シングルサイクルCPUにおいて、命令デコーダは「16ビットのバイナリ（機械語）が、どのような意味を持つ制御信号に変換されるか」を可視化する非常に重要な部位です。

このデコーダを「命令の特定（Opcodeの検知）」と「制御信号へのマッピング」の2段階に分離し、論理合成後の回路図で**命令ごとのラインが整然と並ぶ**ような階層構造を提案します。

### 1. 階層構造（Hierarchy）の定義

回路図で「どの命令が実行されているか」が1本の信号線として浮かび上がるよう、以下のレベルで構成します。

*   **Level 0 (Primitive):** 最小単位（4bit比較器）。
*   **Level 1 (Structural):** 命令の特定（Opcode Bank）と、フィールド抽出（Field Logic）。
*   **Level 2 (Top/Logic):** 特定された命令を制御信号（ALU制御、書き込み許可等）に変換する統合層。

---

### 2. ファイル構成と役割

1ファイル1モジュールの原則に基づき、以下の5つのファイルで構成します。

| ファイル名（モジュール名） | 役割説明 | 階層レベル |
| :--- | :--- | :--- |
| `instruction_decoder_match_4bit.v` | 4bit入力が特定の定数と一致するか判定する（1命令の特定）。 | Level 0 |
| `instruction_decoder_opcode_bank.v` | `match_4bit`を16個並列に`generate`し、16種類の命令のうちどれが有効かを16本の独立した線で出力する。 | Level 1 |
| `instruction_decoder_field_logic.v` | 命令のビットフィールドから `rd`, `rs1`, `rs2` のアドレスを抽出する。`store`命令等の例外的な配置もここで処理する。 | Level 1 |
| `instruction_decoder_control_logic.v` | 16本の命令有効フラグをまとめ、`RegWrite`, `MemWrite`, `ALU_Op` などの具体的な制御信号を生成する。 | Level 1 |
| `instruction_decoder.v` | 上記を組み合わせ、命令メモリからの16bit入力を全ての制御信号へと変換するトップモジュール。 | Level 2 |

---

### 3. パタン構造化と視覚化のポイント

#### 命令の可視化 (`opcode_bank`)
`generate`文を用いて、全ての命令(0000〜1111)に対応するデコード信号を生成します。
回路図上では、**「16個の小さな判定ブロックが縦に並び、実行中の命令に対応する1本の信号線だけが光る（Highになる）」**様子が視覚的に表現されます。これは学生が「今、Addition命令が選ばれた」と理解する助けになります。

```verilog
// instruction_decoder_opcode_bank.v 内のイメージ
genvar i;
generate
    for (i = 0; i < 16; i = i + 1) begin : gen_match
        instruction_decoder_match_4bit u_match (
            .i_opcode (i_instr_op),
            .i_target (i[3:0]),
            .o_match  (w_match_lines[i]) // 16本の命令有効信号
        );
    end
endgenerate
```

#### 制御のマッピング (`control_logic`)
各制御信号（例：`RegWrite`）が、どの命令の時に有効になるかをORゲートの集まりとして構成します。
回路図上では、**「Additionの線、Subtractionの線、...、Loadの線がORゲートに集まって、RegWrite信号を作っている」**という、ISAの定義通りの論理がそのまま形となって現れます。

#### フィールドの抽出 (`field_logic`)
本ISAでは、`store` 命令のみ `rs2` が `instr[7:4]` ではなく `imm` フィールドの一部に含まれる等のバリエーションがあります。これを単なる配線ではなく「フィールド選択モジュール」として階層化することで、命令形式（R/I/S/B/J-type）によるビット位置の違いを意識させることができます。

---

### 4. 階層化のメリット
この分割により、学生は以下のステップで学習を進めることが可能になります。
1.  **Opcode Bank:** 最初の4ビットが命令の種類を決めていることを知る。
2.  **Field Logic:** 命令ごとにレジスタ番号が書かれている場所が違うことを知る。
3.  **Control Logic:** 複数の命令が同じハードウェア（例：Register Fileの書き込みポート）を共有していることを知る。