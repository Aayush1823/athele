// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Athlete Management System
 * @dev Smart contract for managing athlete profiles and achievements on blockchain
 */
contract Project {
    address public owner;
    uint256 private athleteCounter;
    
    struct Athlete {
        uint256 id;
        string name;
        string sport;
        uint256 age;
        string country;
        uint256 achievementCount;
        bool isVerified;
        bool isActive;
        address athleteAddress;
    }
    
    struct Achievement {
        uint256 id;
        string title;
        string description;
        uint256 timestamp;
        bool isVerified;
    }
    
    mapping(uint256 => Athlete) public athletes;
    mapping(uint256 => mapping(uint256 => Achievement)) public athleteAchievements;
    mapping(address => uint256) public addressToAthleteId;
    
    event AthleteRegistered(uint256 indexed athleteId, string name, address athleteAddress);
    event AchievementAdded(uint256 indexed athleteId, uint256 achievementId, string title);
    event AthleteVerified(uint256 indexed athleteId, bool verified);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    modifier onlyAthleteOrOwner(uint256 _athleteId) {
        require(
            msg.sender == athletes[_athleteId].athleteAddress || msg.sender == owner,
            "Only athlete or owner can perform this action"
        );
        _;
    }
    
    constructor() {
        owner = msg.sender;
        athleteCounter = 0;
    }
    
    /**
     * @dev Core Function 1: Register a new athlete
     * @param _name Athlete's name
     * @param _sport Sport category
     * @param _age Athlete's age
     * @param _country Athlete's country
     */
    function registerAthlete(
        string memory _name,
        string memory _sport,
        uint256 _age,
        string memory _country
    ) public returns (uint256) {
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(bytes(_sport).length > 0, "Sport cannot be empty");
        require(_age > 0 && _age < 100, "Invalid age");
        require(addressToAthleteId[msg.sender] == 0, "Address already registered");
        
        athleteCounter++;
        
        athletes[athleteCounter] = Athlete({
            id: athleteCounter,
            name: _name,
            sport: _sport,
            age: _age,
            country: _country,
            achievementCount: 0,
            isVerified: false,
            isActive: true,
            athleteAddress: msg.sender
        });
        
        addressToAthleteId[msg.sender] = athleteCounter;
        
        emit AthleteRegistered(athleteCounter, _name, msg.sender);
        return athleteCounter;
    }
    
    /**
     * @dev Core Function 2: Add achievement to athlete profile
     * @param _athleteId Athlete's ID
     * @param _title Achievement title
     * @param _description Achievement description
     */
    function addAchievement(
        uint256 _athleteId,
        string memory _title,
        string memory _description
    ) public onlyAthleteOrOwner(_athleteId) {
        require(_athleteId > 0 && _athleteId <= athleteCounter, "Invalid athlete ID");
        require(athletes[_athleteId].isActive, "Athlete is not active");
        require(bytes(_title).length > 0, "Title cannot be empty");
        
        uint256 achievementId = athletes[_athleteId].achievementCount + 1;
        
        athleteAchievements[_athleteId][achievementId] = Achievement({
            id: achievementId,
            title: _title,
            description: _description,
            timestamp: block.timestamp,
            isVerified: false
        });
        
        athletes[_athleteId].achievementCount++;
        
        emit AchievementAdded(_athleteId, achievementId, _title);
    }
    
    /**
     * @dev Core Function 3: Verify athlete or achievement (only owner)
     * @param _athleteId Athlete's ID
     * @param _achievementId Achievement ID (0 to verify athlete, >0 to verify specific achievement)
     */
    function verifyAthleteOrAchievement(
        uint256 _athleteId,
        uint256 _achievementId
    ) public onlyOwner {
        require(_athleteId > 0 && _athleteId <= athleteCounter, "Invalid athlete ID");
        
        if (_achievementId == 0) {
            // Verify athlete
            athletes[_athleteId].isVerified = true;
            emit AthleteVerified(_athleteId, true);
        } else {
            // Verify specific achievement
            require(_achievementId <= athletes[_athleteId].achievementCount, "Invalid achievement ID");
            athleteAchievements[_athleteId][_achievementId].isVerified = true;
        }
    }
    
    // View functions
    function getAthleteDetails(uint256 _athleteId) public view returns (
        string memory name,
        string memory sport,
        uint256 age,
        string memory country,
        uint256 achievementCount,
        bool isVerified,
        bool isActive
    ) {
        require(_athleteId > 0 && _athleteId <= athleteCounter, "Invalid athlete ID");
        Athlete memory athlete = athletes[_athleteId];
        return (
            athlete.name,
            athlete.sport,
            athlete.age,
            athlete.country,
            athlete.achievementCount,
            athlete.isVerified,
            athlete.isActive
        );
    }
    
    function getAchievement(uint256 _athleteId, uint256 _achievementId) public view returns (
        string memory title,
        string memory description,
        uint256 timestamp,
        bool isVerified
    ) {
        require(_athleteId > 0 && _athleteId <= athleteCounter, "Invalid athlete ID");
        require(_achievementId > 0 && _achievementId <= athletes[_athleteId].achievementCount, "Invalid achievement ID");
        
        Achievement memory achievement = athleteAchievements[_athleteId][_achievementId];
        return (
            achievement.title,
            achievement.description,
            achievement.timestamp,
            achievement.isVerified
        );
    }
    
    function getTotalAthletes() public view returns (uint256) {
        return athleteCounter;
    }
    
    function getMyAthleteId() public view returns (uint256) {
        return addressToAthleteId[msg.sender];
    }
}
