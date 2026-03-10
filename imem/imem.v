module imem (
    input  wire         clk,
    input  wire [15:0]  i_addr,
    output wire [15:0]  o_instr
    );

    //命令メモリ本体
    reg [15:0] instmem [511:0];//[32767:0];
    reg [15:0] i;

    // バイトアドレッシング対応
    wire [15:0] addr; 
    assign addr = {1'b0, i_addr[15:1]}; // 下位1ビットを無視

    wire [8:0] addr_extract;
    assign addr_extract = addr[8:0]; // 下位9ビット
    
    //非同期読み出し
    // assign o_instr = instmem[addr_extract];

    //同期読み出し
    assign o_instr = i;
    always@ (posedge clk) begin
        i <= instmem[addr_extract];
    end

    //初期化
    initial begin
        $readmemb("imem/machine_code_bin.dat", instmem);
    end

    
endmodule