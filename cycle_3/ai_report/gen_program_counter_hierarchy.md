教育用シングルサイクルCPUにおいて、ISAの挙動（PC+2、条件分岐、ジャンプ、JALR）を視覚的に理解しやすくするため、`program_counter`モジュールを以下の5段階の階層に分割し、`generate`文を用いたパタン構造化を提案します。

この設計では、16ビットの処理を「1ビットの積み重ね」として構成することで、論理合成後の回路図でデータパスの広がりを視覚的に追えるようにします。

---

### 階層構造図

```text
program_counter (Level 4: PCシステム全体)
├── program_counter_control (Level 3: 分岐判定・選択制御)
├── program_counter_reg (Level 2: 16bit同期レジスタ)
│   └── program_counter_bit (Level 1: 1bit D-FF)
├── program_counter_adder_16bit (Level 2: 16bit加算器)
│   └── program_counter_full_adder (Level 1: 全加算器)
│       └── program_counter_half_adder (Level 0: 半加算器)
└── program_counter_mux_4to1_16bit (Level 2: 16bitセレクタ)
    └── program_counter_mux_4to1_1bit (Level 1: 1bitセレクタ)
```

---

### 各ファイルの役割と階層レベルの説明

#### Level 0-1: プリミティブ・コンポーネント
最小単位の論理を定義します。

1. **program_counter_bit.v**
   - **役割**: 1ビット分のリセット付きDフリップフロップ。PCの実体を構成する最小単位です。
2. **program_counter_half_adder.v**
   - **役割**: 半加算器（XORとAND）。加算器の基礎となります。
3. **program_counter_full_adder.v**
   - **役割**: **program_counter_half_adder**を2つ呼び出し、全加算器を構成します。
4. **program_counter_mux_4to1_1bit.v**
   - **役割**: 1ビット幅の4入力セレクタ。次PCの候補（PC+2, 分岐先, ジャンプ先）から1つを選びます。

#### Level 2: パタン構造化モジュール (16bit化)
`generate`文を使用し、Level 1のモジュールを16個並列に並べて16ビット幅に拡張します。

5. **program_counter_reg.v**
   - **役割**: **program_counter_bit**を16個並べ、16ビットのPCレジスタを構成します。
6. **program_counter_adder_16bit.v**
   - **役割**: **program_counter_full_adder**を16個連結（キャリー伝搬）し、16ビットの加算器を構成します。PC+2やPC+immの計算に使用します。
7. **program_counter_mux_4to1_16bit.v**
   - **役割**: **program_counter_mux_4to1_1bit**を16個並べ、16ビットのバスを選択できるようにします。

#### Level 3: 制御ロジック
8. **program_counter_control.v**
   - **役割**: ISAの定義に基づき、次PCを決定する制御信号を生成します。
   - **ロジック**:
     - `bz`命令かつ`Z`フラグが1なら「PC+imm」を選択。
     - `blt`命令かつ`N^V`が1なら「PC+imm」を選択。
     - `jal`なら「PC+imm」、`jalr`なら「rs1+imm」を選択。
     - それ以外は「PC+2」を選択。

#### Level 4: トップレベル・サブモジュール
9. **program_counter.v**
   - **役割**: これまでのモジュールを統合するPCユニットの最上位です。
   - **内部接続**: 
     - 2つの`program_counter_adder_16bit`を使用して「PC+2」と「ターゲットアドレス（PC+imm等）」を同時並列に計算します。
     - `program_counter_control`の信号に基づき、`program_counter_mux_4to1_16bit`で次の値を決定し、`program_counter_reg`に格納します。

---

### 提案する実装のパタン構造化の例 (Verilogイメージ)

`program_counter_adder_16bit.v` などでは、以下のように `generate` 文を用いて視覚的な一貫性を持たせます。

```verilog
// program_counter_adder_16bit.v の例
genvar i;
generate
    for (i = 0; i < 16; i = i + 1) begin : gen_adder
        if (i == 0) begin
            program_counter_full_adder u_fa (
                .i_a(i_a[i]), .i_b(i_b[i]), .i_cin(1'b0),
                .o_sum(o_sum[i]), .o_cout(w_carry[i])
            );
        end else begin
            program_counter_full_adder u_fa (
                .i_a(i_a[i]), .i_b(i_b[i]), .i_cin(w_carry[i-1]),
                .o_sum(o_sum[i]), .o_cout(w_carry[i])
            );
        end
    end
endgenerate
```

### この階層化による視覚的効果

1.  **データパスの明示**: 論理合成ツール（VivadoやQuartus等）のRTL Viewerで見た際に、16個の同じブロックが整列するため、「ビットごとに同じ処理をしている」ことが一目でわかります。
2.  **ISAとの対応**: `program_counter_control`という独立したブロックがあることで、「どの命令（Opcode）がどの分岐条件（Flag）を使うのか」というISAのルールが回路上のどこで判定されているかが明確になります。
3.  **教育的配慮**: 加算器を半加算器レベルから積み上げることで、コンピュータアーキテクチャの基礎からCPUの全体像までを、階層を辿ることで学習できる構造になっています。