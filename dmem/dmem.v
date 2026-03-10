// データメモリ
// 32768 x 16bitのメモリ
// 非同期読み出し、同期書き込み（シングルサイクルCPUに対応するため，非同期読み出し）

module dmem (
    input  wire        i_clk,
    input  wire [15:0] i_addr,
    input  wire        i_wen,
    input  wire [15:0] i_data,
    output wire [15:0] o_data
    );
    
    //データメモリ本体
    // 32768 x 16bitのメモリ
    reg [15:0] datamem [31:0];//[32767:0];
    reg [15:0] o;

    // バイトアドレッシング対応
    // wire [15:0] addr;
    // assign addr = {1'b0, i_addr[15:1]}; // 下位1ビットを無視してアドレスを取得

    wire [4:0] addr_extract;
    assign addr_extract = i_addr[4:0]; // 下位5ビット
    
    //非同期読み出し
    assign o_data = datamem[addr_extract];

    // //同期読み出し
    // assign o_data = o;
    // always @(posedge i_clk) begin
    //     if (!i_wen) begin
    //         o <= datamem[addr_extract];
    //     end
    // end

    //データの初期化
    initial begin
        
        $readmemh("dmem/datamem.dat", datamem);

        // $monitor("dmem[0]:%d, dmem[1]:%d, stack (dmem[129~]): %d, a:%d, b:%d, c:%d, d:%d, e:%d, f:%d, g:%d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d"
        //  ,datamem[0], datamem[1], datamem[129], datamem[130], datamem[131], datamem[132], datamem[133]
        //  , datamem[134], datamem[135], datamem[136], datamem[137], datamem[138], datamem[139]
        //  , datamem[140], datamem[141], datamem[142], datamem[143], datamem[144], datamem[145]
        //  , datamem[146], datamem[147], datamem[148], datamem[149], datamem[150], datamem[151]);
    end    

    //書き込み
    always @(posedge i_clk) begin
        if (i_wen) begin
            datamem[addr_extract] <= i_data;
        end
    end

    
endmodule