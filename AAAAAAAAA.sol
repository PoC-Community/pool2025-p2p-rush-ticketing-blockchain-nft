// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./PetFeeding.sol";
import "./IERC721.sol";

contract PetNFT is PetFeeding, IERC721 {
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    mapping(uint256 => address) private _tokenApprovals;

    function balanceOf(address owner) public view override returns (uint256) {
        return _petCount[owner];
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        require(_myPets.length >= tokenId);
        return _owners[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public override {
        require(operator != msg.sender, "Cannot approve yourself");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function approve(address to, uint256 tokenId) public override {
        address owner = _owners[tokenId];
        require(to != owner, "Cannot approve yourself");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Not authorized");

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {
        return _tokenApprovals[tokenId];
    }

    function transferFrom(address from, address to, uint256 tokenId) public override {
        address owner = _owners[tokenId];
        require(owner == from, "Transfer from bad owner");
        require(to != address(0), "Transfer to NULL");
        require(msg.sender == owner || getApproved(tokenId) == msg.sender || isApprovedForAll(owner, msg.sender), "Caller is not approved");
        _owners[tokenId] = to;
        _petCount[from]--;
        _petCount[to]++;
        emit Transfer(from, to, tokenId);
    }

    function mint(string memory _name) public {
        require(_petCount[msg.sender] < 5, "You can't have more than 5 pets");
        uint256 petId = _createPet(_name);
        _owners[petId] = msg.sender;
        emit Transfer(address(0), msg.sender, petId);
    }
}