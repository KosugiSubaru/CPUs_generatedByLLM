サブモジュール「inst_decoder」について、16ビットの命令を4ビットずつの「セグメント」として視覚的に分離し、ISAのビットフィールド構造を回路図上で直感的に理解できるようにする階層化を提案します。

### 1. 階層構造の設計方針

教育用として、16ビットの命令が「どの4ビットの塊（ニブル）から構成されているか」を回路図上で明示するため、命令をスライスする中間層を設けます。

| 階層レベル | ファイル名 | モジュール名 | 役割 |
| :--- | :--- | :--- | :--- |
| **Level 0** | `inst_decoder_slice.v` | `inst_decoder_slice` | 4ビットの信号を通過させるだけのバッファ。回路図上で「命令の特定部分」をブロックとして独立させるために使用。 |
| **Level 1** | `inst_decoder.v` | `inst_decoder` | **本体**。16ビット命令を`generate`文で4つのスライスに分割し、ISAに基づいた各フィールド（rd, rs1, rs2, opcode等）へマッピングする。 |

---

### 2. サブモジュールのリストアップ

hierarchy:
inst_decoder_slice.v: 16ビット命令を4ビット単位で物理的に分離するためのスライスモジュール。
inst_decoder.v: 4つのスライスを束ね、opcode、rd、rs1、rs2、および即値生成用の生ビット（raw bits）として出力するデコード階層のトップ。

---

### 3. 各ファイルの役割と階層レベルの詳細

#### Level 0: `inst_decoder_slice.v`
このモジュール自体は単なる配線ですが、論理合成ツールで見たときに「Instruction[3:0]」などが一つの箱（Slice）として表示されるようになります。これにより、命令のどの部分がOpcodeに使われているか、といった対応が視覚的に明確になります。

```verilog
// inst_decoder_slice.v
module inst_decoder_slice (
    input  wire [3:0] i_bits,
    output wire [3:0] o_bits
);
    // 信号をそのままバイパスし、回路図上でのブロック化を目的とする
    assign o_bits = i_bits;
endmodule
```

#### Level 1: `inst_decoder.v`
`generate`文を用いて4つの`inst_decoder_slice`をインスタンス化します。その後、各スライスから出た信号を、ISA定義に基づいたポート名に割り当てます。

```verilog
// inst_decoder.v
module inst_decoder (
    input  wire [15:0] i_instr,
    
    // 基本フィールドの抽出
    output wire [3:0]  o_opcode,  // instr[3:0]
    output wire [3:0]  o_rs2_raw, // instr[7:4]
    output wire [3:0]  o_rs1_raw, // instr[11:8]
    output wire [3:0]  o_rd_raw,  // instr[15:12]
    
    // 即値生成(imm_gen)に渡すための統合フィールド
    output wire [11:0] o_imm_raw_15_4  // instr[15:4] (Branch用)
);

    // 内部接続用配線
    wire [3:0] slice_out [3:0];

    // パターン構造化：命令を4ビットずつのスライスとして展開
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_slices
            inst_decoder_slice u_slice (
                .i_bits (i_instr[i*4 +: 4]),
                .o_bits (slice_out[i])
            );
        end
    endgenerate

    // ISA定義に基づいたフィールドの割り当て
    assign o_opcode  = slice_out[0]; // [3:0]
    assign o_rs2_raw = slice_out[1]; // [7:4]
    assign o_rs1_raw = slice_out[2]; // [11:8]
    assign o_rd_raw  = slice_out[3]; // [15:12]
    
    // 複雑な即値フィールド（blt, bz用など）の結合
    assign o_imm_raw_15_4 = {slice_out[3], slice_out[2], slice_out[1]};

endmodule
```

---

### 4. 教育的・視覚的メリット

1.  **ビットフィールドの対応**: 回路図上で `gen_slices[0]` が常に `opcode` に繋がっている様子が見えるため、ISAの `bit_field` 定義（例: `rd[15:12]+rs1[11:8]+rs2[7:4]+opcode[3:0]`）と実際の配線の対応が一目で理解できます。
2.  **配線の整理**: 16ビットの束からバラバラに配線を引くのではなく、一旦「4ビットのスライス」という中間ステップを踏むことで、複雑な回路図の中でも命令の構造が保たれます。
3.  **即値生成への橋渡し**: `imm_raw_15_4` のように、特定のスライスを組み合わせた出力を設けることで、次のステップである `imm_gen` モジュールとの関係性が示唆されます。