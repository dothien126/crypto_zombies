// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "./Ownable.sol";
import "./SafeMath.sol";

contract ZombieFactory is Ownable {
    using SafeMath for uint256;

    uint256 dnaDigits = 16;
    uint256 dnaModulus = 10**dnaDigits;
    Zombie[] public zombies;
    mapping(uint256 => address) public zombieToOwner;
    mapping(address => uint256) ownerZombieCount;
    uint256 cooldownTime = 1 days;

    struct Zombie {
        string name;
        uint256 dna;
        uint256 level;
        uint256 readyTime;
        uint256 winCount;
        uint256 lossCount;
    }

    event NewZombie(uint256 zombieId, string name, uint256 dna);

    function _createZombie(string memory _name, uint256 _dna) internal {
        zombies.push(
            Zombie(
                _name,
                _dna,
                1,
                uint256(block.timestamp + cooldownTime),
                0,
                0
            )
        );
        uint256 id = zombies.length - 1;
        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].add(1);
        emit NewZombie(id, _name, _dna);
    }

    function _generateRandomDna(string memory _str)
        private
        view
        returns (uint256)
    {
        uint256 rand = uint256(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

    function createRandomZombie(string memory _name) public {
        require(ownerZombieCount[msg.sender] == 0, "You've got a zombie");
        uint256 randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }
}
