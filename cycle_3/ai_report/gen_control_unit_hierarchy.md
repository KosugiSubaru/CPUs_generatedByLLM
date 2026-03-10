教育用シングルサイクルCPUにおいて、命令（opcode）がどのように各部の制御信号（RegWriteやALUOpなど）に変換されるかを視覚化するため、`control_unit`を以下の4段階の階層に分割し、`generate`文を用いたパタン構造化を提案します。

この構成により、論理合成後の回路図で「4bitのデコード」→「16本の命令有効信号」→「各制御信号へのマッピング」という流れが、物理的なブロックとして整列して見えるようになります。

---

### 階層構造図

```text
control_unit (Level 3: 制御ユニット全体)
├── control_unit_decoder (Level 2: 命令デコーダ)
│   └── control_unit_instruction_gate (Level 1: 命令判定ゲート)
└── control_unit_op_matrix (Level 2: 制御信号生成マトリクス)
```

---

### 各ファイルの役割と階層レベルの説明

#### Level 1: 命令判定プリミティブ
最小単位のデコード論理を定義します。

1. **control_unit_instruction_gate.v**
   - **役割**: 入力された4ビットのopcodeが、特定のパターン（例: "1010"）と一致するかを判定するコンパレータ。
   - **視覚的効果**: 回路図上で「このゲートはLOAD命令を監視している」ということが1つのブロックとして独立して見えます。

#### Level 2: パタン構造化・マトリクス変換
`generate`文による並列展開と、論理和（OR）による信号合成を行います。

2. **control_unit_decoder.v**
   - **役割**: **control_unit_instruction_gate**を`generate`文で16個インスタンス化し、4ビットのopcodeを16本の「命令有効信号線（w_inst_active[15:0]）」に変換します。
   - **パタン構造化**: 0から15までのopcodeに対応するゲートを整列させます。これにより、命令セットの全貌がハードウェアの並びとして視覚化されます。

3. **control_unit_op_matrix.v**
   - **役割**: 16本の命令有効信号線を受け取り、各制御信号（RegWrite, MemWrite, ALUOp等）を生成します。
   - **仕様**: 例えば、RegWrite信号は「ADD命令 OR SUB命令 OR ... OR LOAD命令」のように、該当する命令信号の論理和として構成されます。

#### Level 3: トップレベル・サブモジュール
4. **control_unit.v**
   - **役割**: **control_unit_decoder**と**control_unit_op_matrix**を接続する最上位です。
   - **外部出力**: 以下の制御信号を出力します。
     - `RegWrite`: レジスタファイルへの書き込み許可
     - `MemWrite`: データメモリへの書き込み許可
     - `ALUSrc`: ALUの第2入力をレジスタにするか即値にするかの選択
     - `MemToReg`: レジスタへの書き込みデータをALU結果にするかメモリにするかの選択
     - `ALUOp`: ALUに実行させる演算種別

---

### 提案する実装のパタン構造化の例 (Verilogイメージ)

`control_unit_decoder.v` では、以下のように `generate` 文を用いて、16個の命令判定器を整列させます。

```verilog
// control_unit_decoder.v の例
genvar i;
generate
    for (i = 0; i < 16; i = i + 1) begin : gen_inst_dec
        control_unit_instruction_gate #(
            .TARGET_OPCODE(i[3:0]) // パラメータで各ゲートの監視対象opcodeを指定
        ) u_gate (
            .i_opcode(i_opcode),
            .o_active(w_inst_active[i])
        );
    end
endgenerate
```

### この階層化による視覚的効果

1.  **デコードプロセスの可視化**: 命令が「1対多」に分解され、それが再び「多対1」で制御信号に集約される様子が、回路図上の配線の束（バス）として明快に表現されます。
2.  **ISAの拡張性の理解**: 新しい命令を追加する場合、`decoder`にゲートを増やし、`matrix`のOR条件に1本線を追加すればよいという、プロセッサ設計の拡張性が直感的に理解できます。
3.  **デバッグの容易性**: 論理合成後のシミュレーションや回路図確認において、「今どの命令がアクティブになっているか」を16本の信号線のうち1本がハイになることで視覚的に追跡可能になります。