サブモジュール `control_unit` について、ISAの命令とハードウェア制御信号の対応関係を視覚化し、構造的に理解するための階層設計を提案します。

この設計の核心は、**「バイナリのOpcodeを一度『1-of-N（ワンホット）』信号にデコードし、その信号から各制御信号を生成する」**というアプローチです。これにより、回路図上で「どの命令が実行されているか」という線（ワイヤ）が、どの制御信号（レジスタ書き込み有効化など）をアクティブにしているかが一目で分かります。

---

### 1. 階層構造一覧

| 階層レベル | ファイル名 | 役割 |
| :--- | :--- | :--- |
| **Level 0** | `control_unit.v` | 最上位。デコーダと信号生成ロジックを接続し、CPU全体の制御信号を出力する。 |
| **Level 1** | `control_unit_instruction_decoder.v` | 4ビットのOpcodeを入力とし、16本の命令特定信号（one-hot）を出力する。 |
| **Level 1** | `control_unit_signal_logic.v` | 特定された命令信号とフラグ入力を組み合わせ、具体的な制御信号（RegWrite, MemWrite等）を生成する。 |
| **Level 2** | `control_unit_decoder_4to16.v` | 4入力16出力のデコーダ本体。パタン構造化の中核。 |
| **Level 3** | `control_unit_decoder_2to4.v` | 2入力4出力のデコーダ。4to16デコーダの構成要素。 |

---

### 2. 各モジュールの役割と階層の詳細説明

#### Level 0: 統合
- **`control_unit.v`**
  - **役割:** CPU全体の司令塔。命令（`i_instr[3:0]`）とフラグ（`Z, N, V`）を入力し、ALU、レジスタ、メモリ、PCセレクタへの制御信号をまとめます。
  - **視覚的特徴:** 合成図では、左側に「命令解析ブロック」、右側に「信号生成ブロック」が配置され、その間を16本の命令ワイヤが流れる形になります。

#### Level 1 & 2 & 3: 命令解析 (Decoder)
- **`control_unit_instruction_decoder.v`**
  - **役割:** 4ビットのOpcodeを人間が理解しやすい16本の独立した信号（`inst_add`, `inst_sub`, `inst_load` 等）に変換します。
- **`control_unit_decoder_4to16.v`**
  - **構造化:** **`generate` 文**を使用して、`control_unit_decoder_2to4` を複数組み合わせて構築します（上位2bitで下位のデコーダの有効化を切り替えるツリー構造）。
  - **教育的意図:** 複雑なデコード処理が、小さなデコーダの組み合わせで実現できることを視覚的に示します。
- **`control_unit_decoder_2to4.v`**
  - **役割:** 最小単位のデコード論理。

#### Level 1: 信号生成 (Signal Logic)
- **`control_unit_signal_logic.v`**
  - **役割:** 命令ワイヤを束ねて、具体的なハードウェア制御信号を作ります。
  - **論理構成:**
    - `o_reg_write = inst_add | inst_sub | ... | inst_load | inst_jal;`
    - `o_mem_write = inst_store;`
    - `o_pc_sel` の決定: 分岐命令（`inst_bz`, `inst_blt`）とフラグ条件のANDを取り、次のPCのアドレスを選択。
  - **視覚的特徴:** 「どの命令群がこの制御信号を共有しているか」が大きなORゲートの集まりとして視覚化されます。例えば、すべてのALU演算命令が `RegWrite` に繋がっている様子が確認できます。

---

### 3. パタン構造化の適用イメージ（Decoder部）

`control_unit_decoder_4to16.v` において、`generate` 文を用いて2to4デコーダを配置する例です。

```verilog
// control_unit_decoder_4to16.v 内の構造化イメージ
genvar i;
generate
    // 上位2bitをデコードして4つの下位デコーダのうち1つを有効にする(Enable信号)
    control_unit_decoder_2to4 u_upper (
        .i_sel(i_opcode[3:2]), .i_en(1'b1), .o_out(w_enable_lines[3:0])
    );
    
    // 下位2bitをデコードするユニットを4つ並列配置
    for (i = 0; i < 4; i = i + 1) begin : gen_decoders
        control_unit_decoder_2to4 u_lower (
            .i_sel(i_opcode[1:0]), .i_en(w_enable_lines[i]), .o_out(o_inst_onehot[i*4 +: 4])
        );
    end
endgenerate
```

### この構成のメリット
1.  **ISAとの直感的な対応:** 合成後の回路図で、例えば `addition` 命令の信号線（ワイヤ）を辿ると、それが `Register File` の `WriteEnable` と `ALU` の `Add` 信号に繋がっているのが見えます。
2.  **デバッグの容易性:** シミュレーション時に「今どの命令がアクティブか」を one-hot 信号で直接確認できるため、教育用として非常に強力です。
3.  **拡張性:** 新しい命令をISAに追加した際、デコーダを1つ増やし、信号生成ロジックのORゲートに入力を1本追加するだけで対応できるため、ハードウェア設計の基本原則を学べます。