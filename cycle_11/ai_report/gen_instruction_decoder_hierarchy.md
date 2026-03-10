「教育用としてISAと回路の対応関係を視覚化する」という目的に適した、`instruction_decoder`の階層化とパターン構造化を提案します。

デコーダを「命令をバラバラにする部分」「どの命令か特定する部分（One-hot生成）」「制御信号へマッピングする部分」に分けることで、回路図上で「命令の特定」から「制御線の活性化」までの流れが視覚的に理解できるようになります。

### 1. 階層構造一覧（ファイル構成）

1ファイル1モジュールの原則に従い、以下の5つのファイルで構成します。

| レベル | ファイル名 | 役割 |
| :--- | :--- | :--- |
| **L0 (Top)** | `instruction_decoder.v` | 全体の統合。フィールド抽出、One-hot生成、信号マッピングの接続。 |
| **L1 (Block)** | `instruction_decoder_field_extractor.v` | 16bit命令を`rd`, `rs1`, `rs2`, `imm`, `opcode`に分解する。 |
| **L1 (Block)** | `instruction_decoder_op_onehot.v` | 4bitの`opcode`から、16系統の「命令特定信号（ADD信号、SUB信号等）」を生成する。 |
| **L1 (Block)** | `instruction_decoder_signal_mapper.v` | 特定された命令信号に基づき、`reg_write`, `mem_write`などの具体的な制御信号を生成する。 |
| **L2 (Cell)** | `instruction_decoder_match_cell.v` | 入力された`opcode`が、自身の担当する期待値と一致するかを判定する最小単位。 |

---

### 2. 各モジュールの役割と階層レベルの詳細

#### L0: `instruction_decoder.v`
全体の最上位です。命令メモリからの入力を受け取り、各ブロックを接続します。
- `field_extractor` でバラバラにしたあと、`opcode` を `op_onehot` へ渡します。
- `op_onehot` から出た16本の「命令実行中フラグ」を `signal_mapper` へ渡します。

#### L1: `instruction_decoder_field_extractor.v`
ISA定義に基づき、ワイヤの結合（Concatenation）のみで構成されます。
- `bit_field: rd[15:12]+rs1[11:8]+rs2[7:4]+opcode[3:0]` のような定義を、視覚的な配線として分離します。

#### L1/L2: `instruction_decoder_op_onehot.v` と `match_cell.v` (パタン構造化)
もっとも教育的な部分です。
- **`match_cell`**: 「自分の担当は `0000`(ADD) か？」を判定する4bit比較器です。
- **`op_onehot`**: `generate`文を用いて、`match_cell` を16個並列に配置します。
  - **視覚的効果**: 回路図で見ると、16個の同じ箱が並び、それぞれが特定の命令に対応している様子が分かります。例えば `opcode` が `0000` の時、一番上の箱だけが `1` を出力するのが見えます。

#### L1: `instruction_decoder_signal_mapper.v`
One-hot信号（16本の命令フラグ）を、CPU内の具体的な制御信号に集約します。
- 例: 「`reg_write_en` 信号」は、(ADD信号 OR SUB信号 OR LOAD信号 ...) という論理和で生成されます。
- **視覚的効果**: どの命令がどの制御信号を「生かして」いるのかが、大きなORゲートの集まりとして視覚化されます。

---

### 3. モジュール呼び出しのイメージ（パタン構造化）

`instruction_decoder_op_onehot.v` 内での実装イメージです。

```verilog
// 16種類の命令に対応する信号を生成
genvar i;
generate
    for (i = 0; i < 16; i = i + 1) begin : gen_op_detect
        instruction_decoder_match_cell #(
            .TARGET_OPCODE(i) // 0から15の数値をパラメータで渡す
        ) u_match (
            .i_opcode (w_opcode),
            .o_match  (w_inst_active[i]) // 命令iが実行中なら1
        );
    end
endgenerate
```

### 4. この階層化による教育的利点

1.  **「デコード」の本質の視覚化**: 4bitのバイナリが16本の独立した命令線に化ける様子（One-hot）を物理的なブロックで見せることができます。
2.  **ISA拡張の容易性の理解**: 新しい命令を追加する場合、`match_cell`を増やすか、`signal_mapper`のOR条件を増やすだけでよいという構造が直感的にわかります。
3.  **制御パスの独立性**: データパス（演算器など）とは別に、制御パス（デコーダ）が「どのスイッチをオンにするか」を決めているという役割分担が明確になります。