// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "lib/forge-std/src/Test.sol";

import "src/MooniFactory.sol";
import "src/Mooniswap.sol";
import "src/MooniRouter.sol";

import {TokenCustomDecimalsMock} from "src/mocks/TokenCustomDecimalsMock.sol";
import {TokenWithBytes32SymbolMock} from "src/mocks/TokenWithBytes32SymbolMock.sol";
import {TokenWithStringSymbolMock} from "src/mocks/TokenWithStringSymbolMock.sol";
import {TokenWithNoSymbolMock} from "src/mocks/TokenWithNoSymbolMock.sol";
import {TokenWithBytes32CAPSSymbolMock} from "src/mocks/TokenWithBytes32CAPSSymbolMock.sol";
import {WETH9} from "src/mocks/WETH9.sol";
// import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract MooniRouterTest is Test {
    TokenCustomDecimalsMock token1;
    TokenCustomDecimalsMock token2;
    MooniFactory factory;
    MooniRouter router;

    function setUp() public {
      factory = new MooniFactory();
      factory.setFee(0.003e18);
      token1 = new TokenCustomDecimalsMock(
        "Token One",
        "TOK1",
        10**21,
        18
      );
      token2 = new TokenCustomDecimalsMock(
        "Token Two",
        "TOK2",
        10**21,
        18
      );
      WETH9 weth = new WETH9();
      assertEq(token1.balanceOf(address(this)),10**21);
      assertEq(token2.balanceOf(address(this)),10**21);
      assertEq(weth.balanceOf(address(this)),0);
      assertEq(factory.MAX_FEE(),factory.fee());
      router = new MooniRouter(address(factory),address(weth));

    }

    // function testBasicDeploy() public {

    //   Mooniswap pool1 = Mooniswap(factory.deploy(IERC20(token1),IERC20(token2)));
    //   assertEq((pool1.getTokens()).length,2);
    // }
    function testAddLiquidity() public {

      Mooniswap pool1 = Mooniswap(factory.deploy(IERC20(token1),IERC20(token2)));
      assertEq((pool1.getTokens()).length,2);
      token1.approve(address(router),10**40);
      token2.approve(address(router),10**40);
      router.addLiquidity(address(token1),address(token2),10**18,10**18,0,0,address(this));
    }
    
    // function testSwap() public {

    //   Mooniswap pool1 = Mooniswap(factory.deploy(IERC20(token1),IERC20(token2)));
    //   assertEq((pool1.getTokens()).length,2);
    // }
}


