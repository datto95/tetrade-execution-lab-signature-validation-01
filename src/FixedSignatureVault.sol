// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract FixedSignatureVault {
    error InvalidSignature();
    error AuthorizationExpired();
    error NonceAlreadyUsed();
    error TransferFailed();

    address public immutable authorizer;
    mapping(uint256 nonce => bool used) public usedNonces;

    constructor(address _authorizer) {
        authorizer = _authorizer;
    }

    receive() external payable {}

    function getDigest(
        address recipient,
        uint256 amount,
        uint256 deadline,
        uint256 nonce
    ) public view returns (bytes32) {
        return keccak256(abi.encodePacked(address(this), recipient, amount, deadline, nonce));
    }

    function claim(
        address payable recipient,
        uint256 amount,
        uint256 deadline,
        uint256 nonce,
        bytes calldata signature
    ) external {
        if (block.timestamp > deadline) revert AuthorizationExpired();
        if (usedNonces[nonce]) revert NonceAlreadyUsed();

        bytes32 digest = getDigest(recipient, amount, deadline, nonce);
        bytes32 ethSignedDigest = _toEthSignedMessageHash(digest);
        if (_recover(ethSignedDigest, signature) != authorizer) revert InvalidSignature();

        usedNonces[nonce] = true;

        (bool ok,) = recipient.call{value: amount}("");
        if (!ok) revert TransferFailed();
    }

    function balance() external view returns (uint256) {
        return address(this).balance;
    }

    function _toEthSignedMessageHash(bytes32 digest) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", digest));
    }

    function _recover(bytes32 digest, bytes calldata signature) internal pure returns (address) {
        if (signature.length != 65) revert InvalidSignature();

        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := calldataload(signature.offset)
            s := calldataload(add(signature.offset, 32))
            v := byte(0, calldataload(add(signature.offset, 64)))
        }

        if (v < 27) v += 27;
        if (v != 27 && v != 28) revert InvalidSignature();

        address recovered = ecrecover(digest, v, r, s);
        if (recovered == address(0)) revert InvalidSignature();
        return recovered;
    }
}