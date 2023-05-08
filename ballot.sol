pragma solidity ^0.5.0;

contract Ballot {
    struct vote {
        address voterAddress;
        string choice;
    }

    struct voter {
        string voterName;
        bool voted;
    }

    uint256 private countResult = 0;
    uint256 public finalResult = 0;
    uint256 public totalVoter = 0;
    uint256 public totalVote = 0;
    address public ballotOfficialAddress;
    string public ballotOfficialName;
    string public proposal;
    string public hashed;
    string public hashedd;
    string public msg_sec;
    string public choice;
    bytes32 public _bytes32;
    bytes32 public temp;
    bytes public result2;
    bytes public result;

    mapping(uint256 => vote) private votes;
    mapping(address => voter) public voterRegister;

    enum State {
        Created,
        Voting,
        Ended
    }
    State public state;

    //creates a new ballot contract
    constructor(string memory _ballotOfficialName, string memory _proposal)
        public
    {
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
        require(msg.sender == ballotOfficialAddress);
        _;
    }

    modifier inState(State _state) {
        require(state == _state);
        _;
    }

    event voterAdded(address voter);
    event voteStarted();
    event voteEnded(uint256 finalResult);
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
    function startVote() public inState(State.Created) onlyOfficial {
        state = State.Voting;
        emit voteStarted();
    }

    //voters vote by indicating their choice (true/false)
    function doVote(string memory _choice)
        public
        inState(State.Voting)
        returns (bool voted)
    {
        bool found = false;

        if (
            bytes(voterRegister[msg.sender].voterName).length != 0 &&
            !voterRegister[msg.sender].voted
        ) {
            voterRegister[msg.sender].voted = true;
            vote memory v;
            v.voterAddress = msg.sender;

            bytes memory strBytes = bytes(_choice);
            result = new bytes(5);
            for (uint256 i = 0; i < 5; i++) {
                result[i] = strBytes[i];
            }
            v.choice = string(result);
            choice = string(result);

            result2 = new bytes((bytes(_choice).length) - 5);
            for (uint256 j = 5; j < (bytes(_choice).length); j++) {
                choice = "blah";
                result2[j - 5] = strBytes[j];
            }
            hashed = string(result2);

            msg_sec = string(abi.encodePacked(v.choice, "SECRET"));

            temp = (keccak256(abi.encodePacked(msg_sec)));
            bytes memory bytesArray = new bytes(32);
            for (uint256 i; i < 32; i++) {
                bytesArray[i] = _bytes32[i];
            }
            hashedd = string(bytesArray);

            if (
                keccak256(abi.encodePacked(hashed)) ==
                keccak256(abi.encodePacked(temp))
            ) {
                if (
                    (keccak256(abi.encodePacked("ttrue")) ==
                        keccak256(abi.encodePacked(v.choice)))
                ) {
                    countResult++; //counting on the go
                }
            }
            votes[totalVote] = v;
            totalVote++;
            found = true;
        }
        emit voteDone(msg.sender);
        return found;
    }

    //end votes
    function endVote() public inState(State.Voting) onlyOfficial {
        state = State.Ended;
        finalResult = countResult; //move result from private countResult to public finalResult
        emit voteEnded(finalResult);
    }
}
