module reg_file_mux (
    input  wire [3:0]  i_addr,   // 読み出しアドレス（4ビット）
    input  wire [15:0] i_r0,     // 各レジスタセルからのデータ入力（16ビット）
    input  wire [15:0] i_r1,
    input  wire [15:0] i_r2,
    input  wire [15:0] i_r3,
    input  wire [15:0] i_r4,
    input  wire [15:0] i_r5,
    input  wire [15:0] i_r6,
    input  wire [15:0] i_r7,
    input  wire [15:0] i_r8,
    input  wire [15:0] i_r9,
    input  wire [15:0] i_r10,
    input  wire [15:0] i_r11,
    input  wire [15:0] i_r12,
    input  wire [15:0] i_r13,
    input  wire [15:0] i_r14,
    input  wire [15:0] i_r15,
    output wire [15:0] o_data    // 選択されたデータ出力
);

    // 16入力1出力のマルチプレクサ論理
    assign o_data = (i_addr == 4'h0) ? i_r0  :
                    (i_addr == 4'h1) ? i_r1  :
                    (i_addr == 4'h2) ? i_r2  :
                    (i_addr == 4'h3) ? i_r3  :
                    (i_addr == 4'h4) ? i_r4  :
                    (i_addr == 4'h5) ? i_r5  :
                    (i_addr == 4'h6) ? i_r6  :
                    (i_addr == 4'h7) ? i_r7  :
                    (i_addr == 4'h8) ? i_r8  :
                    (i_addr == 4'h9) ? i_r9  :
                    (i_addr == 4'hA) ? i_r10 :
                    (i_addr == 4'hB) ? i_r11 :
                    (i_addr == 4'hC) ? i_r12 :
                    (i_addr == 4'hD) ? i_r13 :
                    (i_addr == 4'hE) ? i_r14 :
                                       i_r15;

endmodule