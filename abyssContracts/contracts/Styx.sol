pragma solidity ^0.6.2;
/*
/
/                     ,dS$Sb,       ;$$$
/                   ,$$P^`^²$$,     ;$$$
/    $$$$$$$$$$$$$',$$;,$$$,;$$,`$$ I$$I $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
/  $$$$$$P"²²╩?S$';$$;,$$$$$,;$$;P';$$$',$$$$$$$$$$$$$$$$P²"`.`,`$$$P²"`.`,`$$
/ $$$$$$';$SS#%y,;$$;_╩?$$$$$,;$$ ;$$$',$P²╩P"``"$$²"""",d$',yyyy$',d$' yyyy$$$
/ $$$$$;;$$SP╩²²;$$;,$#y▬,"²?$ $$;$$$' ,ySSy,$$$ $$ $$$;$$$;,`²?$$,$$$;,`²?$$$$$
/ $$SP╩ ╩"` "? ;$$; b,`^╩S$b,`+;$$$$I,$$"`"$$$$;;$$;;$$$`╩S$$$Sy,"?`╩S$$$Sy,`?$$$
/ ,y%#S$$$²"` ;$$;         "?$, ;$$$;  `   ;$$$      $$$ ,y+`"²$$$; ,y+`"²$$$;$$$
/ $$$$SS'    ;$$;  i_L       `?$,$$$$;     $$$$;    ;$$$$$;    ;$$$$$;    ;$$$;$$
/ ;$$S$;.,▬y$$$;               `$$$$$$,__,$$$?$$,__,$S$$$$;    ;$$$$$;    ;$$$;$$
/  `²?S$$$SP²'∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙∙ `I$I`²S$$S²'  `²S$$S²IS$$$$,__,$$$;$$$,__,$$$;$$
/ :       -x- ABY/ah -x-         $$;   :           ;$$I`²S$$S²''  `²S$$S²''
/ :                              :$$   :            $$$
/ :  / solidity. : m4ss, VAC     -:$   :            I$$;
/ :  / design    : VAC, m4ss       ;   :            ;$$I
/ :  / I0        : 1unacy              :
/ :  / stack     : m4ss                :
/ :  / counsel   : 7dlm                :
/ :  / math      : 1unacy, 7dlm.       :
/ :  / stratagem : 1unacy, VAC.        :
/ :....................................:

////////////////////***////////////////////
/*  AT THIS POINT, UPGRADE IS NOT TESTED */
///////////////////***/////////////////////

import "./lib/MultipleOwnable.sol";

import "./tokens/ERC/ERC20/IERC20.sol";


import "./tokens/ERC/ERC20/SafeERC20.sol";

import "./lib/IUniswap.sol";






interface IShard {

    function awardItem(address player, address tokenEaten, uint256 amount, uint256 obolamount) external returns (uint256);

}









