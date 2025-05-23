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
    "生成する" "処理する" "実行する" "開発する" "テストする"
    "環境" "設定" "変数" "関数" "コマンド"
    "エラー" "成功" "完了" "開始" "終了"
    "情報" "警告" "デバッグ" "ログ" "出力"
    "入力" "保存" "読み込み" "書き込み" "削除"
    "作成" "更新" "変更" "確認" "検証"
    "最適化" "改善" "修正" "調整" "設定"
    "管理" "運用" "保守" "監視" "制御"
    "分析" "評価" "計画" "設計" "実装"
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

# 入力値の検証
if ! [[ "$NUM_FILES" =~ ^[1-9][0-9]*$ ]]; then
    echo "エラー: ファイル数は正の整数である必要があります。"
    exit 1
fi

if ! [[ "$MIN_SIZE" =~ ^[1-9][0-9]*$ ]]; then
    echo "エラー: 最小ファイルサイズは正の整数である必要があります。"
    exit 1
fi

if ! [[ "$MAX_SIZE" =~ ^[1-9][0-9]*$ ]]; then
    echo "エラー: 最大ファイルサイズは正の整数である必要があります。"
    exit 1
fi

if [ "$MIN_SIZE" -gt "$MAX_SIZE" ]; then
    echo "エラー: 最小ファイルサイズは最大ファイルサイズ以下である必要があります。"
    exit 1
fi

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
    # size はターゲットサイズ（バイト単位）
    FILE_CONTENT="" 

    if [ "$size" -eq 0 ]; then
        touch "$OUTPUT_DIR/$filename"
    else
        # CURRENT_BYTE_SIZE_OF_FILE_CONTENT_AS_ECHOED は、`echo "$FILE_CONTENT"` を実行した場合のバイトサイズを追跡します。
        CURRENT_BYTE_SIZE_OF_FILE_CONTENT_AS_ECHOED=0

        while true; do
            # 1. 新しい候補行のテキストを生成 (NEW_LINE_TEXT、末尾の改行なし)
            NUM_WORDS_IN_LINE=$((RANDOM % 5 + 1))
            NEW_LINE_TEXT=""
            for ((k=0; k<NUM_WORDS_IN_LINE; k++)); do
                WORD=${WORDS[$((RANDOM % ${#WORDS[@]}))]}
                NEW_LINE_TEXT+="$WORD "
            done
            NEW_LINE_TEXT=${NEW_LINE_TEXT% } # 末尾のスペースを削除

            # 2. NEW_LINE_TEXT が追加された場合の予測バイトサイズを計算
            PROSPECTIVE_BYTE_SIZE=0
            if [ -z "$FILE_CONTENT" ]; then # FILE_CONTENT が現在空の場合
                if [ -z "$NEW_LINE_TEXT" ]; then # NEW_LINE_TEXT も空の場合
                    PROSPECTIVE_BYTE_SIZE=1 # echo "" | wc -c は 1 (改行のみのため)
                else
                    PROSPECTIVE_BYTE_SIZE=$(echo "$NEW_LINE_TEXT" | wc -c)
                fi
            else # FILE_CONTENT に既存のテキストがある場合
                # (FILE_CONTENT + \n + NEW_LINE_TEXT) をエコーした場合のサイズを計算
                PROSPECTIVE_BYTE_SIZE=$(echo "$FILE_CONTENT"$'\n'"$NEW_LINE_TEXT" | wc -c)
            fi

            # 3. 判断ロジック
            # ケース A: 最初の行で、かつ、その行だけでサイズを超える場合
            if [ -z "$FILE_CONTENT" ] && [ $PROSPECTIVE_BYTE_SIZE -gt $size ]; then
                if [ $size -gt 0 ]; then
                    # 最初の行が大きすぎる場合、ファイルが空でないことだけを保証します。
                    # 大きすぎる行を書き込む代わりに、FILE_CONTENTを空のままにしておき、
                    # ループ後のロジックで1バイトのファイル(改行のみ)を作成するようにします。
                    FILE_CONTENT="" 
                fi
                break # ループを終了
            fi

            # ケース B: NEW_LINE_TEXT を追加すると目標サイズを超える場合
            if [ $PROSPECTIVE_BYTE_SIZE -gt $size ]; then
                break # この NEW_LINE_TEXT は追加しません。現在の FILE_CONTENT が最適です。
            fi

            # ケース C: NEW_LINE_TEXT を受け入れる
            if [ -z "$FILE_CONTENT" ]; then
                FILE_CONTENT="$NEW_LINE_TEXT"
            else
                FILE_CONTENT+=$'\n'"$NEW_LINE_TEXT"
            fi
            CURRENT_BYTE_SIZE_OF_FILE_CONTENT_AS_ECHOED=$PROSPECTIVE_BYTE_SIZE

            # ケース D: 目標サイズに完全に一致した場合
            if [ $CURRENT_BYTE_SIZE_OF_FILE_CONTENT_AS_ECHOED -eq $size ]; then
                break
            fi
        done

        # 4. 蓄積された内容を実際のファイルに書き込む
        if [ -n "$FILE_CONTENT" ]; then
            echo "$FILE_CONTENT" > "$OUTPUT_DIR/$filename"
        elif [ $size -gt 0 ]; then
            # FILE_CONTENT は空のままだが、目標サイズが0より大きい場合。
            # (例: 最初の NEW_LINE_TEXT が空で、ループがすぐに終了した場合など)
            # 少なくとも1バイトのファイルを作成するために改行のみを書き込みます。
            echo > "$OUTPUT_DIR/$filename"
        fi
        # sizeが0の場合は、既に上で touch で処理済みです。
    fi
    
    # 進捗表示（10ファイルごと）
    if [ $((i % 10)) -eq 0 ]; then
        echo "作成済み: $i/$NUM_FILES"
    fi
done

echo "完了しました！" 