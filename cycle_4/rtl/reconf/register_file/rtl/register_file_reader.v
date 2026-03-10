module register_file_reader (
    input  wire [255:0] i_data_bus,
    input  wire [3:0]   i_addr,
    output reg  [15:0]  o_data
);

    always @(*) begin
        case (i_addr)
            4'h0: o_data = i_data_bus[15:0];
            4'h1: o_data = i_data_bus[31:16];
            4'h2: o_data = i_data_bus[47:32];
            4'h3: o_data = i_data_bus[63:48];
            4'h4: o_data = i_data_bus[79:64];
            4'h5: o_data = i_data_bus[95:80];
            4'h6: o_data = i_data_bus[111:96];
            4'h7: o_data = i_data_bus[127:112];
            4'h8: o_data = i_data_bus[143:128];
            4'h9: o_data = i_data_bus[159:144];
            4'hA: o_data = i_data_bus[175:160];
            4'hB: o_data = i_data_bus[191:176];
            4'hC: o_data = i_data_bus[207:192];
            4'hD: o_data = i_data_bus[223:208];
            4'hE: o_data = i_data_bus[239:224];
            4'hF: o_data = i_data_bus[255:240];
            default: o_data = 16'h0000;
        endcase
    end

endmodule