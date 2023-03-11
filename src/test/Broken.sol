// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IBroken {
    function withdraw() external payable;

    function deposit() external payable;

    function setWithdrawer(address) external payable;
}
