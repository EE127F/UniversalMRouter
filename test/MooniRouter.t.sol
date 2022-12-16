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
import {MockSOHM} from "src/mocks/MockSOHM.sol";
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

      address[] memory path = new address[](2);
      path[0] = address(token1);
      path[1] = address(token2);

      router.swapExactTokensForTokens(10**12,0,path,msg.sender,address(0));
    }
    function testFunctionality() public {

      MockSOHM rebasingToken1 = new MockSOHM(
                10**27,
                10*10**9 //rebase %
              );
      MockSOHM rebasingToken2 = new MockSOHM(
                10**27,
                10*10**9 //rebase %
              );

      MockSOHM(rebasingToken1).mint(msg.sender,10**21); 
      MockSOHM(rebasingToken2).mint(msg.sender,10**21); 

      // WETH9 weth = new WETH9();

      // MooniFactory factory = new MooniFactory();
      // factory.setFee(0.003e18);

      // MooniRouter router = new MooniRouter(address(factory),address(weth));

      console.logAddress(address(router));

      // IERC20(token1).approve(address(router),10**40);
      // IERC20(token2).approve(address(router),10**40);
      rebasingToken1.approve(address(router),10**40);
      rebasingToken2.approve(address(router),10**40);
      console.logAddress(msg.sender);
      console.logAddress(address(this));
      // assertEq(rebasingToken1.balanceOf(msg.sender),10**21);
      // assertEq(rebasingToken2.balanceOf(msg.sender),10**21);
      
      // console.logUint(router.addLiquidity(address(token1),address(token2),10**18,10**18,10**12,10**12,msg.sender));
      router.addLiquidity(address(rebasingToken1),address(rebasingToken2),10**19,10**19,0,0,msg.sender);

      address[] memory path = new address[](2);
      path[0] = address(rebasingToken1);
      path[1] = address(rebasingToken2);

      
      router.swapExactTokensForTokens(10**10,0,path,msg.sender,address(0));
      // uint[] memory amounts = MathLib.getAmountsOut(address(factory), 10**12, path);
      // console.logUint(amounts[0]);
      // console.logUint(amounts[1]);

      // router.swapExactTokensForTokens(10**12,0,path,msg.sender,address(0));
    }   
    // function testSwap() public {

    //   Mooniswap pool1 = Mooniswap(factory.deploy(IERC20(token1),IERC20(token2)));
    //   assertEq((pool1.getTokens()).length,2);
    // }
}


