module wb_data_mux_bit (
    input  wire [1:0] i_sel,
    input  wire       i_alu,
    input  wire       i_mem,
    input  wire       i_pc2,
    output reg        o_q
);

    always @(*) begin
        case (i_sel)
            2'b00:   o_q = i_alu;
            2'b01:   o_q = i_mem;
            2'b10:   o_q = i_pc2;
            default: o_q = 1'b0;
        endcase
    end

endmodule