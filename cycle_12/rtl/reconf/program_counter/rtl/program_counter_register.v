module program_counter_register (
        input  wire        i_clk,
        input  wire        i_rst_n,
        input  wire [15:0] i_next_pc,
        output wire [15:0] o_pc_now
    );

        reg [15:0] r_pc;

        assign o_pc_now = r_pc;

        always @(posedge i_clk) begin
            if (!i_rst_n) begin
                r_pc <= 16'h0000;
            end else begin
                r_pc <= i_next_pc;
            end
        end

    endmodule