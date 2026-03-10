module alu_core_mux_8to1_1bit (
    input  wire [2:0] i_sel,
    input  wire       i_d0,
    input  wire       i_d1,
    input  wire       i_d2,
    input  wire       i_d3,
    input  wire       i_d4,
    input  wire       i_d5,
    input  wire       i_d6,
    input  wire       i_d7,
    output reg        o_data
);

    always @(*) begin
        case (i_sel)
            3'b000:  o_data = i_d0;
            3'b001:  o_data = i_d1;
            3'b010:  o_data = i_d2;
            3'b011:  o_data = i_d3;
            3'b100:  o_data = i_d4;
            3'b101:  o_data = i_d5;
            3'b110:  o_data = i_d6;
            3'b111:  o_data = i_d7;
            default: o_data = 1'b0;
        endcase
    end

endmodule