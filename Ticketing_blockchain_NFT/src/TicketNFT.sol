// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./TicketFactory.sol";
import "./IERC721.sol";

contract TicketNFT is TicketFactory, IERC721 {
    constructor(
        string memory _defaultLocation,
        string memory _defaultName,
        uint _defaultID,
        uint _defaultDate
    ) TicketFactory(_defaultLocation, _defaultName, _defaultDate) {
    }

    mapping(address => mapping(address => bool)) private _operatorApprovals;
    mapping(uint256 => address) private _tokenApprovals;

    function balanceOf(address owner) public view override returns (uint256) {
        return _ticketCount[owner];
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        require(_myTickets.length >= tokenId);
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
        _ticketCount[from]--;
        _ticketCount[to]++;
        emit Transfer(from, to, tokenId);
    }

    function mint() public {
        require(_ticketCount[msg.sender] < 2, "You can't have more than 1 tickets");

        uint256 ticketId = _createTicket();
        _owners[ticketId] = msg.sender;

        emit Transfer(address(0), msg.sender, ticketId);
    }

    function getFirstOwnedTicket() public view returns (uint256) {
        uint256[] memory tickets = getTicketsIdFromAddress(msg.sender);

        if (tickets.length > 0) {
            return tickets[0];
        } else {
            return type(uint256).max;
        }
    }

}