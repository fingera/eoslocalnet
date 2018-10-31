
CLEOS='cleos --wallet-url http://127.0.0.1:6666 --url http://127.0.0.1:8000'

pushd hello
cmake .
make
popd

$CLEOS set contract fingera hello