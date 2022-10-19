// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Twitter {
    // ----- START OF DO-NOT-EDIT ----- //
    struct Tweet {
        uint tweetId;
        address author;
        string content;
        uint createdAt;
    }

    struct Message {
        uint messageId;
        string content;
        address from;
        address to;
    }

    struct User {
        address wallet;
        string name;
        uint[] userTweets;
        address[] following;
        address[] followers;
        mapping(address => Message[]) conversations;
    }

    mapping(address => User) public users;
    mapping(uint => Tweet) public tweets;

    uint256 public nextTweetId;
    uint256 public nextMessageId;
    // ----- END OF DO-NOT-EDIT ----- //

    // ----- START OF QUEST 1 ----- //
    function registerAccount(string calldata _name) external {
        bytes memory tempName = bytes(_name);
        require(tempName.length > 0, "Name cannot be an empty string");
        User storage user = users[msg.sender];
        user.name = _name;
        user.wallet = msg.sender;
    }

    function postTweet(string calldata _content) external accountExists(msg.sender) {     
        Tweet storage tweet = tweets[nextTweetId];
        tweet.author = msg.sender;
        tweet.content = _content;
        tweet.createdAt = block.timestamp;
        tweet.tweetId = nextTweetId;
        User storage user = users[msg.sender];
        user.userTweets.push(nextTweetId);
        nextTweetId++;
    }

    function readTweets(address _user) view external returns(Tweet[] memory) {
        User storage user = users[_user];
        uint[] memory userTweetIds = user.userTweets;
        uint length = userTweetIds.length;
        Tweet[] memory userTweets = new Tweet[](length);
        for(uint i = 0; i < length; i++){
            userTweets[i] = tweets[userTweetIds[i]];
        }
        return userTweets;
    }

    modifier accountExists(address _user) {
        User storage sender = users[msg.sender];
        bytes memory tempName = bytes(sender.name);
        require(tempName.length > 0, "This wallet does not belong to any account.");
        _;
    }
    // ----- END OF QUEST 1 ----- //

    // ----- START OF QUEST 2 ----- //
    function followUser(address _user) external {
        User storage followerUser = users[msg.sender];
        followerUser.following.push(_user);
        User storage followingUser = users[_user];
        followingUser.followers.push(msg.sender);
    }

    function getFollowing() external view returns(address[] memory)  {
        User storage user= users[msg.sender];
        return user.following;
    }

    function getFollowers() external view returns(address[] memory) {
        User storage user= users[msg.sender];
        return user.followers;
    }

    function getTweetFeed() view external returns(Tweet[] memory) {
        Tweet[] memory tweetArray = new Tweet[](nextTweetId);
        for(uint i = 0; i < nextTweetId; i++){
            tweetArray[i] = tweets[i];
        }
        return tweetArray;
    }

    function sendMessage(address _recipient, string calldata _content) external {
        User storage userSender = users[msg.sender];
        User storage userRecepient = users[_recipient];
        Message memory message = Message(nextMessageId, _content, msg.sender, _recipient);
        userSender.conversations[_recipient].push(message);
        userRecepient.conversations[msg.sender].push(message);
        nextMessageId++;
    }

    function getConversationWithUser(address _user) external view returns(Message[] memory) {
        User storage user = users[msg.sender];
        return user.conversations[_user];
    }
    // ----- END OF QUEST 2 ----- //
}