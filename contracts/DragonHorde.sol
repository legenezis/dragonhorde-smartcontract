// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

/**
 *   This contract essentially creates a treasury
 *
 *   The treasurer is the dragon (the deployer of the contract) who governs a horde of gold
 *      The dragon can appoint or retire minions, who are able to request gold
 *      Anyone can contribute gold to the horde, but only minions can request gold
 *
 *   Approval of gold requests depends on whether or not the dragon is in a good mood
 *       Gold contributions put the dragon in a good mood
 *       Approving gold requests puts the dragon in a bad mood
 *       Mood can also be set manually
 */

contract DragonHorde {
    // Store the address that deploys the contract as the dragon who owns the horde
    address public dragon;

    // Store the name of the dragon
    string public dragonName;

    // Store the state of the dragon's mood
    // true = good mood, false = bad mood
    bool public isGoodMood;

    // Map minions as address keys with a value of true
    // An address key with a value of false is not a minion
    mapping(address => bool) public minions;

    // Modifier that allows only the dragon to perform an action
    modifier isDragon() {
        require(msg.sender == dragon);
        _;
    }

    // Modifier that allows only minions to perform an action
    modifier isMinion() {
        require(minions[msg.sender] == true);
        _;
    }

    // Events that log changes in the dynamics of the horde
    event MoodChange(bool mood);
    event ContributeGold(address indexed from, uint256 amount);
    event RequestGold(address indexed from, uint256 amount);

    // Constructor initializes address that deployed the contract as the dragon
    constructor() {
        dragon = msg.sender;
    }

    // Name the dragon
    // Only the dragon himself can set his name
    function setDragonName(string memory _name) external isDragon {
        dragonName = _name;
    }

    // Set the dragon's mood
    // true = good mood, false = bad mood
    function setMood(bool _mood) external isDragon {
        isGoodMood = _mood;

        // Log event MoodChange
        emit MoodChange(_mood);
    }

    // Appoint a minion via their address
    // Only the dragon can appoint minions
    // If an address has a value of true, minion
    function appointMinion(address _minion) public isDragon {
        minions[_minion] = true;
    }

    // Retire a minion via their address
    // Only the dragon can retire minions
    // If an address has a value of false, not a minion
    function retireMinion(address _minion) public isDragon {
        minions[_minion] = false;
    }

    // Contribute gold to the horde
    // Anyone can contribute gold
    function contributeGold() public payable {
        require(msg.value != 0, "The contribution cannot be nothing.");

        // Set mood to true (good mood) as a result of contribution
        isGoodMood = true;

        // Log events, ContributeGold and MoodChange
        emit ContributeGold(msg.sender, msg.value);
        emit MoodChange(isGoodMood);
    }

    // Request gold from the horde
    // Only minions can request gold
    function requestGold(address payable _to, uint256 _total) public isMinion {
        require(
            _total <= address(this).balance && isGoodMood == true,
            "Request denied."
        );

        // Set mood to false (bad mood) as a result of giving away gold
        isGoodMood = false;

        // Log RequestGold event
        emit RequestGold(msg.sender, _total);
        emit MoodChange(isGoodMood);

        // Transfer gold to the requesting minion
        _to.transfer(_total);
    }

    // Return the size of the horde
    // Only the dragon may know the size of the horde
    function getHordeSize() public view isDragon returns (uint256) {
        return address(this).balance;
    }
}
