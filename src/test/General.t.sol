// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";

contract GeneralTest is Test {
    error OtherError();

    function testSig() public {
        bytes4 huffSelector = 0x2a4cb61e;
        emit log_named_bytes32("OtherError", keccak256("OtherError"));
        //assertEq(bytes4(keccak256("NotOwner")), huffSelector);
        assertEq(OtherError.selector, huffSelector);
    }
}
