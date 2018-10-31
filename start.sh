
# 全局配置
WALLET_DIR=`pwd`/wallet
NODEOS=nodeos
KEOSD=keosd
CLEOS='cleos --wallet-url http://127.0.0.1:6666 --url http://127.0.0.1:8000'
PRIVATE_KEY=5K463ynhZoCDDa4RDcr63cUwWLTnKqmdcoTKTHBjqoKfv4u5V7p
PUBLIC_KEY=EOS8Znrtgwt8TfpmbVpTKvA2oB8Nqey625CLN8bCN3TEbgx86Dsvr
CONTRACTS_DIR=/mnt/d/Projects/eos/build/contracts
SYMBOL=SYS

BOOT_NODE=`pwd`/boot-node
BP1_NODE=`pwd`/bp1-node
BP2_NODE=`pwd`/bp2-node

COMMON_NODEOS_PARAM="--max-irreversible-block-age -1 --contracts-console \
  --genesis-json `pwd`/genesis.json --producer-name eosio --max-clients 8 \
  --p2p-max-nodes-per-host 10 --enable-stale-production \
  --chain-state-db-guard-size-mb 32 --chain-state-db-size-mb 128 \
  --reversible-blocks-db-guard-size-mb 32 --reversible-blocks-db-size-mb 128 "

COMMON_NODEOS_PLUGIN="--plugin eosio::http_plugin --plugin eosio::chain_api_plugin \
  --plugin eosio::producer_plugin --plugin eosio::history_plugin --plugin eosio::history_api_plugin \
  --plugin eosio::net_api_plugin"

# 初始化工作
killall keosd nodeos || true
rm -rf $WALLET_DIR
mkdir -p $WALLET_DIR

# 钱包
$KEOSD --unlock-timeout 999999999 --http-server-address 127.0.0.1:6666 --wallet-dir $WALLET_DIR 2>/dev/null >/dev/null &
$CLEOS wallet create --to-console
$CLEOS wallet import --private-key $PRIVATE_KEY
# bp1
$CLEOS wallet import --private-key 5JrE4MeUZCoZp4FgtS31cbyKuELNLeCHgDRjaHCHQCih6A2qajb
# bp2
$CLEOS wallet import --private-key 5Kim2SZtCjXBws9adAQSPgjVMyDhTwybpZus9g4bDCWxb24RBsM


echo $COMMON_NODEOS_PARAM
# 启动节点
rm -rf $BOOT_NODE
mkdir -p $BOOT_NODE
$NODEOS $COMMON_NODEOS_PARAM --blocks-dir $BOOT_NODE/blocks --config-dir $BOOT_NODE \
  --data-dir $BOOT_NODE --http-server-address 127.0.0.1:8000 --p2p-listen-endpoint 127.0.0.1:9000 \
  ${COMMON_NODEOS_PLUGIN} --private-key "[\"$PUBLIC_KEY\",\"$PRIVATE_KEY\"]" \
  2>$BOOT_NODE/stderr.log 1>$BOOT_NODE/stdout.log &

sleep 10

# 创建基本账户
$CLEOS create account eosio eosio.bpay $PUBLIC_KEY
$CLEOS create account eosio eosio.msig $PUBLIC_KEY
$CLEOS create account eosio eosio.token $PUBLIC_KEY
$CLEOS create account eosio eosio.ram $PUBLIC_KEY
$CLEOS create account eosio eosio.ramfee $PUBLIC_KEY
$CLEOS create account eosio eosio.saving $PUBLIC_KEY
$CLEOS create account eosio eosio.stake $PUBLIC_KEY
$CLEOS create account eosio eosio.vpay $PUBLIC_KEY
$CLEOS create account eosio eosio.names $PUBLIC_KEY

# 设置基本合约
$CLEOS set contract eosio.token $CONTRACTS_DIR/eosio.token/
$CLEOS set contract eosio.msig $CONTRACTS_DIR/eosio.msig/
$CLEOS push action eosio.token create "[\"eosio\", \"10000000000.0000 $SYMBOL\"]" -p eosio.token
$CLEOS push action eosio.token issue "[\"eosio\", \"999999999.9998 $SYMBOL\", \"memo\"]" -p eosio
$CLEOS set contract eosio $CONTRACTS_DIR/eosio.system/
$CLEOS push action eosio setpriv '["eosio.msig", 1]' -p eosio@active

