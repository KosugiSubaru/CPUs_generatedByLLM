submodules:
program_counter: 現在の命令アドレス（PC）を保持し、クロック同期で更新する。
instruction_decoder: 命令をビットフィールドごとに分解し、ALU演算、レジスタ書き込み、メモリ制御などの信号を生成する。
register_file: 16個の16bitレジスタを保持する。2つの独立した読み出しポートと、1つの書き込みポートを備える。
alu_core: 加減算、論理演算、ビットシフトを実行し、演算結果と演算フラグ（Z, N, V）を出力する。
flag_register: ALUが生成したフラグを保持し、1クロック遅延させて分岐判定ユニットへ供給する。
imm_generator: 命令形式（I-type, Load/Store, Branch等）に応じて、即値フィールドを抽出し、符号拡張して16bitデータにする。
pc_adder: 次の命令アドレス（PC+2）や、相対分岐先（PC+imm）を計算するための加算器。
next_pc_selector: 分岐条件の成立、ジャンプ命令、または通常実行に応じて、次にPCへセットする値を選択する。
alu_src_selector: ALUの第2入力（Operand B）として、レジスタの出力（rs2）と即値（imm）のどちらを使用するかを選択する。
reg_write_data_selector: レジスタファイルに書き戻す値を、ALUの演算結果、データメモリからの読み出し値、PC+2の中から選択する。
dmem_interface_logic: 命令（Load/Store）に基づいて、データメモリへのアドレス、書き込みデータ、書き込み有効信号を制御する。