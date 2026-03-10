module tb_top;

    // クロックとリセット信号の生成
    reg i_clk;
    reg i_rst_n;

    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk; // 10ns周期のクロック
    end

    initial begin
        i_rst_n = 0;
        #15; // 15ns後にリセット解除
        i_rst_n = 1;
    end

    // topモジュールのインスタンス化
    top uut (
        .i_clk   (i_clk   ),
        .i_rst_n (i_rst_n )
    );

    // シミュレーションの終了条件
    initial begin
        #5000; // 1000ns後にシミュレーション終了
        $finish;
    end 

    // 波形の記録
    initial begin
        $dumpfile("tb_top_gen.vcd");
        $dumpvars(0, tb_top);
    end

endmodule