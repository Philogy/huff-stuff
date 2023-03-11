// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {Test} from "forge-std/Test.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

interface IChallenge {
    function becomeTheOptimizor(address player) external;
}

/// @author Philippe Dumonet <philippe@dumo.net>
contract OptimizorTest is Test {
    uint256 public constant BIT_MASK_LENGTH = 10;
    uint256 public constant BIT_MASK = 2**BIT_MASK_LENGTH - 1;

    IChallenge c = IChallenge(0x27761C482000F2fC91E74587576c2B267eEb4546);

    function testGetsHighScore() public {
        address coinb = block.coinbase;
        uint256 startBlock = block.number;
        uint256 startTime = block.timestamp;
        uint256 size = 16;

        while (true) {
            uint256 seed = getSeed(coinb, ++startBlock, startTime, size);
            uint256[10] memory inputArr = constructProblemArray(seed);
            uint256[3] memory indexesFor3Sum = constructIndexesFor3Sum(
                seed >> (BIT_MASK_LENGTH * 10)
            );
            uint256 desiredSum = inputArr[indexesFor3Sum[0]] +
                inputArr[indexesFor3Sum[1]] +
                inputArr[indexesFor3Sum[2]];
            if (inputArr[1] >= 10 || inputArr[2] >= 10) continue;
            uint256 realSum = inputArr[0] +
                inputArr[inputArr[1]] +
                inputArr[inputArr[2]];
            if (realSum == desiredSum) break;
        }

        address player = HuffDeployer.config().deploy("evm-golf/OptimizorHill");
        emit log_named_address("player", player);
        emit log_named_uint("player.code.length", player.code.length);

        vm.coinbase(coinb);
        vm.roll(startBlock);
        vm.warp(startTime);

        address me = address(bytes20(keccak256("some random address")));

        vm.prank(me, me);
        c.becomeTheOptimizor(player);
    }

    function getSeed(
        address _bCoinb,
        uint256 _bNum,
        uint256 _bTime,
        uint256 _size
    ) public pure returns (uint256) {
        return
            uint256(keccak256(abi.encodePacked(_bCoinb, _bNum, _bTime, _size)));
    }

    function constructProblemArray(uint256 seed)
        public
        pure
        returns (uint256[10] memory arr)
    {
        unchecked {
            for (uint256 i = 0; i < 10; i++) {
                arr[i] = (seed & BIT_MASK) % 50;
                seed >>= BIT_MASK_LENGTH;
            }
        }
    }

    function constructIndexesFor3Sum(uint256 seed)
        public
        pure
        returns (uint256[3] memory arr)
    {
        unchecked {
            arr[0] = (seed & BIT_MASK) % 10;
            seed >>= BIT_MASK_LENGTH;

            // make sure indexes are unique
            // statistically, this loop shouldnt run much
            while (true) {
                arr[1] = (seed & BIT_MASK) % 10;
                seed >>= BIT_MASK_LENGTH;

                if (arr[1] != arr[0]) {
                    break;
                }
            }

            // make sure indexes are unique
            // statistically, this loop shouldnt run much
            while (true) {
                arr[2] = (seed & BIT_MASK) % 10;
                seed >>= BIT_MASK_LENGTH;

                if (arr[2] != arr[1] && arr[2] != arr[0]) {
                    break;
                }
            }
        }
    }
}
