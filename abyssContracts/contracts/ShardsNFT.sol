pragma solidity ^0.6.0;

import "./tokens/ERC/ERC721/ERC721.sol";






// 
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



contract ShardsNFT is ERC721, Ownable {

    uint256 _tokenIds = 0;

   

     


    struct ShardData {

        //the token eaten
        address _tokenEaten;

        //amount of token eaten
        uint256 _amount;

        //obol amount that was used
        uint256 _obolamount;

        uint256 _timeMinted;

        
    }



    ShardData[] sharddata;


    address public _styx;



    constructor(string memory baseURI_, address styx) ERC721("Abyss Shard", "SHARD") public {

        _setBaseURI(baseURI_);

        _styx = styx;
    }


  

    /* Set minimumAby */

    function setStyx(address _newStyx) onlyOwner public {

        _styx = _newStyx;

    }


    function awardItem(address player, address tokenEaten, uint256 amount, uint256 obolamount/*, string memory tokenUR*/) public returns (uint256) {
        
        require(msg.sender == _styx || msg.sender == owner());


        uint256 newItemId = _tokenIds;
        _mint(player, newItemId);
        //_setTokenURI(newItemId, tokenURI);


        ShardData memory _shard = ShardData({
                    _tokenEaten: tokenEaten,
                    _amount: amount,
                    _obolamount: obolamount,
                    _timeMinted: block.timestamp
                });
        sharddata.push(_shard);




        _tokenIds = _tokenIds.add(1);



        return newItemId;
    }




    function getInfoFor(uint256 tokenId) public view returns (address,address,uint256,uint256,uint256) {
      
        return (
            ownerOf(tokenId),
            sharddata[tokenId]._tokenEaten,
            sharddata[tokenId]._amount,
            sharddata[tokenId]._obolamount,
            sharddata[tokenId]._timeMinted
        );
    }




}