// SPDX-License-Identifier: MIT
// ERC721A Contracts v4.2.3
// Creator: Chiru Labs

pragma solidity ^0.8.9;


interface IElpisOriginAsset {

    function nextTokenId() external view returns (uint256);

    function tokenURI(
        uint256 _tokenId
    ) external view returns (string memory);

    function transferMinterAdmin(address _newAdmin) external;

    function mintAsset(
        address _to,
        string memory _uniqueTokenURI
    ) external;

    function mintAssetBatch(
        address _to,
        uint256 _amount
    ) external;

    function setTokenURI(
        string memory _newTokenURI
    ) external;

    function updateUniqueTokenURI(
        uint256 _tokenId,
        string memory _newTokenURI
    ) external;

    function updateMetadata(
        uint256 _tokenId
    ) external;

    function updateMetadata(
        uint256 _fromTokenId,
        uint256 _toTokenId
    ) external;
}