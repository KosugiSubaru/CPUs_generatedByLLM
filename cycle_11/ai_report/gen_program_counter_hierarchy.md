「視覚的にCPU回路の構造を理解する」という目的に基づき、`program_counter`モジュールを階層化・パターン構造化して提案します。

16bitの加算器やレジスタを1bit単位のセルに分解し、それを`generate`文で並列展開することで、論理合成後の回路図（RTL Viewer等）で「ビットごとの並び」が視覚的に強調される構成にします。

### 1. 階層構造一覧（ファイル構成）

1ファイル1モジュールの原則に従い、以下の6つのファイルで構成します。

| レベル | ファイル名 | 役割 |
| :--- | :--- | :--- |
| **L0 (Top)** | `program_counter_top.v` | PC本体、次アドレス計算ロジック、ジャンプ制御の統合 |
| **L1 (Block)** | `program_counter_reg_16bit.v` | 16bit同期リセット付きレジスタ（1bitセルを16個配置） |
| **L1 (Block)** | `program_counter_adder_16bit.v` | 16bit加算器（フルアダーを16個配置してRipple Carry構成） |
| **L1 (Block)** | `program_counter_mux_4to1_16bit.v` | 次のPC値を選択する4入力セレクタ（1bitセルを16個配置） |
| **L2 (Cell)** | `program_counter_dff.v` | 1bit D-フリップフロップ（同期リセット付） |
| **L2 (Cell)** | `program_counter_full_adder.v` | 1bit 全加算器 |
| **L2 (Cell)** | `program_counter_mux_4to1_1bit.v` | 1bit 4入力マルチプレクサ |

---

### 2. 各モジュールの役割と構造案

#### L0: `program_counter_top.v`
PC周辺の司令塔です。以下の3つのソースから次のPCを選択します。
1. `PC + 2` (通常時)
2. `PC + imm` (分岐・JAL)
3. `rs1 + imm` (JALR)

#### L1/L2: パターン構造化（Adder）
加算器をフルアダーの集合として定義します。RTL Viewerで見た際に、16個の同じ箱がキャリー（繰り上がり）信号で数珠つなぎになっている様子が確認できます。

- **`program_counter_full_adder.v`**: 基本単位（S, Coutを出力）
- **`program_counter_adder_16bit.v`**: `generate`文を用い、`full_adder`を16個インスタンス化。

#### L1/L2: パターン構造化（Register）
16bitの値を保持する部分を、1bitずつのD-FFに分解します。

- **`program_counter_dff.v`**: クロックに同期して入力を出力に渡す基本単位。
- **`program_counter_reg_16bit.v`**: `generate`文を用い、16個の`dff`を配置。

#### L1/L2: パターン構造化（MUX）
次のPCを何にするか（PCSource信号による選択）をビットごとに分離します。

- **`program_counter_mux_4to1_1bit.v`**: 4つの入力から1つを選ぶ論理ゲート群。
- **`program_counter_mux_4to1_16bit.v`**: `generate`文を用い、16ビット分並列に配置。

---

### 3. モジュール呼び出しのイメージ（パタン構造化）

各16bitモジュール内では、以下のように`generate`文を使用して下位モジュールを呼び出します。これにより、回路図上での規則正しい配置が保証されます。

```verilog
// program_counter_adder_16bit.v 内のイメージ
genvar i;
generate
    for (i = 0; i < 16; i = i + 1) begin : gen_adder
        program_counter_full_adder u_fa (
            .a     (in_a[i]),
            .b     (in_b[i]),
            .cin   (i == 0 ? 1'b0 : carry[i-1]),
            .sum   (out_s[i]),
            .cout  (carry[i])
        );
    end
endgenerate
```

### 4. この階層化による教育的利点

1.  **データパスの可視化**: 加算器のキャリーが下位ビットから上位ビットへ流れる様子や、MUXがビットごとに並列動作している様子が、合成後の技術マップで物理的に並んで見えます。
2.  **ISAとの対応**: 
    - 「命令長が16bit（2バイト）だからPCを+2する」ための専用加算器がどこにあるか。
    - 「JALR命令で基底レジスタ(rs1)を使用する」ための配線がMUXにどう繋がっているか。
    これらがモジュールという「箱」として独立しているため、デバッグや理解が容易になります。
3.  **タイミングの理解**: 1bit DFF（`program_counter_dff`）を明示することで、クロックが立ち上がる瞬間に初めて「次のPC」が「現在のPC」として確定するという同期回路の基本を視覚化できます。