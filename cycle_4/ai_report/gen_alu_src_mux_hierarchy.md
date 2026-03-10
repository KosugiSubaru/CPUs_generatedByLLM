「alu_src_mux」は、ALUの第2入力として「レジスタから読み出した値（rs2）」と「生成された即値（imm）」のどちらを使用するかを選択するマルチプレクサです。

教育用として、16ビットのデータ選択が**「1ビットごとの選択素子の並列化」**で構成されていることを視覚化するため、以下の階層構造とパタン構造を提案します。

---

### 1. 階層構造の概要

| 階層レベル | ファイル名 | モジュール名 | 役割 |
| :--- | :--- | :--- | :--- |
| **Level 0** (最小単位) | `alu_src_mux_bit.v` | `alu_src_mux_bit` | 1ビット幅の2対1マルチプレクサ。制御信号に基づき、rs2かimmの1ビットを選択する。 |
| **Level 1** (最上位) | `alu_src_mux.v` | `alu_src_mux` | `generate`文を用いて、`alu_src_mux_bit`を16個並列に配置し、16ビット幅のセレクタを構成する。 |

---

### 2. 各モジュールの役割と説明

#### Level 0: `alu_src_mux_bit.v`
データパスにおける選択の最小単位です。
- **教育的役割**: 16ビットの切り替えが、実は1ビットずつの独立したスイッチの集まりであることを回路図上で示します。
- 制御信号（`i_alu_src`）が「0」ならレジスタ値、「1」なら即値を選択します。

#### Level 1: `alu_src_mux.v`
ALU入力選択ユニットの全体を統括します。
- **パタン構造化**: `generate`文を使用することで、16個の独立したMUXブロックが整然と並ぶ回路図が生成されます。
- **ISAとの対応**: `addi` や `load` 命令などの「Iタイプ命令」において、データパスがレジスタから即値側に切り替わる様子を視覚的に強調します。

---

### 3. ファイルリストのリストアップ

hierarchy:
alu_src_mux_bit.v: 制御信号に基づき、レジスタ値の1ビットと即値の1ビットのいずれかを選択して出力する最小構成単位。
alu_src_mux.v: generate文を用いてalu_src_mux_bitを16個並列にインスタンス化し、ALUへの供給データを一括で切り替える16ビットセレクタの最上位。

---

### 4. Verilogコードの生成

#### ファイル1：alu_src_mux_bit.v
```verilog
module alu_src_mux_bit (
    input  wire i_sel,  // 0:rs2, 1:imm
    input  wire i_rs2,
    input  wire i_imm,
    output wire o_data
);

    assign o_data = (i_sel == 1'b1) ? i_imm : i_rs2;

endmodule
```

#### ファイル2：alu_src_mux.v
```verilog
module alu_src_mux (
    input  wire        i_alu_src, // 制御信号
    input  wire [15:0] i_rs2_data,
    input  wire [15:0] i_imm_data,
    output wire [15:0] o_alu_op2
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_alu_src_mux
            alu_src_mux_bit u_mux_bit (
                .i_sel  (i_alu_src),
                .i_rs2  (i_rs2_data[i]),
                .i_imm  (i_imm_data[i]),
                .o_data (o_alu_op2[i])
            );
        end
    endgenerate

endmodule
```