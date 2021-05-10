// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./MyERC20.sol";
import "./dependencies/VRFConsumerBase.sol";

contract TestgroundGame is VRFConsumerBase {
  string public logger = "init";
  // Chainlink internal setup
  bytes32 internal keyHash;
  uint256 internal fee;

  // Random handlers

  mapping(bytes32 => address) public player;
  mapping(address => string) public player_state;
  mapping(address => bytes32) public player_match;
  mapping(bytes32 => mapping(uint256 => string)) public attacker_characters;
  mapping(bytes32 => mapping(uint256 => string)) public attacked_characters;
  mapping(bytes32 => mapping(uint256 => uint256)) public damage_dealt;

  constructor()
  public
  VRFConsumerBase(
    0x8C7382F9D8f56b33781fE506E897a4F1e2d17255 /* VRF Coordinator */,
    0x326C977E6efc84E512bB9C30f76E30c160eD06FB /* Link Mumbai Token Contract */)
  {
    keyHash = 0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4;
    fee = 0.0001 * 10 ** 18;

    logger = "construct";
  }

  function roll(uint256 userProvidedSeed) public returns (bytes32 _requestId) {
    require(LINK.balanceOf(address(this)) > fee, "Not enough LINK - fill contract with faucet");
    bytes32 requestId = requestRandomness(keyHash, fee, userProvidedSeed);

    player[requestId] = msg.sender;
    player_state[msg.sender] = "waiting for oracle";
    player_match[msg.sender] = requestId;

    logger = "roll";

    return requestId;
  }

  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
    player_state[player[requestId]] = "match generated";
    logger = "fulfill";

    string memory attacker = "priest";
    if(randomness%4==1)attacker = "warrior";if(randomness%4==2)attacker = "wizard";if(randomness%4==3)attacker = "rogue";
    attacker_characters[requestId][0] = attacker;
    attacked_characters[requestId][0] = "dragon";
    damage_dealt[requestId][0] = randomness%2000;

    randomness/=7;
    string memory attacked = "priest";
    if(randomness%4==1)attacked = "warrior";if(randomness%4==2)attacked = "wizard";if(randomness%4==3)attacked = "rogue";
    attacker_characters[requestId][1] = "dragon";
    attacked_characters[requestId][1] = attacked;
    damage_dealt[requestId][1] = randomness%10000;

    randomness/=13;
    attacked = "priest";
    if(randomness%4==1)attacked = "warrior";if(randomness%4==2)attacked = "wizard";if(randomness%4==3)attacked = "rogue";
    attacker_characters[requestId][2] = attacked;
    attacked_characters[requestId][2] = "dragon";
    damage_dealt[requestId][2] = randomness%2000;

    randomness/=17;
    attacked = "priest";
    if(randomness%4==1)attacked = "warrior";if(randomness%4==2)attacked = "wizard";if(randomness%4==3)attacked = "rogue";
    attacker_characters[requestId][3] = "dragon";
    attacked_characters[requestId][3] = attacked;
    damage_dealt[requestId][3] = randomness%10000;
    /**/
  }
}
