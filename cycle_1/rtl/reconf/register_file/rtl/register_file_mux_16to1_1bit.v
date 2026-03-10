module register_file_mux_16to1_1bit (
    input  wire [3:0]  i_sel,
    input  wire [15:0] i_data, // 16個のレジスタの同じビット位置の集合
    output reg         o_data
);

    // 16入力1ビット出力のマルチプレクサ
    always @(*) begin
        case (i_sel)
            4'h0: o_data = i_data[0];
            4'h1: o_data = i_data[1];
            4'h2: o_data = i_data[2];
            4'h3: o_data = i_data[3];
            4'h4: o_data = i_data[4];
            4'h5: o_data = i_data[5];
            4'h6: o_data = i_data[6];
            4'h7: o_data = i_data[7];
            4'h8: o_data = i_data[8];
            4'h9: o_data = i_data[9];
            4'ha: o_data = i_data[10];
            4'hb: o_data = i_data[11];
            4'hc: o_data = i_data[12];
            4'hd: o_data = i_data[13];
            4'he: o_data = i_data[14];
            4'hf: o_data = i_data[15];
            default: o_data = 1'b0;
        endcase
    end

endmodule