module pc_control_mux_1bit (
    input  wire [1:0] i_sel,
    input  wire       i_d0,
    input  wire       i_d1,
    input  wire       i_d2,
    input  wire       i_d3,
    output reg        o_q
);

    always @(*) begin
        case (i_sel)
            2'b00:   o_q = i_d0; // PC + 2
            2'b01:   o_q = i_d1; // Branch Target
            2'b10:   o_q = i_d2; // Jump Register Target
            2'b11:   o_q = i_d3; // Jump Target
            default: o_q = 1'b0;
        endcase
    end

endmodule