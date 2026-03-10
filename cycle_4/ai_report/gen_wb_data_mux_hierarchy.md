「wb_data_mux（ライトバックデータ選択マルチプレクサ）」は、最終的にレジスタファイル（rd）に書き込むデータを、「ALUの演算結果」「データメモリからの読み出し値」「戻りアドレス（PC+2）」の中から選択するモジュールです。

データパスの最終地点として、どの命令がどのデータソースを選択しているかを視覚化するため、1ビットの選択素子を並列化するパタン構造化を提案します。

---

### 1. 階層構造の概要

| 階層レベル | ファイル名 | モジュール名 | 役割 |
| :--- | :--- | :--- | :--- |
| **Level 0** (最小単位) | `wb_data_mux_bit.v` | `wb_data_mux_bit` | 1ビット幅のマルチプレクサ。制御信号に基づき、ALU結果、メモリ値、PC+2のいずれか1ビットを選択する。 |
| **Level 1** (最上位) | `wb_data_mux.v` | `wb_data_mux` | `generate`文を用いて、`wb_data_mux_bit`を16個並列に配置し、16ビット幅の書き戻しデータセレクタを構成する。 |

---

### 2. 各モジュールの役割と説明

#### Level 0: `wb_data_mux_bit.v`
書き戻しパスの選択を行う最小単位です。
- **教育的役割**: 16ビットのデータが、制御信号（`i_sel`）によって一斉に切り替わる様子をビットレベルのスイッチ群として視覚化します。
- 3つの入力ソース（ALU, Memory, PC+2）を2ビットの選択信号で切り替えます。

#### Level 1: `wb_data_mux.v`
ライトバック選択ユニットの全体を統括します。
- **パタン構造化**: `generate`文を使用し、16個のMUXブロックを配置します。
- **選択ロジックの統合**: `control_unit`から出力される `i_mem_to_reg`（メモリ選択）や `i_reg_src_pc`（ジャンプ時のPC+2選択）を統合し、1ビットMUX群への選択信号を生成します。

---

### 3. この階層化によるメリット

1.  **データフローの終着点の視覚化**:
    回路図の右端で、演算・メモリ・PCの3つの大きな流れがこのMUXで1つに収束し、レジスタファイルへ戻っていく様子が明確に表現されます。
2.  **命令タイプとデータソースの対応**:
    「ロード命令（Memory選択）」「演算命令（ALU選択）」「ジャンプ命令（PC+2選択）」というISAの動作が、どのパスを有効にしているかとして直感的に理解できます。

---

### 4. 構成ファイルリスト

hierarchy:
wb_data_mux_bit.v: 2ビットの選択信号に基づき、ALU結果、データメモリ、PC+2のいずれか1ビットを選択して出力するマルチプレクサ。
wb_data_mux.v: generate文を用いてwb_data_mux_bitを16個並列にインスタンス化し、レジスタへの書き戻しデータを一括で選択する最上位。

---

### 5. Verilogコードの生成

#### ファイル1：wb_data_mux_bit.v
```verilog
module wb_data_mux_bit (
    input  wire [1:0] i_sel, // 00:ALU, 01:Mem, 10:PC+2
    input  wire       i_alu,
    input  wire       i_mem,
    input  wire       i_pc2,
    output reg        o_q
);

    always @(*) begin
        case (i_sel)
            2'b00:   o_q = i_alu;
            2'b01:   o_q = i_mem;
            2'b10:   o_q = i_pc2;
            default: o_q = 1'b0;
        endcase
    end

endmodule
```

#### ファイル2：wb_data_mux.v
```verilog
module wb_data_mux (
    input  wire        i_mem_to_reg, // 制御信号1
    input  wire        i_reg_src_pc, // 制御信号2
    input  wire [15:0] i_alu_res,
    input  wire [15:0] i_mem_data,
    input  wire [15:0] i_pc_plus2,
    output wire [15:0] o_wb_data
);

    wire [1:0] w_sel;

    // 選択信号のエンコード
    assign w_sel = (i_reg_src_pc) ? 2'b10 :
                   (i_mem_to_reg) ? 2'b01 : 2'b00;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_wb_mux
            wb_data_mux_bit u_mux_bit (
                .i_sel (w_sel),
                .i_alu (i_alu_res[i]),
                .i_mem (i_mem_data[i]),
                .i_pc2 (i_pc_plus2[i]),
                .o_q   (o_wb_data[i])
            );
        end
    endgenerate

endmodule
```