// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DSTest} from "lib/forge-std/lib/ds-test/src/test.sol";
import {Vm} from "lib/forge-std/src/Vm.sol";
import {TokenCustomDecimalsMock} from "src/mocks/TokenCustomDecimalsMock.sol";
import "lib/forge-std/src/Test.sol";
import "src/MooniFactory.sol";
import "src/Mooniswap.sol";
import "src/MooniRouter.sol";
import {WETH9} from "src/mocks/WETH9.sol";
import {MyToken} from "src/mocks/ERC20Mock.sol";

contract TestMooniRouterSwap is DSTest {

    MooniFactory public factory;
    MooniRouter public router;

    MyToken public token0;
    MyToken public token1;
    MyToken public token2;
    WETH9 public weth;

    function setUp() public {
      factory = new MooniFactory();
      weth = new WETH9();
      router = new MooniRouter(address(factory),address(weth));
      token0 = new MyToken();
      token1 = new MyToken();
      token2 = new MyToken();
      token0.approve(address(router), 9999999999*10**18);
      token1.approve(address(router), 9999999999*10**18);
      token2.approve(address(router), 9999999999*10**18);
      weth.approve(address(router), 9999999999*10**18);
    }

    // function testSwapExactTokensForTokensr() public {
    //     (uint256 liquidity01) = router.addLiquidity(
    //         address(token0),
    //         address(token1),
    //         75 ether,
    //         75 ether,
    //         75 ether,
    //         75 ether,
    //         address(this)
    //     );
    //     assertTrue(liquidity01>0);
    //     (uint256 liquidity12) = router.addLiquidity(
    //         address(token1),
    //         address(token2),
    //         75 ether,
    //         75 ether,
    //         75 ether,
    //         75 ether,
    //         address(this)
    //     );
    //     assertTrue(liquidity12>0);

    //     uint amountToken0Before = token0.balanceOf(address(this));
    //     uint amountToken2Before = token2.balanceOf(address(this));

    //     address[] memory path = new address[](3);
    //     path[0] = address(token0);
    //     path[1] = address(token1);
    //     path[2] = address(token2);
       
    //     router.swapExactTokensForTokens(10**24, 10**11, path, address(this), address(this));
  

    //      uint amountToken0After = token0.balanceOf(address(this));
    //      uint amountToken2After = token2.balanceOf(address(this));

    //      assertTrue(amountToken0After < amountToken0Before);
    //      assertTrue(amountToken2After > amountToken2Before);
    // }
   function testSwap() public {
        // (uint256 liquidity01) = router.addLiquidity(
        //     address(token0),
        //     address(token1),
        //     75 ether,
        //     75 ether,
        //     75 ether,
        //     75 ether,
        //     address(this)
        // );
        // assertTrue(liquidity01>0);
        (uint256 liquidity12) = router.addLiquidityETH{value: 75 ether}(
            address(token0),
            75 ether,
            75 ether,
            75 ether,
            address(this)
        );

        assertTrue(liquidity12>0);
        assertTrue(weth.totalSupply()>0);

        // address pair = factory.pairFor(address(weth),address(token1));
        // uint amountReturn = Mooniswap(pair).getReturn(IERC20(address(weth)), token1, 10**19);
        // assertTrue(amountReturn>0);

        uint amountToken0Before = token0.balanceOf(address(this));
        uint amountWethBefore = weth.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[1] = address(token0);
      //  path[2] = address(token1);
        path[0] = address(weth);

       router.swapExactETHForTokens{value: 10 ether}(10**11, path, address(this), address(this));

        uint amountToken0After = token0.balanceOf(address(this));
        uint amountWethAfter = weth.balanceOf(address(this));

       assertTrue(amountToken0After > amountToken0Before);
     //  assertTrue(amountWethAfter < amountWethBefore);
    }
}