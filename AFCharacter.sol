// SPDX-License-Identifier: Unlicensed

// This is a work in progress.  All elements are subject to change.

pragma solidity 0.8.10;
import "hardhat/console.sol";
import "./AFRoles.sol";
import "./ConstantsAF.sol";

contract AFCharacter is AFRoles{
  string public name = 'AFCharacter';

  enum Rarities { RARE1, RARE2, SUPERRARE1, SUPERRARE2, 
                  EPIC1, EPIC2, LEGENDARY1, LEGENDARY2, 
                  MYTHIC1, MYTHIC2 }
  
  // The characters that currently have availability
  uint256[] public availableCharacters = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25];

  // Defines a character and their attributes
  struct Character {
    // The character name
    string name;
    // The rarity of the character
    Rarities rarity;
    // The number of this character can be minted, total
    uint256 scarcity;
    // The total number of times this character has been minted
    uint256 supply;
    //The name of the artist
    bytes32 artist;
    //The name of the series
    bytes32 series;
    //The name of the collection
    bytes32 collection;
    
  }

  // All available characters currently registered in the contract
  mapping (uint256 => Character) public allCharactersEver;


  bytes32 constant _artist = "Todd Wahnish";
  bytes32 constant _series = "Season 1/Genesis";
  bytes32 constant _collection = "Adult Fantasy";
  
  constructor ()
  {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
  }


  // This can be publicly accessed safely
  function getCharacter(uint256 characterID) view external returns(Character memory){
    return allCharactersEver[characterID]; 
  }

  function getCharacterTotalSupply(uint256 characterID) view external returns (uint256) {
    return allCharactersEver[characterID].supply;
  }

  // Gets the length of the availableCharacters array
  function getAvailableCharactersCount() view external returns (uint256) {
    return availableCharacters.length;
  }

  function incrementCharacterSupply (uint256 characterID) private {
    allCharactersEver[characterID].supply += 1;

    // Making character unavailable if the character is sold out
    if(allCharactersEver[characterID].supply == allCharactersEver[characterID].scarcity) {
      removeCharacterFromAvailableCharacters(characterID);
    }
  }

  function getCharacterSupply (uint256 characterID) external view returns (uint256) {
    return allCharactersEver[characterID].supply;
  }

  // Picks a random character ID from the list of characters with availability for minting, increments character supply
  // and decrements available character count
  function takeRandomCharacter() external onlyContract returns (uint256) {
    uint256 arrayCount = availableCharacters.length;

    // Checking to make sure characters are available to mint
    require(arrayCount > 0, ConstantsAF.noCharacters_e);

    uint256 randomCharacterArrayIndex = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp))) % arrayCount;
    uint256 characterID = availableCharacters[randomCharacterArrayIndex];

    // Checking to make sure the random character we picked exists
    require(bytes(allCharactersEver[characterID].name).length != 0, ConstantsAF.invalidCharacter_e);

    
    incrementCharacterSupply(characterID);
    delete arrayCount;
    delete randomCharacterArrayIndex;
    return characterID;
  }

  function removeCharacterFromAvailableCharacters(uint256 characterID) private {
    uint256 arrayCount = availableCharacters.length;
    uint256 index = 0;
    // find index of character to be removed
    for(index; index<arrayCount; index++){
      if(availableCharacters[index] == characterID){
        break;
      }
    }
    availableCharacters[index] = availableCharacters[availableCharacters.length - 1];
    availableCharacters.pop();
    delete arrayCount;
    delete index;
  }

  function makeCharacters(string[] memory names, 
                          int8[] memory rarities, 
                          uint256[] memory scarcities) external onlyEditor {
    for(uint256 index = 0; index < names.length; index++){
      Character storage char = allCharactersEver[index + 1];
      char.name = names[index];
      char.rarity = Rarities(rarities[index]);
      char.scarcity = scarcities[index];
      char.supply = 0;
      char.artist = _artist;
      char.collection = _collection;
      char.series = _series;
    }
  }
}
