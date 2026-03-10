module alu_core_shifter_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire        i_sel,
    output wire [15:0] o_res
);

    wire [15:0] w_sra_res;
    wire [15:0] w_sla_res;
    wire [3:0]  w_shift_amount;

    assign w_shift_amount = i_b[3:0];

    assign w_sra_res = $signed(i_a) >>> w_shift_amount;
    assign w_sla_res = i_a << w_shift_amount;

    assign o_res = (i_sel == 1'b0) ? w_sra_res : w_sla_res;

endmodule