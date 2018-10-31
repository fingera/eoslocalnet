#include <eosiolib/eosio.hpp>

using namespace eosio;

CONTRACT hello : public eosio::contract {
  public:
    using contract::contract;

    ACTION hi() {
      print("Hello111");
    }

    ACTION fuck() {
      print("fuck");
    }
};

EOSIO_DISPATCH( hello, (hi)(fuck) )
