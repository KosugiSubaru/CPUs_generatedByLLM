module pc_control_condition (
    input  wire i_is_blt,
    input  wire i_is_bz,
    input  wire i_flag_z,
    input  wire i_flag_n,
    input  wire i_flag_v,
    output wire o_is_taken
);

    wire w_blt_match;
    wire w_bz_match;

    // ISA定義: branch less than (blt) は N ^ V が真の時に分岐
    assign w_blt_match = i_flag_n ^ i_flag_v;

    // ISA定義: branch zero (bz) は Z が真の時に分岐
    assign w_bz_match  = i_flag_z;

    // 命令が分岐命令であり、かつ対応するフラグ条件を満たしている場合に1を出力
    assign o_is_taken = (i_is_blt & w_blt_match) | (i_is_bz & w_bz_match);

endmodule