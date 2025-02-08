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

    constructor(string memory _defaultLocation, string memory _defaultName, uint _defaultDate) {
        owner = msg.sender;
        _myTickets[0].event_name = _defaultName;
        _myTickets[0].location = _defaultLocation;
        _myTickets[0].date = _defaultDate;
    }

    function _createTicket() internal returns (uint256) {
        require(_ticketCount[msg.sender] < 3, "You can't have more than 3 tickets");
    
        uint256 newTicketId = _myTickets.length;
    
        myTicket memory newTicket = myTicket({
            event_name: _myTickets[0].event_name,
            location: _myTickets[0].location,
            id: newTicketId,
            date: _myTickets[0].date
        });
    
        _myTickets.push(newTicket);
        _owners[newTicketId] = msg.sender;
        _ticketCount[msg.sender]++;
    
        return newTicketId;
    }

    function getTicketsIdFromAddress(address _owner) public view returns (uint256[] memory) {
        uint256 count = _ticketCount[_owner];
        uint256[] memory result = new uint256[](count);
        uint256 index = 0;

        for (uint256 i = 0; i < _myTickets.length; i++) {
            if (_owners[i] == _owner) {
                result[index] = i;
                index++;
            }
        }
        return result;
    }

    function getMyTicketsId() public view returns (uint256[] memory) {
        return getTicketsIdFromAddress(msg.sender);
    }

    function getMyTickets(uint256 _ticketId) public view returns (myTicket memory) {
        require(_owners[_ticketId] == msg.sender, "You don't own this tickets");
        return _myTickets[_ticketId];
    }
}
