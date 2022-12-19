// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DSTest} from "lib/forge-std/lib/ds-test/src/test.sol";
import {Vm} from "lib/forge-std/src/Vm.sol";
import {TokenCustomDecimalsMock} from "src/mocks/TokenCustomDecimalsMock.sol";

import "src/MooniFactory.sol";
import "src/Mooniswap.sol";
import "src/MooniRouter.sol";
import {WETH9} from "src/mocks/WETH9.sol";
import {MockSOHM} from "src/mocks/MockSOHM.sol";

contract TestMooniV2Router is DSTest {
    Vm internal constant vm = Vm(HEVM_ADDRESS);

    MooniFactory public factory;
    MooniRouter public router;

    TokenCustomDecimalsMock public token0;
    TokenCustomDecimalsMock public token1;
    MockSOHM public rebasingToken0;
    MockSOHM public rebasingToken1;
    WETH9 public weth;

    function setUp() public {
      factory = new MooniFactory();
      factory.setFee(0.003e18);
      weth = new WETH9();
      router = new MooniRouter(address(factory),address(weth));
      token0 = new TokenCustomDecimalsMock(
        "Token Zero",
        "TOK0",
        1 ether,
        18
      );
      token1 = new TokenCustomDecimalsMock(
        "Token One",
        "TOK1",
        1 ether,
        18
      );
      rebasingToken0 = new MockSOHM(
        10**27,
        10*10**9 //rebase %
      );
      rebasingToken1 = new MockSOHM(
        10**27,
        10*10**9 //rebase %
      );

      MockSOHM(rebasingToken0).mint(address(this),1 ether); 
      MockSOHM(rebasingToken1).mint(address(this),1 ether); 

    }

    function testAddLiquidityPairFor() public {
        token0.approve(address(router), 10 ether);
        token1.approve(address(router), 10 ether);

        (address _token0, address _token1) = MathLib.sortTokens(
            address(token0),
            address(token1)
        );
        address pair = MathLib.pairFor(
            address(factory),
            _token0,
            _token1
        );

        factory.deploy(IERC20(token0),IERC20(token1));
        (uint256 liquidity) = router.addLiquidity(
            address(token0),
            address(token1),
            1 ether,
            1 ether,
            1 ether,
            1 ether,
            address(this)
        );

        // assertEq(liquidity, );
        assertEq(liquidity, UniERC20.uniBalanceOf(IERC20(pair),address(this)));
        assertEq(MathLib.pairFor(address(factory),address(token0),address(token1)),pair);
    }

    function testAddLiquidityNoPair() public {
        token0.approve(address(router), 1 ether);
        token1.approve(address(router), 1 ether);

        (address _token0, address _token1) = MathLib.sortTokens(
            address(token0),
            address(token1)
        );

        address pair = MathLib.pairFor(
            address(factory),
            _token0,
            _token1
        );

        (uint256 liquidity) = router
            .addLiquidity(
                address(token0),
                address(token1),
                1 ether,
                1 ether,
                1 ether,
                1 ether,
                address(this)
            );

        // assertEq(amount0, 1 ether);
        // assertEq(amount1, 1 ether);
        // assertEq(liquidity, 1 ether - UnifapV2Pair(pair).MINIMUM_LIQUIDITY());

        // assertEq(factory.pairs(address(token0), address(token1)), pair);
        // assertEq(UnifapV2Pair(pair).token0(), address(token0));
        // assertEq(UnifapV2Pair(pair).token1(), address(token1));

        // (uint256 reserve0, uint256 reserve1, ) = Mooniswap(pair)
        //     .getReserves();
        // assertEq(reserve0, 1 ether);
        // assertEq(reserve1, 1 ether);
        // assertEq(token0.balanceOf(address(pair)), 1 ether);
        // assertEq(token1.balanceOf(address(pair)), 1 ether);
        // assertEq(token0.balanceOf(address(this)), 9 ether);
        // assertEq(token1.balanceOf(address(this)), 9 ether);
    }

    // function testAddLiquidityInsufficientAmountB() public {
    //     token0.approve(address(router), 4 ether);
    //     token1.approve(address(router), 8 ether);

    //     router.addLiquidity(
    //         address(token0),
    //         address(token1),
    //         4 ether,
    //         8 ether,
    //         4 ether,
    //         8 ether,
    //         address(this),
    //         block.timestamp + 1
    //     );

    //     token0.approve(address(router), 1 ether);
    //     token1.approve(address(router), 2 ether);

    //     vm.expectRevert(abi.encodeWithSignature("InsufficientAmountB()"));
    //     router.addLiquidity(
    //         address(token0),
    //         address(token1),
    //         1 ether,
    //         2 ether,
    //         1 ether,
    //         2.3 ether,
    //         address(this),
    //         block.timestamp + 1
    //     );
    // }

    // function testAddLiquidityAmountBDesiredHigh() public {
    //     token0.approve(address(router), 4 ether);
    //     token1.approve(address(router), 8 ether);

    //     router.addLiquidity(
    //         address(token0),
    //         address(token1),
    //         4 ether,
    //         8 ether,
    //         4 ether,
    //         8 ether,
    //         address(this),
    //         block.timestamp + 1
    //     );

    //     token0.approve(address(router), 1 ether);
    //     token1.approve(address(router), 2 ether);

    //     (uint256 amount0, uint256 amount1, ) = router.addLiquidity(
    //         address(token0),
    //         address(token1),
    //         1 ether,
    //         2.3 ether,
    //         1 ether,
    //         2 ether,
    //         address(this),
    //         block.timestamp + 1
    //     );

    //     assertEq(amount0, 1 ether);
    //     assertEq(amount1, 2 ether);
    // }

    // function testAddLiquidityAmountBDesiredLow() public {
    //     token0.approve(address(router), 4 ether);
    //     token1.approve(address(router), 8 ether);

    //     router.addLiquidity(
    //         address(token0),
    //         address(token1),
    //         4 ether,
    //         8 ether,
    //         4 ether,
    //         8 ether,
    //         address(this),
    //         block.timestamp + 1
    //     );

    //     token0.approve(address(router), 1 ether);
    //     token1.approve(address(router), 2 ether);

    //     (uint256 amount0, uint256 amount1, ) = router.addLiquidity(
    //         address(token0),
    //         address(token1),
    //         1 ether,
    //         1.5 ether,
    //         0.75 ether,
    //         2 ether,
    //         address(this),
    //         block.timestamp + 1
    //     );

    //     assertEq(amount0, 0.75 ether);
    //     assertEq(amount1, 1.5 ether);
    // }

    // function testAddLiquidityInsufficientAmountA() public {
    //     token0.approve(address(router), 4 ether);
    //     token1.approve(address(router), 8 ether);

    //     router.addLiquidity(
    //         address(token0),
    //         address(token1),
    //         4 ether,
    //         8 ether,
    //         4 ether,
    //         8 ether,
    //         address(this),
    //         block.timestamp + 1
    //     );

    //     token0.approve(address(router), 1 ether);
    //     token1.approve(address(router), 2 ether);

    //     vm.expectRevert(abi.encodeWithSignature("InsufficientAmountA()"));
    //     router.addLiquidity(
    //         address(token0),
    //         address(token1),
    //         1 ether,
    //         1.5 ether,
    //         1 ether,
    //         2 ether,
    //         address(this),
    //         block.timestamp + 1
    //     );
    // }

    // function testAddLiquidityExpired() public {
    //     token0.approve(address(router), 1 ether);
    //     token1.approve(address(router), 1 ether);

    //     vm.warp(2);
    //     vm.expectRevert(abi.encodeWithSignature("Expired()"));
    //     router.addLiquidity(
    //         address(token0),
    //         address(token1),
    //         1 ether,
    //         1 ether,
    //         1 ether,
    //         1 ether,
    //         address(this),
    //         1
    //     );
    // }

    // function testRemoveLiquidity() public {
    //     token0.approve(address(router), 1 ether);
    //     token1.approve(address(router), 1 ether);

    //     (uint256 amount0, uint256 amount1, uint256 liquidity) = router
    //         .addLiquidity(
    //             address(token0),
    //             address(token1),
    //             1 ether,
    //             1 ether,
    //             1 ether,
    //             1 ether,
    //             address(this),
    //             block.timestamp + 1
    //         );

    //     address pair = factory.pairs(address(token0), address(token1));
    //     assertEq(IERC20(pair).balanceOf(address(this)), liquidity);

    //     router.removeLiquidity(
    //         address(token0),
    //         address(token1),
    //         liquidity,
    //         amount0,
    //         amount1,
    //         address(this),
    //         block.timestamp + 1
    //     );
    // }
}
