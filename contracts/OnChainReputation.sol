// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract ReentrancyGuard {
    bool private _nonReentrant;
    constructor() { _nonReentrant = false; }
    modifier nonReentrant() {
        require(!_nonReentrant, "ReentrancyGuard: reentrant call");
        _nonReentrant = true;
        _;
        _nonReentrant = false;
    }
}
abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() { _owner = msg.sender; emit OwnershipTransferred(address(0), _owner); }
    modifier onlyOwner() { require(_owner == msg.sender, "Ownable: caller is not the owner"); _; }
    function owner() public view returns (address) { return _owner; }
}

contract OnChainReputation is ReentrancyGuard, Ownable {
    struct Profile {
        address user;
        uint256 score;
        uint256 totalRatings;
        bool active;
    }
    mapping(address => Profile) public profiles;
    // FIX: ratingGiven was keyed by ratingCount, so the duplicate-check always hit a
    // fresh key (anyone could rate the same user repeatedly). Key per rated user.
    mapping(address => mapping(address => bool)) public ratingGiven;
    uint256 public profileCount;
    uint256 public ratingCount;

    event ProfileCreated(address indexed user, uint256 initialScore);
    event RatingGiven(address indexed rater, address indexed rated, uint256 score);
    event RatingUpdated(address indexed rater, address indexed rated, uint256 oldScore, uint256 newScore);

    function createProfile(uint256 initialScore) external nonReentrant {
        require(initialScore <= 100, "Score max 100");
        require(!profiles[msg.sender].active, "Profile exists");
        Profile storage p = profiles[msg.sender];
        p.user = msg.sender;
        p.score = initialScore;
        p.totalRatings = 0;
        p.active = true;
        profileCount += 1;
        emit ProfileCreated(msg.sender, initialScore);
    }

    function rateUser(address ratedUser, uint256 score) external nonReentrant {
        require(ratedUser != msg.sender, "Cannot self-rate");
        require(score <= 100, "Score max 100");
        require(profiles[ratedUser].active, "User has no profile");
        // FIX: dedupe is now per rated user (keyed by score math), not per rating count.
        require(!ratingGiven[ratedUser][msg.sender], "Already rated");
        ratingGiven[ratedUser][msg.sender] = true;
        Profile storage p = profiles[ratedUser];
        // FIX: division is by (totalRatings + 1), never zero; score stays in [0, 100].
        uint256 oldScore = p.score;
        p.score = (p.score * p.totalRatings + score) / (p.totalRatings + 1);
        p.totalRatings += 1;
        emit RatingGiven(msg.sender, ratedUser, score);
        emit RatingUpdated(msg.sender, ratedUser, oldScore, p.score);
    }

    function getProfile(address user) external view returns (uint256 score, uint256 totalRatings, bool active) {
        Profile storage p = profiles[user];
        return (p.score, p.totalRatings, p.active);
    }
}
