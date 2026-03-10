module pc_control_gate_xor (
    input  wire i_n,
    input  wire i_v,
    output wire o_less_than
);

    assign o_less_than = i_n ^ i_v;

endmodule