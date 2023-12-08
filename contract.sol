//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract NFT is ERC721Enumerable, Ownable {
    using Strings for uint256;
    string public baseURI;
    string private unRevealedURL="ipfs://QmVqcn6iVpAUr4mc7yC7ddm1MkV9kSEFhAT35hp7c5GbU9/";

    string public baseExtension = ".json";
    uint256 public cost = 0.0015 ether;
    uint256 public presaleCost = 0.005 ether;
    uint256 public presaleSupply = 1111;
    bool public revealed = false;

    uint256 public maxSupply = 5555;
    uint256 public maxMintAmount = 10;

    bool public paused = true;
    uint public presale_time;


    constructor(
        string memory _initBaseURI
    ) ERC721("CryptoFashion", "CF") {
        setBaseURI(_initBaseURI);
        start_launch() ;
   }

    // internal 
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    // public 
   function mint(address _to, uint256 _mintAmount) public payable 
   {
        uint256 supply = totalSupply();
        require(!paused);
        require(_mintAmount > 0);
        require(_mintAmount <= maxMintAmount);
        require(supply + _mintAmount <= maxSupply);
        uint curr_cost;
        if (msg.sender != owner()) 
        {
            if(block.timestamp< presale_time)
            { 
                require(supply<presaleSupply,"presale supply is is over");
                 curr_cost = presaleCost;            
            }
            else
            {
                curr_cost = cost;
            }

            require(msg.value >= curr_cost * _mintAmount);

            payable(owner()).transfer(msg.value);
            
        }

        for (uint256 i = 1; i <= _mintAmount; i++) {
            _safeMint(_to, supply + i);
        }

    }

    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        if(revealed == true)
        {
            require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
            );

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
        }
        else{
            return unRevealedURL;
        }

    }

    //only owner
    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }
    function reveal_collection() public onlyOwner {
        revealed = true;
    }
    function setPresaleCost(uint256 _newCost) public onlyOwner {
        presaleCost = _newCost;
    }

    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxMintAmount = _newmaxMintAmount;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }
        function Set_presale_supply(uint _value) public onlyOwner {
        presaleSupply = _value;
    }


    function Increase_Presale_Time(uint _days) public onlyOwner {
        if (block.timestamp<=presale_time)
        {
            presale_time=presale_time + (_days* 1 days);
        }
        else{
            presale_time=block.timestamp + (_days* 1 days);
        }

    }

    function End_preSale() external onlyOwner
    {
        require(block.timestamp>presale_time,"presale is already ended");
        presale_time=block.timestamp ;
    }

    function AirDrop(address[] calldata _to,uint256[] calldata _id) external onlyOwner{
        require(_to.length == _id.length,"receivers and ids have different lengths");
        for(uint i=0;i<_to.length;i++)
        {
            safeTransferFrom(msg.sender,_to[i],_id[i]);
        }
    }
 

    function start_launch() public onlyOwner 
    {
        paused = false;
        presale_time=block.timestamp +  3 days;

    }

    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success);
    }
    function curr_time() view public  returns(uint)
    {
        return block.timestamp;
    }

}