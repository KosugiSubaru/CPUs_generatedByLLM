教育用シングルサイクルCPUにおいて、**Control Unit**は「命令（機械語）を意味（制御信号）に変換する」というCPUの心臓部です。

ISAのOpcode（4ビット）を16通りの命令にデコードし、それぞれの命令が必要とする制御パスを有効化する様子を視覚化するため、以下の階層化とパターン構造化を提案します。

---

### 1. 階層構造の概要

Control Unitを「命令の特定（デコード）」「演算の制御」「データの流れの制御」「分岐の判断」の4つの役割に分離します。

- **Level 1: Top Module**
    - `control_unit`: 下位デコーダを統合し、CPU全体への制御信号をまとめる。
- **Level 2: Functional Decoders**
    - `control_unit_instruction_decoder`: 4ビットのOpcodeを、16本の「命令有効信号（One-hot）」に変換する。
    - `control_unit_alu_decoder`: どの命令がどのALU演算を必要とするかを決定する。
    - `control_unit_data_decoder`: レジスタファイルやメモリの書き込み許可信号、MUXの選択信号を生成する。
    - `control_unit_branch_decoder`: 命令の種類とフラグ（Z, N, V）を組み合わせて、分岐するかどうかを判定する。
- **Level 3: Logic Units (Pattern Units)**
    - `control_unit_decoder_2to4`: 2ビット入力を4出力に変換する基本デコーダ。これを組み合わせて4ビットデコーダを構成（パターン構造化）。

---

### 2. サブモジュールのリストと役割

| ファイル名 / モジュール名 | 階層 | 役割の説明 |
| :--- | :---: | :--- |
| **control_unit.v** | 1 | **最上位構成:** Opcodeを入力とし、下位モジュールから出力される各種制御信号をまとめ、CPU各部（ALU, PC, RegFile, Mem）へ供給する。 |
| **control_unit_instruction_decoder.v** | 2 | **命令識別器:** `generate`文を用いて `control_unit_decoder_2to4` を組み合わせ、4ビットのOpcodeから16本の「命令別有効フラグ（One-hot）」を生成する。 |
| **control_unit_decoder_2to4.v** | 3 | **基本デコーダ:** デコードの最小単位。2ビットの入力を1ビット×4の有効信号に変換する。視覚的にデコードの仕組みを理解させるためのパーツ。 |
| **control_unit_alu_decoder.v** | 2 | **ALU制御:** 命令有効フラグを受け取り、ALUが実行すべき演算モード（加算、減算、論理演算、シフト等）を決定する。 |
| **control_unit_data_decoder.v** | 2 | **データパス制御:** 書き込み有効信号（RegWrite, MemWrite）や、レジスタに書き戻すデータを選択するMUXの信号などを生成する。 |
| **control_unit_branch_decoder.v** | 2 | **分岐制御:** 分岐命令（`bz`, `blt`）やジャンプ命令（`jal`, `jalr`）と、ALUフラグの状態に基づき、`pc_sel`（次PCの選択信号）を生成する。 |

---

### 3. パターン構造化と視覚化のポイント

#### ① 命令識別を「1対1」の線にする（One-hot化）
`control_unit_instruction_decoder` を通すことで、回路図上に16本の信号線（例：`w_inst_add`, `w_inst_load`等）が現れます。これにより、論理合成後の回路図で「今どの命令のパスが光っているか（有効か）」が極めて直感的に理解できるようになります。

#### ② デコーダの再帰的構成（generate文の活用）
4ビットデコーダを「2ビットデコーダ×複数個」で構成する様子を `generate` 文で記述します。これにより、大規模なデコーダが小規模なデコーダの組み合わせでできているというデジタル回路の基本を視覚化します。

#### ③ 分岐ロジックの独立
分岐条件（`N^V` や `Z`）の判定を `control_unit_branch_decoder` に隔離することで、ISA定義にある「条件分岐命令はフラグを参照して分岐する」という仕様と、回路の対応が明確になります。

### 4. 教育的な効果
合成後の回路図では、左側に **Instruction Decoder** が配置され、そこから16本の信号線が右側の **ALU/Data/Branch Decoder** へと伸びる構造になります。これは、教科書にある「制御ユニットが命令を解釈し、各所に指示を出す」という概念図そのものとなります。