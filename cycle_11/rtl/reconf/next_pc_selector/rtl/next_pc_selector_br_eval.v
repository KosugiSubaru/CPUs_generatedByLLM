module next_pc_selector_br_eval (
    input  wire [3:0] i_opcode,
    input  wire       i_flag_z,
    input  wire       i_flag_n,
    input  wire       i_flag_v,
    output wire       o_taken
);

    wire w_is_blt;
    wire w_is_bz;
    wire w_cond_blt;
    wire w_cond_bz;

    assign w_is_blt = (i_opcode == 4'b1100);
    assign w_is_bz  = (i_opcode == 4'b1101);

    assign w_cond_blt = i_flag_n ^ i_flag_v;
    assign w_cond_bz  = i_flag_z;

    assign o_taken = (w_is_blt & w_cond_blt) | 
                     (w_is_bz  & w_cond_bz);

endmodule