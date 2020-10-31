pragma solidity ^0.6.0;

import "./tokens/ERC/ERC721/ERC721.sol";






contract ShardsNFT is ERC721 {

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


    address public _charon;



    constructor(string memory baseURI_, address charon) ERC721("Abyss Shard", "SHARD") public {

        _setBaseURI(baseURI_);

        _charon = charon;
    }


  




    function awardItem(address player, address tokenEaten, uint256 amount, uint256 obolamount/*, string memory tokenUR*/) public returns (uint256) {
        
        require(msg.sender == _charon);


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