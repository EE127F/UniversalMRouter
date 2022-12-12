// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Mooniswap} from "src/Mooniswap.sol";

library PairInitCode {
 
  bytes constant PAIR_INIT_CODE = type(Mooniswap).creationCode;
  bytes32 constant PAIR_INIT_CODE_HASH = keccak256(PAIR_INIT_CODE);
}
