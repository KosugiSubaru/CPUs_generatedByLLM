module alu_16bit_mux8 (
    input  wire [15:0] i_data0, // Addition result
    input  wire [15:0] i_data1, // Subtraction result
    input  wire [15:0] i_data2, // AND result
    input  wire [15:0] i_data3, // OR result
    input  wire [15:0] i_data4, // XOR result
    input  wire [15:0] i_data5, // NOT result
    input  wire [15:0] i_data6, // SRA result
    input  wire [15:0] i_data7, // SLA result
    input  wire [2:0]  i_sel,   // Opcode [2:0]
    output wire [15:0] o_data
);

    // 8つの演算結果から、セレクタ信号に基づいて1つを選択する
    assign o_data = (i_sel == 3'b000) ? i_data0 :
                    (i_sel == 3'b001) ? i_data1 :
                    (i_sel == 3'b010) ? i_data2 :
                    (i_sel == 3'b011) ? i_data3 :
                    (i_sel == 3'b100) ? i_data4 :
                    (i_sel == 3'b101) ? i_data5 :
                    (i_sel == 3'b110) ? i_data6 :
                                       i_data7;

endmodule