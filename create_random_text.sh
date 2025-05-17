#!/bin/bash

# デフォルト値の設定
NUM_FILES=100
MIN_SIZE=1
MAX_SIZE=1024
OUTPUT_DIR="random_text_files"

# ランダムなテキストを生成するための文字列配列
WORDS=(
    "こんにちは" "世界" "プログラミング" "シェルスクリプト" "Linux"
    "システム" "ファイル" "データ" "テキスト" "ランダム"
    "生成" "処理" "実行" "開発" "テスト"
    "環境" "設定" "変数" "関数" "コマンド"
    "エラー" "成功" "完了" "開始" "終了"
    "情報" "警告" "デバッグ" "ログ" "出力"
    "入力" "保存" "読み込み" "書き込み" "削除"
    "作成" "更新" "変更" "確認" "検証"
    "最適化" "改善" "修正" "調整" "設定"
    "管理" "運用" "保守" "監視" "制御"
)

# ヘルプメッセージの表示
show_help() {
    echo "使用方法: $0 [オプション]"
    echo "オプション:"
    echo "  -n, --num-files NUM    作成するファイルの数（デフォルト: 100）"
    echo "  -m, --min-size SIZE    最小ファイルサイズ（KB単位、デフォルト: 1）"
    echo "  -M, --max-size SIZE    最大ファイルサイズ（KB単位、デフォルト: 1024）"
    echo "  -o, --output-dir DIR   出力ディレクトリ（デフォルト: random_text_files）"
    echo "  -h, --help             このヘルプメッセージを表示"
    exit 0
}

# コマンドライン引数の解析
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--num-files)
            NUM_FILES="$2"
            shift 2
            ;;
        -m|--min-size)
            MIN_SIZE="$2"
            shift 2
            ;;
        -M|--max-size)
            MAX_SIZE="$2"
            shift 2
            ;;
        -o|--output-dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo "エラー: 不明なオプション $1"
            show_help
            ;;
    esac
done

# 出力ディレクトリの作成
mkdir -p "$OUTPUT_DIR"

echo "$NUM_FILES個のテキストファイルを作成します..."
echo "サイズ範囲: ${MIN_SIZE}KB - ${MAX_SIZE}KB"
echo "出力ディレクトリ: $OUTPUT_DIR"

# ファイルの作成
for ((i=1; i<=NUM_FILES; i++)); do
    # ランダムなサイズを生成（バイト単位）
    size=$(( (RANDOM % (MAX_SIZE - MIN_SIZE + 1) + MIN_SIZE) * 1024 ))
    
    # ファイル名の生成（4桁の数字にパディング）
    filename=$(printf "random_text_%04d.txt" $i)
    
    # テキストファイルの作成
    {
        while [ $(stat -f %z "$OUTPUT_DIR/$filename" 2>/dev/null || echo 0) -lt $size ]; do
            # ランダムな行数を生成（1-10行）
            lines=$((RANDOM % 10 + 1))
            
            # 各行にランダムな単語を配置
            for ((j=0; j<lines; j++)); do
                # ランダムな単語数を生成（1-5単語）
                words=$((RANDOM % 5 + 1))
                line=""
                for ((k=0; k<words; k++)); do
                    word=${WORDS[$((RANDOM % ${#WORDS[@]}))]}
                    line+="$word "
                done
                echo "$line"
            done
        done
    } > "$OUTPUT_DIR/$filename"
    
    # 進捗表示（10ファイルごと）
    if [ $((i % 10)) -eq 0 ]; then
        echo "作成済み: $i/$NUM_FILES"
    fi
done

echo "完了しました！" 