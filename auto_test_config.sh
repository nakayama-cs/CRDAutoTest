# デフォルトのパスを設定
if [ -z $EXEC_PATH ]; then
    export EXEC_PATH="./cmd/mtechnavi-cli/"
fi

function autoTestConfigExecPath() {
    export EXEC_PATH=$1
}