# 创建普通用户
$CLEOS system newaccount --transfer eosio fingera $PUBLIC_KEY --stake-net "1000.0000 $SYMBOL" --stake-cpu "1000.0000 $SYMBOL" --buy-ram "1000.0000 $SYMBOL"
$CLEOS transfer eosio fingera "100000.0000 $SYMBOL"
$CLEOS system newaccount --transfer eosio lyjstudy $PUBLIC_KEY --stake-net "1000.0000 $SYMBOL" --stake-cpu "1000.0000 $SYMBOL" --buy-ram "1000.0000 $SYMBOL"
$CLEOS transfer eosio lyjstudy "100000.0000 $SYMBOL"

# 创建BP账户
# 5JrE4MeUZCoZp4FgtS31cbyKuELNLeCHgDRjaHCHQCih6A2qajb
$CLEOS system newaccount --transfer eosio bp1 EOS8CGqUDvKFftcdeRhysXUhSuFQf8PsJZEPVi4kiZRCkTMUMtaY9 --stake-net "10000.0000 $SYMBOL" --stake-cpu "10000.0000 $SYMBOL" --buy-ram "10000.0000 $SYMBOL"
$CLEOS transfer eosio bp1 "10000.0000 $SYMBOL"
$CLEOS system regproducer bp1 EOS8CGqUDvKFftcdeRhysXUhSuFQf8PsJZEPVi4kiZRCkTMUMtaY9 https://bp1.com/
# 5Kim2SZtCjXBws9adAQSPgjVMyDhTwybpZus9g4bDCWxb24RBsM
$CLEOS system newaccount --transfer eosio bp2 EOS8KUjkygUmeWviopVZZdFAVLE9ntUqxrHNaFs5bh7NG8a5KnBN2 --stake-net "10000.0000 $SYMBOL" --stake-cpu "10000.0000 $SYMBOL" --buy-ram "10000.0000 $SYMBOL"
$CLEOS transfer eosio bp2 "10000.0000 $SYMBOL"
$CLEOS system regproducer bp2 EOS8KUjkygUmeWviopVZZdFAVLE9ntUqxrHNaFs5bh7NG8a5KnBN2 https://bp1.com/
# 启动BP节点 并 投票


