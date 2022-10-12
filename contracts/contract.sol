// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./ERC1155/ERC1155.sol";
import "./ERC20/IBLKCT.sol";
import "./storage/userStorageInterface.sol";


contract BLOCKCITIES is ERC1155, Ownable {
    IBlockCities public BC_TOKEN;
    //user storage contract address
    UserStorageInterface public userContract;
    uint256 id;
    string _uriPrefix;
    string _contractURI;
    mapping(uint256 => string) private URIData;
    struct detail {
        uint256 quantity;
        string uri;
        uint256 amount;
        bool buy;
        // bool investment;
        // bool preReserve;
        // bool Rent;
        address escrowAgent;
        uint256 escrowAmount;
    }
    mapping(uint256 => detail) assetDetail;
    mapping(uint256 => milestoneDetail) midDetail;

    struct milestoneDetail {
        uint256 mid;
        mapping(uint256 => mapping(uint256 => string)) RFPVisible;
        mapping(uint256 => uint256) RFPid;
    }
    mapping(uint256 => bidder) BidDetail;
    struct bidder {
        mapping(uint256 => mapping(uint256 => uint256)) bidAmount;
        mapping(uint256 => mapping(uint256 => address)) bidAddress;
    }

     constructor(
        string memory UriPrefix_,
        string memory ContractURI_,
        address tokenAddr,
        address UserContractAddr
    ) ERC1155(" ") {
        _uriPrefix = UriPrefix_;
        _contractURI = ContractURI_;
        BC_TOKEN = IBlockCities(tokenAddr);
        userContract = UserStorageInterface(UserContractAddr);

    }

    function contractURI() public view returns (string memory) {
        return string(abi.encodePacked(_uriPrefix, _contractURI));
    }

    /**
     *@dev
     */
    function uri(uint256 assetid)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return string(abi.encodePacked(_uriPrefix, assetDetail[assetid].uri));
    }

  

    function escrowPrice(
        address _user,
        uint256 _id,
        uint256 _amount
    
    ) external {
        require(
            keccak256(abi.encodePacked(userContract.userProfession(_user))) ==
                keccak256(abi.encodePacked("EscrowAgent")),
            "ERROR :NO AGENT FOUND"
        );
        assetDetail[_id].escrowAmount = _amount;
    }

    function assetCreation(
        address _user,
        address _escrowAgent,
        uint256 _amount,
        uint256 _quantity,
        string  memory _URI,
        bool _buy
    ) public onlyOwner {
        require(userContract.userExist(_user) == true, " ERROR:NO USER FOUND");
          require(
            keccak256(abi.encodePacked(userContract.userProfession(_escrowAgent))) ==
                keccak256(abi.encodePacked("EscrowAgent")),
            "ERROR : NOT AGENT FOUND"
        );
        uint256 ids = id;
        assetDetail[ids].uri = _URI;
        assetDetail[ids].amount = _amount;
        assetDetail[ids].escrowAgent = _escrowAgent;
        assetDetail[ids].buy = _buy;

        _mint(_user, ids, _quantity, "");
        id++;
        // available(_buy, _invest, _reserve, _rent);
    }

    function createMilestone(
        uint256 _id,
        bool universal,
        string memory _profession
    ) external onlyOwnerid(_id) {
        midDetail[_id].mid += 1;
        midDetail[_id].RFPid[midDetail[_id].mid] += 1;
        if (universal == true) {
            midDetail[_id].RFPVisible[midDetail[_id].mid][
                midDetail[_id].RFPid[midDetail[_id].mid]
            ] = _profession;
        } 
    }

    function specificProfession(
        uint _id,
        uint _mid,
        uint256 _RFP
    ) external view returns (string memory) {
        return
            midDetail[_id].RFPVisible[_mid][_RFP];
    }

    function createRFP(uint256 _id, uint256 _mid, bool universal,
        string memory _profession) external onlyOwnerid(_id){
        require( midDetail[_id].mid > _id, " ERROR: NO MILEStONE FOUND");
        // RFPid[_id][_mid] += 1;
        midDetail[_id].RFPid[_mid] += 1;
        if (universal == true) {
            midDetail[_id].RFPVisible[midDetail[_id].mid][
         _mid
            ] = _profession;
        } 
    }

    function bidderSelect(
        uint256 rfp,
        uint256 M_Id,
        uint256 assetID,
        uint256 amount,
        address _bidder
    ) public onlyOwnerid(assetID) {
        BidDetail[assetID].bidAmount[M_Id][rfp] = amount;
        BidDetail[assetID].bidAddress[M_Id][rfp] = _bidder;
        BC_TOKEN.transfertoken(
            msg.sender,
            address(this),
            BidDetail[assetID].bidAmount[M_Id][rfp]
        );
    }
        modifier onlyOwnerid(uint _id ) {
            require(
               balanceOf(msg.sender, _id) >=1
                   ,
                " Error: NOT THE OWNER"
            );
            _;
        }


    // function available(
    //     bool _buy,
    //     bool _invest,
    //     bool _reserve,
    //     bool _rent
    // ) internal {
    //     assetDetail[id].buy = _buy;
    //     assetDetail[id].investment = _invest;
    //     assetDetail[id].preReserve = _reserve;
    //     assetDetail[id].rent = _rent;
    // }
}
