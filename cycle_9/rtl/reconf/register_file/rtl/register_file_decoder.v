module register_file_decoder (
    input  wire [3:0]  i_addr,
    input  wire        i_we,
    output wire [15:0] o_we_bus
);

    assign o_we_bus[0]  = i_we & (i_addr == 4'd0);
    assign o_we_bus[1]  = i_we & (i_addr == 4'd1);
    assign o_we_bus[2]  = i_we & (i_addr == 4'd2);
    assign o_we_bus[3]  = i_we & (i_addr == 4'd3);
    assign o_we_bus[4]  = i_we & (i_addr == 4'd4);
    assign o_we_bus[5]  = i_we & (i_addr == 4'd5);
    assign o_we_bus[6]  = i_we & (i_addr == 4'd6);
    assign o_we_bus[7]  = i_we & (i_addr == 4'd7);
    assign o_we_bus[8]  = i_we & (i_addr == 4'd8);
    assign o_we_bus[9]  = i_we & (i_addr == 4'd9);
    assign o_we_bus[10] = i_we & (i_addr == 4'd10);
    assign o_we_bus[11] = i_we & (i_addr == 4'd11);
    assign o_we_bus[12] = i_we & (i_addr == 4'd12);
    assign o_we_bus[13] = i_we & (i_addr == 4'd13);
    assign o_we_bus[14] = i_we & (i_addr == 4'd14);
    assign o_we_bus[15] = i_we & (i_addr == 4'd15);

endmodule