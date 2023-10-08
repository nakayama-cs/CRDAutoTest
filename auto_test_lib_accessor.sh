#!/bin/bash

function autoTestGet() {
    echo $(echo $1 | jq -r $2)
}

function autoTestHasKeyValue() {
    echo $(echo $1 | sed -nE "s/.*\"${2}\":\s*\"(${3})\".*/\1/p" | tail -n 1)
}

#
# jsonを指定filterで抽出したデータに検査文字列が1つ以上含まれているかを検査します
# 
# 引数:
#   $1 json文字列
#   $2 jqのfilter (例: .items[].tokyoShokoResearchId)
#   $3 検査文字列
# 返却値:
#   jsonを指定filterで抽出したデータに検査文字列が1つ以上含まれている場合はOK、それ以外は空文字を返却します。
#
function autoTestExistsValue() {
    echo $(echo $1 | jq -r "${2}" | sed -n "s/^\(${3}\)$/OK/p")
}

#
# jsonを指定filterで抽出したデータに検査文字列以外が含まれているかを検査します
# 
# 引数:
#   $1 json文字列
#   $2 jqのfilter (例: .items[].tokyoShokoResearchId)
#   $3 検査文字列 (例1: "1234", 例2: "foo\|hoge")
# 返却値:
#   jsonの指定filterで抽出したデータに検査文字列が含まれていない場合はOK、それ以外は空文字を返却します。
#
function autoTestContainAnother() {
    result=$(echo $1 | jq -r "${2}" | sed -z 's/\n/,/g' | sed "s/${3}//g" | sed "s/,//g")
    if [ ! -z $result ]; then
        echo "OK"
    fi
}