contract Styx is MultipleOwnable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;



    /*bool to stop proposale and prepare upgrade*/

    bool public waitingUpgrade;

    /*delay that people have to withdraw aby until a migration*/

    uint256 public waitingUpgradeTime;


    uint256 private constant aDay = 86400;


    /* Contract Variables and events */
    uint public minimumQuorum;


    uint256 public tokentoeats;

    mapping (uint256 => address) public tokentoeat;

    //date proposal created and safe
    uint256 public safeDay = aDay;
    mapping (uint256 => uint256) public proposalDate;



    //addy->id->votes
    mapping (address => mapping(uint256 => uint256)) public tokenVote;
    //addy->id->bool
    mapping (address => mapping(uint256 => bool)) public tokenVoteEaten;
    //addy->id->bool
    mapping (address => mapping(uint256 => bool)) public obolFailed;




    event ProposalAdded(address NextTokenToEat,uint256 timeWas);

    event Voted(address NextTokenToEat, address voter, uint256 weight);

    event ProposalTallied(address NextTokenToEat, uint quorum, uint256 timeWas);

    event ChangeOfRules(uint minimumQuorum);

    event Eat (address dead, uint256 eth, uint256 token, address sd, uint256 timeWas);





    /*ABY* token governance */


    IERC20 public aby;

    IERC20 public obol;



    IShard public shardNft;




    //current token to be eaten
    address public nextTokenToEat = address(0);

    address public weth;



    //tokens stacked by vote
    //user address->token address->id->balance
    mapping(address => mapping(address => mapping(uint256 => uint256))) private _abyBalances;

    //tokens stacked by obol
    //user address->token address->id->balance
    mapping(address => mapping(address => mapping(uint256 => uint256))) private _obolBalances;


    //latest obol highest bidder

    address public highBidder;


    //latest obol highest bidder

    uint256 public totalObol;


    //latest obol highest bidder amount

    uint256 public highBidderAm;


    //perc to keep in the abyss for Styx, creating bigger and bigger balance

    uint public percKeep = 10;

  
    //minimum amount of ABY to initial a vote

    uint public minimumAby = 10 ether;


    //uniswap
    address public uniswapAddress;


    //abyss
    address public abyss;


    //pools
    mapping (address => bool) public pools;



    /* mod allows only shareholders to vote and create new proposals */
    modifier onlyAbyMembers {
        require(aby.balanceOf(msg.sender) > 0);
        _;
    }

    modifier onlyObolMembers {
        require(obol.balanceOf(msg.sender) > 0);
        _;
    }


    /* mod only pools */

    modifier onlyPools (address pool) {
        require(pools[pool]);
        _;
    }



  

     /* First time setup */
    constructor (uint minimumQuorumForProposals
    ) public  {
        
        changeVotingRules(minimumQuorumForProposals);


    }



    fallback() external{
        revert();
    }

    receive() payable external{
        //revert();
    }


    /* Function to init contracts to use in Styx */
    function init(address _aby, address _obol, address _shard, address _abyss)  public onlyOwner  {



        //setting the aby and obol tokens
        aby = IERC20(_aby);

        obol = IERC20(_obol);


        uniswapAddress = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        weth = address(0xc778417E063141139Fce010982780140Aa0cD5Ab);


        shardNft = IShard(_shard);


        abyss = _abyss;

    }

    /* Ch.rules */
    function changeVotingRules(
        uint minimumQuorumForProposals
    ) onlyOwner public {
        minimumQuorum = minimumQuorumForProposals;

        emit ChangeOfRules(minimumQuorum);
    }



    /* Pool functions */

    function managePools(address pool, bool status) onlyOwner public {

        pools[pool] = status;

    }

     /* Set safeDay */

    function setSafeDay(uint256 _amountOfDay) onlyOwner public {

        safeDay = _amountOfDay.mul(aDay);

    }

    

    /* Set percKeep */

    function setPercKeep(uint256 _percAmount) onlyOwner public {

        percKeep = _percAmount;

    }

     /* Set minimumAby */

    function setMinimumAby(uint256 _abyAmount) onlyOwner public {

        minimumAby = _abyAmount;

    }



    /* New proposal creation function - token feast */
    function newProposal(
        //address beneficiary,
        //uint etherAmount,
        address _nextTokenToEat,
        uint256 abyam
    )
        public
        onlyAbyMembers
        returns (uint proposalID)
    {

        require(!waitingUpgrade);

        require(abyam >= minimumAby);

        tokentoeat[tokentoeats] = _nextTokenToEat;

        proposalDate[tokentoeats] = block.timestamp;

        tokentoeats = tokentoeats.add(1);

        voteAby(abyam,tokentoeats.sub(1));



        emit ProposalAdded(_nextTokenToEat, block.timestamp);


        return tokentoeats.sub(1);
    }

    /* Function to return address from a proposal id */
    function returnAddyForId(uint256 id) public view returns(address){
        return tokentoeat[id];
    }

    /* Function to execute proposal, opening obol bids */
    function executeProposal(uint256 id) public {
        address _nextTokenToEat = returnAddyForId(id);
        require(!waitingUpgrade);
        require(nextTokenToEat == address(0));
        require(tokenVote[_nextTokenToEat][id] >= minimumQuorum && !tokenVoteEaten[_nextTokenToEat][id]);

        require(block.timestamp >= proposalDate[id].add(safeDay));




        tokenVoteEaten[_nextTokenToEat][id] = true;

        nextTokenToEat = _nextTokenToEat;




        // Fire Events
        emit ProposalTallied(_nextTokenToEat, tokenVote[_nextTokenToEat][id],block.timestamp);
    }


    /* Internal function to add the initial vote for aby */
    function voteAby(uint256 amount, uint256 id) internal {
        address _nextTokenToEat = returnAddyForId(id);
        //require no next token to eat to be set for aby vote. this way when one choosen, until OBOL vote, no vote on proposal.
        require(nextTokenToEat == address(0));


        tokenVote[_nextTokenToEat][id] = tokenVote[_nextTokenToEat][id].add(amount);
        _abyBalances[msg.sender][_nextTokenToEat][id] = _abyBalances[msg.sender][_nextTokenToEat][id].add(amount);
        aby.safeTransferFrom(msg.sender, address(this), amount);
    }

    /* Function to vote aby for a proposal */
    function voteAbyExt(uint256 amount, uint256 id) public {
        address _nextTokenToEat = returnAddyForId(id);

        //require no next token to eat to be set for aby vote. this way when one choosen, until OBOL vote, no vote on proposal.
        require(nextTokenToEat == address(0));

        require(tokenVote[_nextTokenToEat][id]> 0);
        tokenVote[_nextTokenToEat][id] = tokenVote[_nextTokenToEat][id].add(amount);
        _abyBalances[msg.sender][_nextTokenToEat][id] = _abyBalances[msg.sender][_nextTokenToEat][id].add(amount);
        aby.safeTransferFrom(msg.sender, address(this), amount);
    }

    /* Redeem aby from votes as long there is no nextTokenToEat set  */
    function redeemAby(uint256 amount, uint256 id) public {
        address _nextTokenToEat = returnAddyForId(id);
        require(nextTokenToEat == address(0));

        _abyBalances[msg.sender][_nextTokenToEat][id] = _abyBalances[msg.sender][_nextTokenToEat][id].sub(amount);
        tokenVote[_nextTokenToEat][id] =tokenVote[_nextTokenToEat][id].sub(amount);
        aby.safeTransfer(msg.sender, amount);
    }

    /* Redeem obol function, unburned because of uniswap fail_errors */
    function redeemObol(uint256 amount, uint256 id) public {
        address tokenthatfailed = returnAddyForId(id);
        require(obolFailed[tokenthatfailed][id]);

        _obolBalances[msg.sender][tokenthatfailed][id] = _obolBalances[msg.sender][tokenthatfailed][id].sub(amount);

        require(obol.transfer(msg.sender, amount));

    }


    /* Function to let pools and strats borrow from Styx */

    function takeALoan(uint256 amount) onlyPools(msg.sender) public returns (bool) {


        address payable receiver = payable(msg.sender);
        receiver.transfer(amount);

        return true;

    }

   







     /* Function returns true on uniswap trade to prevent the nextTokenToEat failed and stuck if price impact is too high */
    function sellTokenForEth(address token, uint256 amountToEat) internal returns (bool){


         // (Uniswap allows ERC20:ERC20 but most liquidity is on ETH:ERC20 markets)
            IUniswap uniswap = IUniswap(uniswapAddress);

            address[] memory path = new address[](2);
            path[0] = address(weth);
            path[1] = address(token);
            uniswap.swapExactETHForTokens{value : amountToEat}(
                //minOuts[0],
                 0,
                 path,
                 address(this),
                 now
            );

            return true;

    }


    /* Bid obol to propagate the proposal. Winner made the bid that made the totalObol reach the amount to eat. NFT */
    function bid(uint256 amount, uint256 id) onlyObolMembers public {

        //require next token to eat to be set for obol vote. this way when one choosen, until OBOL vote, no vote on proposal, and bid logic for the winner bidder.
        require(nextTokenToEat != address(0),"nextTokenToEat 0");

        require(tokentoeat[id] == nextTokenToEat ,"nextTokenToEat incorrect");

        require(obol.transferFrom(msg.sender, address(this), amount),"obol app");


        if(amount > highBidderAm){

            highBidder = msg.sender;
            highBidderAm = amount;
        }

        totalObol = totalObol.add(amount);




        _obolBalances[msg.sender][nextTokenToEat][id].add(amount);

        uint256 amountToEat = address(this).balance.sub((address(this).balance.mul(percKeep)).div(100));


        if(totalObol >= (amountToEat)){

            //if obol amount is bigger or same than eth value in, should give the NFT or ask Styx to burn obol and send the eth to uniswap and burn the desired token
            highBidder = address(0);
            highBidderAm = 0;

            //set back NextTokenToEat to zero

            tokenVoteEaten[nextTokenToEat][id] = false;

            

            uint256 obolToAb = totalObol;

            totalObol = 0;

            address prevToken = nextTokenToEat;

            nextTokenToEat = address(0);

            
            


            if(sellTokenForEth(prevToken, amountToEat)){

                //burn obol
                require(obol.transfer(abyss, obolToAb) ,"obol to abyss");



                IERC20 blToken = IERC20(prevToken);

                //Mint NFT
                shardNft.awardItem(msg.sender, prevToken, blToken.balanceOf(abyss), obolToAb);




                obolFailed[prevToken][id] = false;

                emit Eat(prevToken, amountToEat, blToken.balanceOf(address(this)), abyss, block.timestamp);

                blToken.transfer(abyss, blToken.balanceOf(address(this)));


            }else{
                //cannot sell on uniswap, mark as failed so people can redeem their obol
                obolFailed[prevToken][id] = true;
            }

            



        }





    }


    /*function to upgrade Styx to a new copy, letting people withdraw tokens, then migrate*/

    function initiateUpgrade(uint256 _Days) public onlyOwner {

        //being fair
        require(_Days >= 7);

        //setting the delay and blocking proposal
        waitingUpgrade = true;
        //set in X delay
        waitingUpgradeTime = block.timestamp.add(_Days.mul(aDay));
        //setting to zero so withdraw aby possible.
        nextTokenToEat = address(0x0);

    }

    /* function that upgrade Styx, send the ether balance, burn obol, self destruc*/


    function upgrade(address _newStyx) public onlyOwner {

        //require time
        require(block.timestamp >= waitingUpgradeTime && waitingUpgrade);

        //move ether

        payable(address(_newStyx)).transfer(address(this).balance);


        //burn obol
        require(obol.transfer(abyss, obol.balanceOf(address(this))));

        //so sad but burn aby
        require(aby.transfer(abyss, aby.balanceOf(address(this))));


    }



}