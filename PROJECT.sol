// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LearnToEarn {
    struct Lesson {
        string title;
        uint256 reward; // Reward in Wei
        bool completed;
    }

    address public owner;
    mapping(address => uint256) public balances;
    mapping(address => Lesson[]) public userLessons;

    event LessonCreated(address user, string title, uint256 reward);
    event LessonCompleted(address user, string title, uint256 reward);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() { 
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    function createLesson(address user, string memory title, uint256 reward) public onlyOwner {
        userLessons[user].push(Lesson({title: title, reward: reward, completed: false}));
        emit LessonCreated(user, title, reward);
    }

    function completeLesson(uint256 lessonIndex) public {
        require(lessonIndex < userLessons[msg.sender].length, "Invalid lesson index.");
        Lesson storage lesson = userLessons[msg.sender][lessonIndex];
        require(!lesson.completed, "Lesson already completed.");
        
        lesson.completed = true;
        balances[msg.sender] += lesson.reward;

        emit LessonCompleted(msg.sender, lesson.title, lesson.reward);
    }

    function withdraw() public {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "Insufficient balance.");
        
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function depositRewards() public payable onlyOwner {
        require(msg.value > 0, "Must send some Ether to fund rewards.");
    }

    function getLessons(address user) public view returns (Lesson[] memory) {
        return userLessons[user];
    }
}