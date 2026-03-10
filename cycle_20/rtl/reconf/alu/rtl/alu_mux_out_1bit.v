module alu_mux_out_1bit (
    input  wire [3:0] i_sel,
    input  wire       i_adder,
    input  wire       i_logic,
    input  wire       i_shifter,
    input  wire       i_pass_b,
    output wire       o_res
);

    // 各命令のopcode(alu_op)に対応する演算結果を選択
    // i_logic: and(0010), or(0011), xor(0100), not(0101)
    // i_shifter: sra(0110), sla(0111)
    // i_pass_b: loadi(1001)
    // i_adder: add(0000), sub(0001), addi(1000), load(1010), store(1011), jalr(1111)

    assign o_res = (i_sel == 4'b0010 || i_sel == 4'b0011 || i_sel == 4'b0100 || i_sel == 4'b0101) ? i_logic :
                   (i_sel == 4'b0110 || i_sel == 4'b0111) ? i_shifter :
                   (i_sel == 4'b1001)                     ? i_pass_b  :
                   i_adder;

endmodule