# 删除关键账户密钥
$CLEOS push action eosio updateauth '{"account": "eosio", "permission": "owner", "parent": "", "auth": {"threshold": 1, "keys": [], "waits": [], "accounts": [{"weight": 1, "permission": {"actor": "eosio.prods", "permission": "active"}}]}}' -p eosio@owner
$CLEOS push action eosio updateauth '{"account": "eosio", "permission": "active", "parent": "owner", "auth": {"threshold": 1, "keys": [], "waits": [], "accounts": [{"weight": 1, "permission": {"actor": "eosio.prods", "permission": "active"}}]}}' -p eosio@active
$CLEOS get account eosio
$CLEOS push action eosio updateauth '{"account": "eosio.bpay", "permission": "owner", "parent": "", "auth": {"threshold": 1, "keys": [], "waits": [], "accounts": [{"weight": 1, "permission": {"actor": "eosio", "permission": "active"}}]}}' -p eosio.bpay@owner
$CLEOS push action eosio updateauth '{"account": "eosio.bpay", "permission": "active", "parent": "owner", "auth": {"threshold": 1, "keys": [], "waits": [], "accounts": [{"weight": 1, "permission": {"actor": "eosio", "permission": "active"}}]}}' -p eosio.bpay@active
$CLEOS get account eosio.bpay
$CLEOS push action eosio updateauth '{"account": "eosio.msig", "permission": "owner", "parent": "", "auth": {"threshold": 1, "keys": [], "waits": [], "accounts": [{"weight": 1, "permission": {"actor": "eosio", "permission": "active"}}]}}' -p eosio.msig@owner
$CLEOS push action eosio updateauth '{"account": "eosio.msig", "permission": "active", "parent": "owner", "auth": {"threshold": 1, "keys": [], "waits": [], "accounts": [{"weight": 1, "permission": {"actor": "eosio", "permission": "active"}}]}}' -p eosio.msig@active
$CLEOS get account eosio.msig
$CLEOS push action eosio updateauth '{"account": "eosio.names", "permission": "owner", "parent": "", "auth": {"threshold": 1, "keys": [], "waits": [], "accounts": [{"weight": 1, "permission": {"actor": "eosio", "permission": "active"}}]}}' -p eosio.names@owner
$CLEOS push action eosio updateauth '{"account": "eosio.names", "permission": "active", "parent": "owner", "auth": {"threshold": 1, "keys": [], "waits": [], "accounts": [{"weight": 1, "permission": {"actor": "eosio", "permission": "active"}}]}}' -p eosio.names@active
$CLEOS get account eosio.names
$CLEOS push action eosio updateauth '{"account": "eosio.ram", "permission": "owner", "parent": "", "auth": {"threshold": 1, "keys": [], "waits": [], "accounts": [{"weight": 1, "permission": {"actor": "eosio", "permission": "active"}}]}}' -p eosio.ram@owner
$CLEOS push action eosio updateauth '{"account": "eosio.ram", "permission": "active", "parent": "owner", "auth": {"threshold": 1, "keys": [], "waits": [], "accounts": [{"weight": 1, "permission": {"actor": "eosio", "permission": "active"}}]}}' -p eosio.ram@active
$CLEOS get account eosio.ram
$CLEOS push action eosio updateauth '{"account": "eosio.ramfee", "permission": "owner", "parent": "", "auth": {"threshold": 1, "keys": [], "waits": [], "accounts": [{"weight": 1, "permission": {"actor": "eosio", "permission": "active"}}]}}' -p eosio.ramfee@owner
$CLEOS push action eosio updateauth '{"account": "eosio.ramfee", "permission": "active", "parent": "owner", "auth": {"threshold": 1, "keys": [], "waits": [], "accounts": [{"weight": 1, "permission": {"actor": "eosio", "permission": "active"}}]}}' -p eosio.ramfee@active
$CLEOS get account eosio.ramfee
$CLEOS push action eosio updateauth '{"account": "eosio.saving", "permission": "owner", "parent": "", "auth": {"threshold": 1, "keys": [], "waits": [], "accounts": [{"weight": 1, "permission": {"actor": "eosio", "permission": "active"}}]}}' -p eosio.saving@owner
$CLEOS push action eosio updateauth '{"account": "eosio.saving", "permission": "active", "parent": "owner", "auth": {"threshold": 1, "keys": [], "waits": [], "accounts": [{"weight": 1, "permission": {"actor": "eosio", "permission": "active"}}]}}' -p eosio.saving@active
$CLEOS get account eosio.saving
$CLEOS push action eosio updateauth '{"account": "eosio.stake", "permission": "owner", "parent": "", "auth": {"threshold": 1, "keys": [], "waits": [], "accounts": [{"weight": 1, "permission": {"actor": "eosio", "permission": "active"}}]}}' -p eosio.stake@owner
$CLEOS push action eosio updateauth '{"account": "eosio.stake", "permission": "active", "parent": "owner", "auth": {"threshold": 1, "keys": [], "waits": [], "accounts": [{"weight": 1, "permission": {"actor": "eosio", "permission": "active"}}]}}' -p eosio.stake@active
$CLEOS get account eosio.stake
$CLEOS push action eosio updateauth '{"account": "eosio.token", "permission": "owner", "parent": "", "auth": {"threshold": 1, "keys": [], "waits": [], "accounts": [{"weight": 1, "permission": {"actor": "eosio", "permission": "active"}}]}}' -p eosio.token@owner
$CLEOS push action eosio updateauth '{"account": "eosio.token", "permission": "active", "parent": "owner", "auth": {"threshold": 1, "keys": [], "waits": [], "accounts": [{"weight": 1, "permission": {"actor": "eosio", "permission": "active"}}]}}' -p eosio.token@active
$CLEOS get account eosio.token
$CLEOS push action eosio updateauth '{"account": "eosio.vpay", "permission": "owner", "parent": "", "auth": {"threshold": 1, "keys": [], "waits": [], "accounts": [{"weight": 1, "permission": {"actor": "eosio", "permission": "active"}}]}}' -p eosio.vpay@owner
$CLEOS push action eosio updateauth '{"account": "eosio.vpay", "permission": "active", "parent": "owner", "auth": {"threshold": 1, "keys": [], "waits": [], "accounts": [{"weight": 1, "permission": {"actor": "eosio", "permission": "active"}}]}}' -p eosio.vpay@active
$CLEOS get account eosio.vpay