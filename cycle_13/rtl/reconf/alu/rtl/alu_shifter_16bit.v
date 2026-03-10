module alu_shifter_16bit (
    input  wire [15:0] i_data,
    input  wire [3:0]  i_shamt,
    input  wire        i_is_left,
    output wire [15:0] o_data
);

    // 算術シフト演算
    // i_is_left = 1: 算術左シフト (SLA) -> 0をLSB側に挿入
    // i_is_left = 0: 算術右シフト (SRA) -> 符号ビット(bit[15])をMSB側に挿入
    // シフト量は下位4ビット（0〜15）が有効
    assign o_data = (i_is_left == 1'b1) ? (i_data << i_shamt) : 
                                          ($signed(i_data) >>> i_shamt);

endmodule