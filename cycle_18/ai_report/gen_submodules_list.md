submodules:
program_counter: 次に実行する命令のアドレス（PC）を保持し、クロック同期で値を更新する。
control_unit: 命令のopcodeをデコードし、ALUの演算種別や各レジスタ・メモリの書き込み許可等の制御信号を生成する。
register_file: 16本の16ビットレジスタを管理し、非同期の2ポート読み出しと同期の1ポート書き込み（R0は常に0）を行う。
immediate_generator: 命令の種類（I/L/S/B/J-type）に応じて即値フィールドを抽出し、16ビットに符号拡張する。
alu_main: 算術、論理、および算術シフト演算を実行し、演算結果とフラグ（Z, N, V）を生成する。
flag_register: 「条件分岐は1クロック前のフラグを参照する」という仕様に基づき、ALUフラグを1サイクル遅延させて保持する。
pc_selector: 通常のインクリメント（PC+2）、条件分岐（PC+imm）、ジャンプ（PC+imm / rs1+imm）から次のPC値を選択・算出する。