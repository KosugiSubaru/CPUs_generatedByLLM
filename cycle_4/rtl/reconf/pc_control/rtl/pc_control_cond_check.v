module pc_control_cond_check (
    input  wire [3:0] i_opcode,
    input  wire       i_flag_z,
    input  wire       i_flag_n,
    input  wire       i_flag_v,
    output wire       o_cond_met
);

    wire w_is_blt;
    wire w_is_bz;
    wire w_blt_met;
    wire w_bz_met;

    // Opcode detection for branch instructions
    assign w_is_blt = (i_opcode == 4'b1100);
    assign w_is_bz  = (i_opcode == 4'b1101);

    // Condition logic based on ISA behavior
    assign w_blt_met = w_is_blt && (i_flag_n ^ i_flag_v);
    assign w_bz_met  = w_is_bz  && i_flag_z;

    assign o_cond_met = w_blt_met || w_bz_met;

endmodule