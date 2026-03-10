module register_file_mux_16to1 (
    input  wire [255:0] i_data_bus,
    input  wire [3:0]   i_sel,
    output wire [15:0]  o_data
);

    wire [63:0] w_mux_l1_out;

    // Level 1: 16個の入力を4入力ずつの4グループに分け、下位2ビットのアドレスで各グループから1つを選択
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_mux_l1
            register_file_mux_4to1 u_mux_l1 (
                .i_data0 (i_data_bus[(64*i) + 16*0 +: 16]),
                .i_data1 (i_data_bus[(64*i) + 16*1 +: 16]),
                .i_data2 (i_data_bus[(64*i) + 16*2 +: 16]),
                .i_data3 (i_data_bus[(64*i) + 16*3 +: 16]),
                .i_sel   (i_sel[1:0]),
                .o_data  (w_mux_l1_out[16*i +: 16])
            );
        end
    endgenerate

    // Level 2: Level 1で選ばれた4つのデータから、上位2ビットのアドレスで最終的な1つを選択
    register_file_mux_4to1 u_mux_l2 (
        .i_data0 (w_mux_l1_out[15:0]),
        .i_data1 (w_mux_l1_out[31:16]),
        .i_data2 (w_mux_l1_out[47:32]),
        .i_data3 (w_mux_l1_out[63:48]),
        .i_sel   (i_sel[3:2]),
        .o_data  (o_data)
    );

endmodule