// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
// import "lib/openzeppelin-contracts/contracts/utils/Create2.sol";
import "./libraries/UniERC20.sol";
import "./Mooniswap.sol";
import "./interfaces/IMooniswap.sol";


contract MooniFactory is Ownable {
    using UniERC20 for IERC20;

    event Deployed(
        address indexed mooniswap,
        address indexed token1,
        address indexed token2
    );

    uint256 public constant MAX_FEE = 0.003e18; // 0.3%

    uint256 public fee;
    address[] public allPools;
    mapping(address => bool) public isPool;
    mapping(IERC20 => mapping(IERC20 => address)) public pools;

    function getAllPools() external view returns (address[] memory) {
        return allPools;
    }

    function setFee(uint256 newFee) external onlyOwner {
        require(newFee <= MAX_FEE, "Factory: fee should be <= 0.3%");
        fee = newFee;
    }
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }
    function pairFor(address tokenA, address tokenB) public view returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        bytes memory bytecode = type(Mooniswap).creationCode;
        pair = address(uint160(bytes20(keccak256(abi.encodePacked(
                bytes1(0xff),///// or hex'ff'
                address(this),
                keccak256(abi.encodePacked(token0, token1)),
                keccak256(bytecode)
                 
            )))));
    }
    function pairFor2(address tokenA, address tokenB) public view returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint160(bytes20(keccak256(abi.encodePacked(
                bytes1(0xff),///// or hex'ff'
                address(this),
                keccak256(abi.encodePacked(token0, token1)),
                hex'f6b7a53515d4dff4d63558837a72095dc587e3f77f73911d4ced3c28149f2fcd' // init code hash
            )))));
       
    }
//    pool = new Mooniswap(
   //         tokens,
  //          string(abi.encodePacked("Mooniswap V1 (", symbol1, "-", symbol2, ")")),
 //           string(abi.encodePacked("MOON-V1-", symbol1, "-", symbol2))
//        );
     
    function deploy(IERC20 tokenA, IERC20 tokenB) public  returns (address pair) {
        require(tokenA != tokenB, "Factory: not support same tokens");
        require(pools[tokenA][tokenB] == address(0), "Factory: pool already exists");

        (IERC20 token1, IERC20 token2) = sortTokens(tokenA, tokenB);
        IERC20[] memory tokens = new IERC20[](2);
        tokens[0] = token1;
        tokens[1] = token2;

        string memory symbol1 = token1.uniSymbol();
        string memory symbol2 = token2.uniSymbol();

        bytes32 salt = keccak256(abi.encodePacked(token1, token2));
        bytes memory POOL_NAME = abi.encodePacked("Mooniswap V1 (", symbol1, "-", symbol2, ")");
        bytes memory POOL_SYMBOL = abi.encodePacked("MOON-V1-", symbol1, "-", symbol2);

        pair = address(new Mooniswap{salt: salt}(string(POOL_NAME),string(POOL_SYMBOL)));
        IMooniswap(pair).initialize(tokens);
        IMooniswap(pair).transferOwnership(owner());
        //pool.transferOwnership(owner());
        pools[token1][token2] = pair;
        pools[token2][token1] = pair;
        allPools.push(pair);
        isPool[pair] = true;

        emit Deployed(
            address(pair),
            address(token1),
            address(token2)
        );
    }

    function sortTokens(IERC20 tokenA, IERC20 tokenB)
        public
        pure
        returns (IERC20, IERC20)
    {
        if (tokenA < tokenB) {
            return (tokenA, tokenB);
        }
        return (tokenB, tokenA);
    }
}
