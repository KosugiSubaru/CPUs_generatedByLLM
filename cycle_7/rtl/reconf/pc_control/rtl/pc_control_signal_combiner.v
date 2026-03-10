module pc_control_signal_combiner (
    input  wire i_branch_taken,
    input  wire i_is_jal,
    input  wire i_is_jalr,
    output wire o_pc_sel_target
);

    wire [2:0] w_signals;
    wire [3:0] w_or_chain;

    assign w_signals = {i_branch_taken, i_is_jal, i_is_jalr};
    assign w_or_chain[0] = 1'b0;

    genvar i;
    generate
        for (i = 0; i < 3; i = i + 1) begin : gen_or_logic
            assign w_or_chain[i+1] = w_or_chain[i] | w_signals[i];
        end
    endgenerate

    assign o_pc_sel_target = w_or_chain[3];

endmodule