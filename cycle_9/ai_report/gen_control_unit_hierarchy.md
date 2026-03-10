「control_unit」はCPUの「司令塔」であり、命令の種類に応じてデータパスの各所へ制御信号（セレクタ切り替えや書き込み許可など）を送ります。

教育用として、opcodeのデコード過程と、各制御信号（RegWrite, MemWrite等）が生成される論理を視覚的に分離した階層構造を提案します。

---

### 1. 階層構造の設計方針

| 階層レベル | ファイル名 | モジュール名 | 役割 |
| :--- | :--- | :--- | :--- |
| **Level 0** | `control_unit_match.v` | `control_unit_match` | **最小単位**。入力opcodeが指定された特定値と一致するか判定（1ビットのOne-hot生成）。 |
| **Level 1** | `control_unit_decoder.v` | `control_unit_decoder` | **パターン構造化単位**。`generate`文で`match`モジュールを16個並べ、16ビットのOne-hot信号を出力。 |
| **Level 1** | `control_unit_logic.v` | `control_unit_logic` | One-hot信号を論理和（OR）し、RegWrite, MemWrite, ALUOpなどの基本制御信号を生成。 |
| **Level 1** | `control_unit_pc_logic.v` | `control_unit_pc_logic` | 分岐命令（blt, bz）の成立判定や、ジャンプ命令（jal, jalr）のPC選択信号を制御。 |
| **Level 2** | `control_unit.v` | `control_unit` | **本体**。上記のサブモジュールを統合し、CPU全体への制御信号をまとめる。 |

---

### 2. サブモジュールのリストアップ

hierarchy:
control_unit_match.v: 4ビットのopcodeとパラメータ化された期待値を比較し、一致信号を出力する。
control_unit_decoder.v: `generate`文を用いて16個の`control_unit_match`をインスタンス化し、4bitから16bit(One-hot)へのデコードを行う。
control_unit_logic.v: デコードされた16ビット信号に基づき、レジスタ書き込み許可やALUソース選択などのデータパス制御信号を生成する。
control_unit_pc_logic.v: 分岐条件（N, V, Zフラグ）と分岐・ジャンプ命令を照合し、PCの更新ソースを決定する論理。
control_unit.v: 制御階層のトップ。opcodeを入力とし、データパスおよびPC制御に必要なすべての信号を出力する。

---

### 3. 各階層の教育的意図

#### ① `control_unit_decoder` による視覚化
通常、デコード処理は `case` 文で記述されますが、あえて `control_unit_match` を16個並べることで、回路図上で**「現在実行中の命令が16本の線のうちどれか1本を光らせている」**様子が視覚化されます。これはデコードの概念を理解する上で非常に強力な視覚効果となります。

#### ② `control_unit_logic` による論理の明示
「RegWrite信号がONになるのは、ADD命令の時、またはSUB命令の時、または...」という論理が、One-hot信号のORゲートとして回路図に現れます。これにより、ISAの命令定義とハードウェアの動作許可信号の結びつきが明確になります。

#### ③ `control_unit_pc_logic` でのフラグ参照
ISA定義にある「1クロック前のフラグを参照する」という動作を、このモジュール内に集約します。`blt` (N^V) や `bz` (Z) の条件式が独立したブロックとして存在するため、分岐条件の設計ミスを防ぎ、デバッグを容易にします。

---

### 4. 生成される主要な制御信号（例）
このモジュール群から出力される主な信号は以下の通りです。
- `o_reg_we`: レジスタファイルへの書き込み許可
- `o_mem_we`: データメモリへの書き込み許可
- `o_alu_op`: ALUに実行させる演算の種類（4bit）
- `o_alu_src_sel`: ALUの第2入力にレジスタ(rs2)を使うか即値(imm)を使うかの選択
- `o_wb_sel`: レジスタへの書き戻し値を、ALU結果、メモリ、PC+2のどれにするかの選択
- `o_pc_sel`: 次のPCを PC+2, PC+imm, rs1+imm のどれにするかの選択信号