// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract TicketFactory {
    struct myTicket {
        string event_name;
        string location;
        uint id;
        uint256 date;
    }

    myTicket[] public _myTickets;
    mapping(uint256 => address) _owners;
    mapping(address => uint256) _ticketCount;
    address public owner;

    constructor(string memory _defaultLocation, string memory _defaultName, uint _defaultID, uint _defaultDate) {
        owner = msg.sender;

        _myTickets.push(myTicket(_defaultLocation, _defaultName, _defaultID, _defaultDate));
    }

    function _createTicket(string memory _name, string memory _location) internal returns (uint256) {
        require(_ticketCount[msg.sender] <= 3, "You can't have more than 3 pets");

        myTicket memory newTicket = myTicket({name: _myTickets[0].name, location: _location});
        uint256 newTicketId = _myTickets.length;
        _myTickets.push(newTicket);
        _owners[newTicketId] = msg.sender;
        _ticketCount[msg.sender]++;

        return (newTicketId);
    }
}
