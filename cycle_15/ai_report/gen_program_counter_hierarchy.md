サブモジュール `program_counter` について、教育的な視覚化とパタン構造化を重視した階層設計を提案します。

この設計では、16ビットのレジスタや加算器を、最小単位のゲートや1ビット単位のモジュールから `generate` 文を用いて組み上げることで、**論理合成後の回路図（RTL Viewer等）でビットごとの並びや階層構造が綺麗に視覚化されること**を目的としています。

---

### 1. 階層構造一覧

| 階層レベル | ファイル名 | 役割 |
| :--- | :--- | :--- |
| **Level 0** | `program_counter_top.v` | PCの全体構成。レジスタ、加算器、セレクタを接続する最上位。 |
| **Level 1** | `program_counter_reg_16bit.v` | 16ビットの同期リセット付レジスタ。 |
| **Level 1** | `program_counter_adder_16bit.v` | 16ビットのリプルキャリー加算器。PC+2やPC+immに使用。 |
| **Level 1** | `program_counter_mux_4to1_16bit.v` | 次のPCを選択する4入力セレクタ（PC+2, Branch, JALR等）。 |
| **Level 2** | `program_counter_dff.v` | 1ビットのD型フリップフロップ（レジスタの最小単位）。 |
| **Level 2** | `program_counter_full_adder.v` | 1ビットの全加算器。 |
| **Level 2** | `program_counter_mux_2to1_16bit.v` | 16ビットの2入力セレクタ（4to1の構成要素）。 |
| **Level 3** | `program_counter_half_adder.v` | 1ビットの半加算器（全加算器の構成要素）。 |

---

### 2. 各モジュールの詳細とパタン構造化の提案

#### Level 0: 統合
- **`program_counter_top.v`**
  - **役割:** CPUコアからの制御信号を受け取り、次のPC値を計算して保持します。
  - **視覚的特徴:** 合成回路図において「計算（Adder）」「選択（Mux）」「保持（Reg）」の3つの大きなブロックがループ状に接続されている様子が確認できます。

#### Level 1 & 2: 保持機能 (Register)
- **`program_counter_reg_16bit.v`**
  - **構造化:** `generate` 文を使用して、`program_counter_dff` を16個並列にインスタンス化します。
  - **教育的意図:** 16ビットのデータが個別のフリップフロップに格納される様子を視覚化します。
- **`program_counter_dff.v`**
  - **役割:** 1ビットの値をクロック同期で保存。

#### Level 1, 2 & 3: 演算機能 (Adder)
- **`program_counter_adder_16bit.v`**
  - **構造化:** `generate` 文を使用して、`program_counter_full_adder` を16個直列（キャリーを伝搬）にインスタンス化します。
  - **教育的意図:** 「リプルキャリー加算器」の構造がそのまま回路図に現れ、下位ビットからの繰り上がりが上位ビットへ伝わる様子を理解しやすくします。
- **`program_counter_full_adder.v`**
  - **構造化:** 2つの `program_counter_half_adder` と1つのORゲートで構成。
- **`program_counter_half_adder.v`**
  - **役割:** 半加算器（XORとAND）による最小単位の加算。

#### Level 1 & 2: 選択機能 (Multiplexer)
- **`program_counter_mux_4to1_16bit.v`**
  - **構造化:** `program_counter_mux_2to1_16bit` を3つツリー状に組み合わせて構築します。
  - **教育的意図:** 複雑な4入力選択が、単純な2択の組み合わせで実現されている階層性を視覚化します。
  - **入力ソース:**
    1. `PC + 2` (通常進捗)
    2. `PC + imm` (Branch / JAL)
    3. `rs1 + imm` (JALR)
    4. `PC` (現在の値を維持、ストール用等の拡張性)
- **`program_counter_mux_2to1_16bit.v`**
  - **役割:** セレクト信号に応じて2つの16ビット入力から片方を選択。

---

### 3. パタン構造化（generate文）の適用イメージ

例えば、`program_counter_adder_16bit.v` 内では以下のように記述することで、回路図上に16個の全加算器が規則正しく並びます。

```verilog
// program_counter_adder_16bit.v 内のイメージ
genvar i;
generate
    for (i = 0; i < 16; i = i + 1) begin : gen_adder
        program_counter_full_adder u_fa (
            .a     (in_a[i]),
            .b     (in_b[i]),
            .cin   ( (i==0) ? 1'b0 : carry[i-1] ),
            .sum   (out_sum[i]),
            .cout  (carry[i])
        );
    end
endgenerate
```

### この設計のメリット
1.  **ISAとの対応:** PC相対分岐（`PC + imm`）や絶対ジャンプ（`rs1 + imm`）が、どの加算器とどのセレクタを通って実現されているかが、合成後のブロック図を見るだけで一目瞭然となります。
2.  **階層の深さ:** 半加算器から16ビット加算器までのステップを踏むことで、デジタル回路のボトムアップな構築プロセスを視覚的に示せます。
3.  **デバッグの容易性:** 1ビット単位までモジュールが分離されているため、特定のビットの挙動がおかしい場合に、どのインスタンスを確認すればよいか明確になります。