// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

contract ERC20Test is Test {
    address constant USER1 = address(uint160(1000));
    address constant USER2 = address(uint160(2000));
    address constant USER3 = address(uint160(3000));
    ERC20 internal token;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    function setUp() public {
        token = ERC20(
            HuffDeployer.config().with_deployer(USER1).deploy(
                "test/contracts/MockERC20"
            )
        );
        vm.label(address(token), "Token");
    }

    function testMintAtDeploy() public {
        vm.expectEmit(true, true, false, true);
        emit Transfer(address(0), USER1, 1e9 * 1e18);
        vm.prank(USER1);
        ERC20 newToken = ERC20(
            HuffDeployer.config().with_deployer(USER1).deploy(
                "test/contracts/MockERC20"
            )
        );

        assertEq(newToken.balanceOf(USER1), 1e9 * 1e18, "balance mismatch");
        assertEq(newToken.totalSupply(), 1e9 * 1e18, "supply mismatch");
    }

    function assertReturndatasizeEq(uint256 _expectedSize) public {
        uint256 returnDataSize;
        assembly {
            returnDataSize := returndatasize()
        }
        assertEq(returnDataSize, _expectedSize);
    }

    function testDecimals() public {
        assertEq(token.decimals(), 18);
    }

    function testSymbol() public {
        assertEq(token.symbol(), "TOK");
    }

    function testName() public {
        assertEq(token.name(), "Mock Token");
    }

    function testTransfer(uint256 _amount) public {
        vm.assume(_amount <= 1e9 * 1e18);

        vm.expectEmit(true, true, false, true);
        emit Transfer(USER1, USER2, 100 * 1e18);
        vm.prank(USER1);
        bool success = token.transfer(USER2, 100 * 1e18);

        assertReturndatasizeEq(32);

        assertTrue(success);
        assertEq(token.balanceOf(USER1), (1e9 - 100) * 1e18);
        assertEq(token.balanceOf(USER2), 100 * 1e18);
    }

    function testSnapshotTransfer() public {
        testTransfer(100 * 1e18);
    }

    function testApprove(uint256 _allowance) public {
        vm.expectEmit(true, true, false, true, address(token));
        emit Approval(USER2, USER3, _allowance);
        vm.prank(USER2);
        bool success = token.approve(USER3, _allowance);

        assertReturndatasizeEq(32);

        assertTrue(success);
        assertEq(token.allowance(USER2, USER3), _allowance);
        assertEq(token.allowance(USER3, USER2), 0);
    }

    function testSnapshotApprove() public {
        testApprove(200000 * 1e18);
    }

    function testTransferFrom(uint256 _amount, uint256 _allowance) public {
        vm.assume(_amount <= 1e9 * 1e18);
        vm.assume(_amount <= _allowance);
        vm.assume(_allowance != type(uint256).max);

        vm.prank(USER1);
        token.approve(USER2, _allowance);
        assertEq(token.allowance(USER1, USER2), _allowance);

        vm.expectEmit(true, true, false, true, address(token));
        emit Approval(USER1, USER2, _allowance - _amount);
        vm.expectEmit(true, true, false, true, address(token));
        emit Transfer(USER1, USER3, _amount);

        vm.prank(USER2);
        bool success = token.transferFrom(USER1, USER3, _amount);

        assertReturndatasizeEq(32);
        assertTrue(success);
        assertEq(token.allowance(USER1, USER2), _allowance - _amount);
        assertEq(token.balanceOf(USER1), 1e9 * 1e18 - _amount);
        assertEq(token.balanceOf(USER3), _amount);
        assertEq(token.balanceOf(USER2), 0);
    }

    function testSnapshotTransferFrom() public {
        testTransferFrom(2000 * 1e18, 300000 * 1e18);
    }

    function testTransferFromMaxAllowance(uint256 _amount) public {
        vm.assume(_amount <= 1e9 * 1e18);

        vm.prank(USER1);
        token.approve(USER2, type(uint256).max);
        assertEq(token.allowance(USER1, USER2), type(uint256).max);

        vm.expectEmit(true, true, false, true, address(token));
        emit Transfer(USER1, USER3, _amount);

        vm.prank(USER2);
        bool success = token.transferFrom(USER1, USER3, _amount);

        assertReturndatasizeEq(32);
        assertTrue(success);
        assertEq(token.allowance(USER1, USER2), type(uint256).max);
        assertEq(token.balanceOf(USER1), 1e9 * 1e18 - _amount);
        assertEq(token.balanceOf(USER3), _amount);
        assertEq(token.balanceOf(USER2), 0);
    }

    function testSnapshotTransferFromMaxAllowance() public {
        testTransferFromMaxAllowance(2389 * 1e18);
    }
}
