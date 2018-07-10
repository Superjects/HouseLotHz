pragma solidity ^0.4.23;


contract FixdedCursor {
    uint32 public startBlock;
    uint32 public endBlock;
    uint8 public minCount;
    uint8 public maxCount;
    mapping(address => uint8) private voteOf;

    uint8 public count;
    uint private voted;
    bool public finished;

    event vote_done(uint8 _count,uint _voted);

    constructor(
        uint32 start_block,
        uint32 end_block,
        uint8 min_count,
        uint8 max_count
    ) public {
        require(start_block>block.number);
        require(end_block>start_block);
        require(min_count>1);
        require(max_count>min_count);
    
        startBlock=start_block;
        endBlock=end_block;
        minCount=min_count;
        maxCount=max_count;
    
        count = 0;
        voted =0;
        finished=false;
    }

    modifier canVote() {
        if (finished) revert();
        else if(block.number<startBlock) revert();
        else if(voteOf[msg.sender]>0) revert();
        else _;
    }

    function vote(uint8 number) public canVote{
        if(block.number>endBlock){
            finished=true;
            emit vote_done(count,voted);
        }else{
            require(number>0 && number<10);
            voted=voted*10+number;
            voteOf[msg.sender] = number;
            count++;
            if(count>=maxCount){
                finished=true;
                emit vote_done(count,voted);
            }
        }
    }
   
    function refresh() public{
        if(finished) revert();
        if(block.number<=endBlock) revert();
        else{
            finished=true;
            emit vote_done(count,voted);
        }
    }
  
    function getVoteOf(address voter) public view returns (uint8){
        return (finished||voter==msg.sender)?voteOf[voter]:0;
    }
 
    function getVoted() public view returns (uint) {
        return finished?voted:0;
    }


}