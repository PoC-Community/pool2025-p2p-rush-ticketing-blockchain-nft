// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./TicketNFT.sol";
import "./IERC721Metadata.sol";
import "./node_modules/@openzeppelin/contracts/utils/Strings.sol";

contract TicketNFTMetadata is TicketNFT, IERC721Metadata {
    string private _name;
    string private _symbol;
    string private _baseURI;

    constructor(
        string memory defaultLocation,
        string memory defaultName,
        uint defaultID,
        uint defaultDate,
        string memory name_,
        string memory symbol_,
        string memory baseURI_
    ) TicketNFT(defaultLocation, defaultName, defaultID, defaultDate) {
        _name = name_;
        _symbol = symbol_;
        _baseURI = baseURI_;
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(tokenId < _myTickets.length, "Token ID does not exist");
        return string(abi.encodePacked(_baseURI, Strings.toString(tokenId), ".json"));
    }

    function setBaseURI(string calldata newURI) external {
        require(msg.sender == owner, "Only owner can change metadata URI");
        _baseURI = newURI;
    }
}
