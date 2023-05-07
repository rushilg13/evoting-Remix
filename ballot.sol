/**
 * @file ballot.sol
 * @author Jackson Ng <jackson@jacksonng.org>
 * @date created 22nd Apr 2019
 * @date last modified 30th Apr 2019
 */

pragma solidity ^0.5.0;

contract Ballot {

    struct vote{
        address voterAddress;
        string choice;
    }
    
    struct voter{
        string voterName;
        bool voted;
    }

    uint private countResult = 0;
    uint public finalResult = 0;
    uint public totalVoter = 0;
    uint public totalVote = 0;
    address public ballotOfficialAddress;      
    string public ballotOfficialName;
    string public proposal;
    bytes32 private messageHash;
    
    mapping(uint => vote) private votes;
    mapping(address => voter) public voterRegister;
    
    enum State { Created, Voting, Ended }
	State public state;
	
	//creates a new ballot contract
	constructor(
        string memory _ballotOfficialName,
        string memory _proposal) public {
        ballotOfficialAddress = msg.sender;
        ballotOfficialName = _ballotOfficialName;
        proposal = _proposal;
        
        state = State.Created;
    }
    
    
	modifier condition(bool _condition) {
		require(_condition);
		_;
	}

	modifier onlyOfficial() {
		require(msg.sender ==ballotOfficialAddress);
		_;
	}

	modifier inState(State _state) {
		require(state == _state);
		_;
	}

    event voterAdded(address voter);
    event voteStarted();
    event voteEnded(uint finalResult);
    event voteDone(address voter);
    
    //add voter
    function addVoter(address _voterAddress, string memory _voterName)
        public
        inState(State.Created)
        onlyOfficial
    {
        voter memory v;
        v.voterName = _voterName;
        v.voted = false;
        voterRegister[_voterAddress] = v;
        totalVoter++;
        emit voterAdded(_voterAddress);
    }

    //declare voting starts now
    function startVote()
        public
        inState(State.Created)
        onlyOfficial
    {
        state = State.Voting;     
        emit voteStarted();
    }

    // Function to get hash value
    function getMessageHash() public view returns (bytes32) {
        return messageHash;
    }

    //voters vote by indicating their choice (true/false)
    function doVote(string memory _choice)
        public
        inState(State.Voting)
        returns (bool voted)
    {
        bool found = false;
        
        if (bytes(voterRegister[msg.sender].voterName).length != 0 
        && !voterRegister[msg.sender].voted){
            voterRegister[msg.sender].voted = true;
            vote memory v;
            v.voterAddress = msg.sender;
            v.choice = _choice;
            if (keccak256(abi.encodePacked("6273151f959616268004b58dbb21e5c851b7b8d04498b4aabee12291d22fc034 ")) == keccak256(abi.encodePacked(_choice))){
                messageHash = keccak256(bytes(_choice));
                countResult++; //counting on the go
            }
            else if (keccak256(abi.encodePacked("ba9154e0baa69c78e0ca563b867df81bae9d177c4ea1452c35c84386a70f0f7a")) == keccak256(abi.encodePacked(_choice))){
                messageHash = keccak256(bytes(_choice));
            }
            votes[totalVote] = v;
            totalVote++;
            found = true;
        }
        emit voteDone(msg.sender);
        return found;
    }
    
    //end votes
    function endVote()
        public
        inState(State.Voting)
        onlyOfficial
    {
        state = State.Ended;
        finalResult = countResult; //move result from private countResult to public finalResult
        emit voteEnded(finalResult);
    }
}
