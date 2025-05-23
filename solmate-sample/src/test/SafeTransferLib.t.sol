// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {MockERC20} from "./utils/mocks/MockERC20.sol";
import {RevertingToken} from "./utils/weird-tokens/RevertingToken.sol";
import {ReturnsTwoToken} from "./utils/weird-tokens/ReturnsTwoToken.sol";
import {ReturnsFalseToken} from "./utils/weird-tokens/ReturnsFalseToken.sol";
import {MissingReturnToken} from "./utils/weird-tokens/MissingReturnToken.sol";
import {ReturnsTooMuchToken} from "./utils/weird-tokens/ReturnsTooMuchToken.sol";
import {ReturnsGarbageToken} from "./utils/weird-tokens/ReturnsGarbageToken.sol";
import {ReturnsTooLittleToken} from "./utils/weird-tokens/ReturnsTooLittleToken.sol";

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {ERC20} from "../tokens/ERC20.sol";
import {SafeTransferLib} from "../utils/SafeTransferLib.sol";

contract SafeTransferLibTest is DSTestPlus {
    RevertingToken reverting;
    ReturnsTwoToken returnsTwo;
    ReturnsFalseToken returnsFalse;
    MissingReturnToken missingReturn;
    ReturnsTooMuchToken returnsTooMuch;
    ReturnsGarbageToken returnsGarbage;
    ReturnsTooLittleToken returnsTooLittle;

    MockERC20 erc20;

    function setUp() public {
        reverting = new RevertingToken();
        returnsTwo = new ReturnsTwoToken();
        returnsFalse = new ReturnsFalseToken();
        missingReturn = new MissingReturnToken();
        returnsTooMuch = new ReturnsTooMuchToken();
        returnsGarbage = new ReturnsGarbageToken();
        returnsTooLittle = new ReturnsTooLittleToken();

        erc20 = new MockERC20("StandardToken", "ST", 18);
        erc20.mint(address(this), type(uint256).max);
    }

    function testTransferWithMissingReturn() public {
        verifySafeTransfer(address(missingReturn), address(0xBEEF), 1e18);
    }

    function testTransferWithStandardERC20() public {
        verifySafeTransfer(address(erc20), address(0xBEEF), 1e18);
    }

    function testTransferWithReturnsTooMuch() public {
        verifySafeTransfer(address(returnsTooMuch), address(0xBEEF), 1e18);
    }

    function testTransferFromWithMissingReturn() public {
        verifySafeTransferFrom(
            address(missingReturn),
            address(0xFEED),
            address(0xBEEF),
            1e18
        );
    }

    function testTransferFromWithStandardERC20() public {
        verifySafeTransferFrom(
            address(erc20),
            address(0xFEED),
            address(0xBEEF),
            1e18
        );
    }

    function testTransferFromWithReturnsTooMuch() public {
        verifySafeTransferFrom(
            address(returnsTooMuch),
            address(0xFEED),
            address(0xBEEF),
            1e18
        );
    }

    function testApproveWithMissingReturn() public {
        verifySafeApprove(address(missingReturn), address(0xBEEF), 1e18);
    }

    function testApproveWithStandardERC20() public {
        verifySafeApprove(address(erc20), address(0xBEEF), 1e18);
    }

    function testApproveWithReturnsTooMuch() public {
        verifySafeApprove(address(returnsTooMuch), address(0xBEEF), 1e18);
    }

    function testTransferETH() public {
        SafeTransferLib.safeTransferETH(address(0xBEEF), 1e18);
    }

    function testTransferWithMissingReturn(
        address to,
        uint256 amount,
        bytes calldata brutalizeWith
    ) public brutalizeMemory(brutalizeWith) {
        verifySafeTransfer(address(missingReturn), to, amount);
    }

    function testTransferWithStandardERC20(
        address to,
        uint256 amount,
        bytes calldata brutalizeWith
    ) public brutalizeMemory(brutalizeWith) {
        verifySafeTransfer(address(erc20), to, amount);
    }

    function testTransferWithReturnsTooMuch(
        address to,
        uint256 amount,
        bytes calldata brutalizeWith
    ) public brutalizeMemory(brutalizeWith) {
        verifySafeTransfer(address(returnsTooMuch), to, amount);
    }

    function testTransferWithGarbage(
        address to,
        uint256 amount,
        bytes memory garbage,
        bytes calldata brutalizeWith
    ) public brutalizeMemory(brutalizeWith) {
        if (
            (garbage.length < 32 ||
                (garbage[0] != 0 ||
                    garbage[1] != 0 ||
                    garbage[2] != 0 ||
                    garbage[3] != 0 ||
                    garbage[4] != 0 ||
                    garbage[5] != 0 ||
                    garbage[6] != 0 ||
                    garbage[7] != 0 ||
                    garbage[8] != 0 ||
                    garbage[9] != 0 ||
                    garbage[10] != 0 ||
                    garbage[11] != 0 ||
                    garbage[12] != 0 ||
                    garbage[13] != 0 ||
                    garbage[14] != 0 ||
                    garbage[15] != 0 ||
                    garbage[16] != 0 ||
                    garbage[17] != 0 ||
                    garbage[18] != 0 ||
                    garbage[19] != 0 ||
                    garbage[20] != 0 ||
                    garbage[21] != 0 ||
                    garbage[22] != 0 ||
                    garbage[23] != 0 ||
                    garbage[24] != 0 ||
                    garbage[25] != 0 ||
                    garbage[26] != 0 ||
                    garbage[27] != 0 ||
                    garbage[28] != 0 ||
                    garbage[29] != 0 ||
                    garbage[30] != 0 ||
                    garbage[31] != bytes1(0x01))) && garbage.length != 0
        ) return;

        returnsGarbage.setGarbage(garbage);

        verifySafeTransfer(address(returnsGarbage), to, amount);
    }

    function testTransferFromWithMissingReturn(
        address from,
        address to,
        uint256 amount,
        bytes calldata brutalizeWith
    ) public brutalizeMemory(brutalizeWith) {
        verifySafeTransferFrom(address(missingReturn), from, to, amount);
    }

    function testTransferFromWithStandardERC20(
        address from,
        address to,
        uint256 amount,
        bytes calldata brutalizeWith
    ) public brutalizeMemory(brutalizeWith) {
        verifySafeTransferFrom(address(erc20), from, to, amount);
    }

    function testTransferFromWithReturnsTooMuch(
        address from,
        address to,
        uint256 amount,
        bytes calldata brutalizeWith
    ) public brutalizeMemory(brutalizeWith) {
        verifySafeTransferFrom(address(returnsTooMuch), from, to, amount);
    }

    function testTransferFromWithGarbage(
        address from,
        address to,
        uint256 amount,
        bytes memory garbage,
        bytes calldata brutalizeWith
    ) public brutalizeMemory(brutalizeWith) {
        if (
            (garbage.length < 32 ||
                (garbage[0] != 0 ||
                    garbage[1] != 0 ||
                    garbage[2] != 0 ||
                    garbage[3] != 0 ||
                    garbage[4] != 0 ||
                    garbage[5] != 0 ||
                    garbage[6] != 0 ||
                    garbage[7] != 0 ||
                    garbage[8] != 0 ||
                    garbage[9] != 0 ||
                    garbage[10] != 0 ||
                    garbage[11] != 0 ||
                    garbage[12] != 0 ||
                    garbage[13] != 0 ||
                    garbage[14] != 0 ||
                    garbage[15] != 0 ||
                    garbage[16] != 0 ||
                    garbage[17] != 0 ||
                    garbage[18] != 0 ||
                    garbage[19] != 0 ||
                    garbage[20] != 0 ||
                    garbage[21] != 0 ||
                    garbage[22] != 0 ||
                    garbage[23] != 0 ||
                    garbage[24] != 0 ||
                    garbage[25] != 0 ||
                    garbage[26] != 0 ||
                    garbage[27] != 0 ||
                    garbage[28] != 0 ||
                    garbage[29] != 0 ||
                    garbage[30] != 0 ||
                    garbage[31] != bytes1(0x01))) && garbage.length != 0
        ) return;

        returnsGarbage.setGarbage(garbage);

        verifySafeTransferFrom(address(returnsGarbage), from, to, amount);
    }

    function testApproveWithMissingReturn(
        address to,
        uint256 amount,
        bytes calldata brutalizeWith
    ) public brutalizeMemory(brutalizeWith) {
        verifySafeApprove(address(missingReturn), to, amount);
    }

    function testApproveWithStandardERC20(
        address to,
        uint256 amount,
        bytes calldata brutalizeWith
    ) public brutalizeMemory(brutalizeWith) {
        verifySafeApprove(address(erc20), to, amount);
    }

    function testApproveWithReturnsTooMuch(
        address to,
        uint256 amount,
        bytes calldata brutalizeWith
    ) public brutalizeMemory(brutalizeWith) {
        verifySafeApprove(address(returnsTooMuch), to, amount);
    }

    function testApproveWithGarbage(
        address to,
        uint256 amount,
        bytes memory garbage,
        bytes calldata brutalizeWith
    ) public brutalizeMemory(brutalizeWith) {
        if (
            (garbage.length < 32 ||
                (garbage[0] != 0 ||
                    garbage[1] != 0 ||
                    garbage[2] != 0 ||
                    garbage[3] != 0 ||
                    garbage[4] != 0 ||
                    garbage[5] != 0 ||
                    garbage[6] != 0 ||
                    garbage[7] != 0 ||
                    garbage[8] != 0 ||
                    garbage[9] != 0 ||
                    garbage[10] != 0 ||
                    garbage[11] != 0 ||
                    garbage[12] != 0 ||
                    garbage[13] != 0 ||
                    garbage[14] != 0 ||
                    garbage[15] != 0 ||
                    garbage[16] != 0 ||
                    garbage[17] != 0 ||
                    garbage[18] != 0 ||
                    garbage[19] != 0 ||
                    garbage[20] != 0 ||
                    garbage[21] != 0 ||
                    garbage[22] != 0 ||
                    garbage[23] != 0 ||
                    garbage[24] != 0 ||
                    garbage[25] != 0 ||
                    garbage[26] != 0 ||
                    garbage[27] != 0 ||
                    garbage[28] != 0 ||
                    garbage[29] != 0 ||
                    garbage[30] != 0 ||
                    garbage[31] != bytes1(0x01))) && garbage.length != 0
        ) return;

        returnsGarbage.setGarbage(garbage);

        verifySafeApprove(address(returnsGarbage), to, amount);
    }

    function testTransferETH(
        address recipient,
        uint256 amount,
        bytes calldata brutalizeWith
    ) public brutalizeMemory(brutalizeWith) {
        // Transferring to msg.sender can fail because it's possible to overflow their ETH balance as it begins non-zero.
        if (
            recipient.code.length > 0 ||
            uint256(uint160(recipient)) <= 18 ||
            recipient == msg.sender
        ) return;

        amount = bound(amount, 0, address(this).balance);

        SafeTransferLib.safeTransferETH(recipient, amount);
    }

    function verifySafeTransfer(
        address token,
        address to,
        uint256 amount
    ) internal {
        uint256 preBal = ERC20(token).balanceOf(to);
        SafeTransferLib.safeTransfer(ERC20(address(token)), to, amount);
        uint256 postBal = ERC20(token).balanceOf(to);

        if (to == address(this)) {
            assertEq(preBal, postBal);
        } else {
            assertEq(postBal - preBal, amount);
        }
    }

    function verifySafeTransferFrom(
        address token,
        address from,
        address to,
        uint256 amount
    ) internal {
        forceApprove(token, from, address(this), amount);

        // We cast to MissingReturnToken here because it won't check
        // that there was return data, which accommodates all tokens.
        MissingReturnToken(token).transfer(from, amount);

        uint256 preBal = ERC20(token).balanceOf(to);
        SafeTransferLib.safeTransferFrom(ERC20(token), from, to, amount);
        uint256 postBal = ERC20(token).balanceOf(to);

        if (from == to) {
            assertEq(preBal, postBal);
        } else {
            assertEq(postBal - preBal, amount);
        }
    }

    function verifySafeApprove(
        address token,
        address to,
        uint256 amount
    ) internal {
        SafeTransferLib.safeApprove(ERC20(address(token)), to, amount);

        assertEq(ERC20(token).allowance(address(this), to), amount);
    }

    function forceApprove(
        address token,
        address from,
        address to,
        uint256 amount
    ) internal {
        uint256 slot = token == address(erc20) ? 4 : 2; // Standard ERC20 name and symbol aren't constant.

        hevm.store(
            token,
            keccak256(
                abi.encode(to, keccak256(abi.encode(from, uint256(slot))))
            ),
            bytes32(uint256(amount))
        );

        assertEq(ERC20(token).allowance(from, to), amount, "wrong allowance");
    }
}
