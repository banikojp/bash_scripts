#!/bin/bash

# デフォルト値の設定
NUM_FILES=100
MIN_SIZE=1
MAX_SIZE=1024
OUTPUT_DIR="random_files"

# ヘルプメッセージの表示
show_help() {
    echo "使用方法: $0 [オプション]"
    echo "オプション:"
    echo "  -n, --num-files NUM    作成するファイルの数（デフォルト: 100）"
    echo "  -m, --min-size SIZE    最小ファイルサイズ（KB単位、デフォルト: 1）"
    echo "  -M, --max-size SIZE    最大ファイルサイズ（KB単位、デフォルト: 1024）"
    echo "  -o, --output-dir DIR   出力ディレクトリ（デフォルト: random_files）"
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

echo "$NUM_FILES個のファイルを作成します..."
echo "サイズ範囲: ${MIN_SIZE}KB - ${MAX_SIZE}KB"
echo "出力ディレクトリ: $OUTPUT_DIR"

# ファイルの作成
for ((i=1; i<=NUM_FILES; i++)); do
    # ランダムなサイズを生成（バイト単位）
    size=$(( (RANDOM % (MAX_SIZE - MIN_SIZE + 1) + MIN_SIZE) * 1024 ))
    
    # ファイル名の生成（4桁の数字にパディング）
    filename=$(printf "random_file_%04d.bin" $i)
    
    # ファイルの作成
    dd if=/dev/urandom of="$OUTPUT_DIR/$filename" bs=1 count=$size status=none
    
    # 進捗表示（10ファイルごと）
    if [ $((i % 10)) -eq 0 ]; then
        echo "作成済み: $i/$NUM_FILES"
    fi
done

echo "完了しました！" 