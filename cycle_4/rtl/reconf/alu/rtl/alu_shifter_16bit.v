module alu_shifter_16bit (
    input  wire [15:0] i_a,
    input  wire [15:0] i_b,
    input  wire [3:0]  i_op,
    output reg  [15:0] o_out
);

    wire [3:0]  w_shamt;
    wire [15:0] w_sra_res;
    wire [15:0] w_sla_res;

    // シフト量は下位4ビットを使用
    assign w_shamt   = i_b[3:0];

    // 算術右シフト (符号ビット維持)
    assign w_sra_res = $signed(i_a) >>> w_shamt;

    // 算術左シフト (Verilogの<<<は符号付き変数に対して<<と同様に動作)
    assign w_sla_res = i_a << w_shamt;

    always @(*) begin
        case (i_op)
            4'b0110: o_out = w_sra_res; // sra
            4'b0111: o_out = w_sla_res; // sla
            default: o_out = 16'h0000;
        endcase
    end

endmodule