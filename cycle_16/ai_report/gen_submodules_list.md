submodules:
pc_unit: 現在の命令アドレス（Program Counter）を保持し、次のクロックで更新する
instruction_decoder: 16ビットの命令を解析し、各モジュールへの制御信号（ALU演算種別、レジスタ/メモリ書き込み許可等）を生成する
register_file: 16ビット×16個のレジスタを管理し、2つのレジスタ読み出しと1つの書き込みを同時に行う
immediate_generator: 命令の各形式（I-type, Load/Store, Branch, Jump等）に合わせて即値を抽出し、符号拡張を行う
alu_core: 算術演算（加減算）、論理演算（AND/OR/XOR/NOT）、シフト演算を行い、演算結果とフラグ（Z, N, V）を出力する
flag_register: ALUが出力したフラグ（Z, N, V）を1クロック保持し、次命令の分岐判定に提供する
next_pc_logic: 命令の種類とフラグ状態に基づき、次のPC（PC+2、分岐先、ジャンプ先）を決定する
writeback_mux: レジスタファイルに書き込むデータを、ALU演算結果、メモリ読み出しデータ、即値、またはPC+2（戻りアドレス）の中から選択する