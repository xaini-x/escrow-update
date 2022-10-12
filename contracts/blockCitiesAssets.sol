//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.7;
import "hardhat/console.sol";

import "./IContractManager.sol";


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

abstract contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    
    // mo meed to specfy internal in constructor as contract is abstract 
    constructor () { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     *
     * not an internal constructor
     */
    constructor() {
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract BaseContract is Ownable {
    address internal managerAddress;

    function setManagerAddress(address _managerAddress) public onlyOwner {
        managerAddress = _managerAddress;
    }

    function getManagerAddress() public view returns(address){
        return managerAddress;
    }
}

interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}



interface IBlockCities is IERC20 {
    function transferPrice(
        address from,
        address recipient,
        uint256 amount
    ) external returns (bool);

  function transfertoken(
        address from,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function decimals() external returns (uint8);
}

/** @title Blockcities token(ERC 20, Burnable and Ownable) contract. */
contract BlockCitiesAssets is Ownable, BaseContract {
    uint256 private _rate;
    uint256 private _investLimit = 50000;
    uint256 private _buyLimit = 50000;
    uint256 private tokensPerEther = 100;
    string private _BlockCities;

    mapping(address => uint256) private securityTokens;
    
    event InvestEvent(
        address indexed _investor,
        string _assetDetails,
        uint256 _amount,
        string _duration,
        string _roi,
        uint256 _timestamp
    );
    event ReserveEvent(
        address indexed _depositor,
        string _assetDetails,
        uint256 _amount,
        uint256 _timestamp
    );
    event BuyEvent(
        uint256 initailAssetTokenAmount,
        uint256 totalChargesInTokens,
        address assetOwnerAddress
       
    );
    event BuyBlockcities(
        address indexed from,
        address indexed receipent,
        uint256 amount
    );
    
    function getTokenPerEther() public view returns (uint256) {
        return tokensPerEther;
    }

    function setTokenPerEther(uint256 _totalTokensPerEther) public onlyOwner {
        tokensPerEther = _totalTokensPerEther;
    }

    function getSecurityTokens() public view returns(uint256) {
        return securityTokens[msg.sender];
    }


    /** @dev func setRate() : Only Onwer (intially the one who deployed the contract)
     * @param rate :  ROI (rate of return on investments) upon the investment..
     */

    function setRate(uint256 rate) public onlyOwner {
        _rate = rate;
    }

    /** @dev func getRate().
     * @return ROI (rate of return on investments) upon the investment.
     */

    function getRate() public view returns (uint256) {
        return (_rate);
    }

    /** @dev func setRate() : Only Onwer (intially the one who deployed the contract)
     * @param investlimit :  ROI (rate of return on investments) upon the investment..
     */

    function setInvestLimit(uint256 investlimit) public onlyOwner {
        _investLimit = investlimit;
    }

    /** @dev func getRate().
     * @return ROI (rate of return on investments) upon the investment.
     */

    function getInvestLimit() public view returns (uint256) {
        return (_investLimit);
    }

    /** @dev func setRate() : Only Onwer (intially the one who deployed the contract)
     * @param buylimit :  ROI (rate of return on investments) upon the investment..
     */

    function setBuyLimit(uint256 buylimit) public onlyOwner {
        _buyLimit = buylimit;
    }

    /** @dev func getRate().

      * @return ROI (rate of return on investments) upon the investment.
      */

    function getBuyLimit() public view returns (uint256) {
        return (_buyLimit);
    }

    /** @dev func getSecurityToken().
     * @param investorAddress : ethereum address of the user's whose security tokens are required.
     * @return securityTokens : Total Amount of security token on provided address.
     */

    function getSecurityToken(address investorAddress)
        public
        view
        returns (uint256)
    {
        return (securityTokens[investorAddress]);
    }

    // just for testing
    function getDecimal() public returns(uint8) {
        IContractManager manager = IContractManager(
            managerAddress
        );
        console.log("_blockCities :", _BlockCities);
        address blockcitiesAddress = manager.getAddress(_BlockCities);
        console.log("blockCitiesAddress :", blockcitiesAddress);
        
        IBlockCities BLKCT = IBlockCities(blockcitiesAddress);
        uint8 decimals = BLKCT.decimals();
        return decimals;
    }

    /** @dev func buyBlockcities().
     * @param _amount : Total number of blockcities tokens (decimals) to be transfer to sender's address.
     */

    function buyBlockcities(address recipient, uint256 _amount) public onlyOwner {
        IContractManager manager = IContractManager(
            managerAddress
        );
        address blockcitiesAddress = manager.getAddress(_BlockCities);
        IBlockCities BLKCT = IBlockCities(blockcitiesAddress);
        BLKCT.transferPrice(owner(), recipient, _amount);
        emit BuyBlockcities(owner(), recipient, _amount);
    }

    /** @dev func invest()
     * @param _amount      : Total number of blockcities tokens (decimals) required to invest in asset.
     * @param _assetowner  : Assest Owner's ethereum address.
     * @param _duration    : Duration (time period) to which investment is done.
     * @param _roi         : Rate of return on investment.
     * @param _assetDetails : Additional Details(type, characterstics etc.) of the assest.
     */

    function invest(
        uint256 _amount,
        address _assetowner,
        string memory _duration,
        string memory _roi,
        string memory _assetDetails
    ) public {
        IContractManager manager = IContractManager(
            managerAddress
        );
        address getsAddress = manager.getAddress(_BlockCities);
        IBlockCities BLKCT = IBlockCities(getsAddress);
        require(_amount >= _investLimit, "Not enough balance");
        require(BLKCT.balanceOf(_msgSender()) >= _amount, "Not enough balance");
        BLKCT.transferPrice(_msgSender(), _assetowner, _amount);
        securityTokens[_msgSender()] = securityTokens[_msgSender()] + _amount;
        emit InvestEvent(
            _msgSender(),
            _assetDetails,
            _amount,
            _duration,
            _roi,
            block.timestamp
        );
    }

    /** @dev func reserve()
     * @param _amount      : Total number of blockcities tokens (decimals) required to reserve in asset.
     * @param _receiver    : Assest Owner's ethereum address.
     * @param _assetDetails : Additional Details(type, characterstics etc.) of the assest.
     */

    function reserve(
        uint256 _amount,
        address _receiver,
        string memory _assetDetails
    ) public {
        IContractManager manager = IContractManager(
            managerAddress
        );
        address getsAddress = manager.getAddress(_BlockCities);
        IBlockCities BLKCT = IBlockCities(getsAddress);
        require(BLKCT.balanceOf(_msgSender()) >= _amount, "Not enough balance");
        BLKCT.transferPrice(_msgSender(), _receiver, _amount);
        emit ReserveEvent(
            _msgSender(),
            _assetDetails,
            _amount,
            block.timestamp
        );
    }

    /** @dev func claimReturns()
     * @param _amount        : Total number of blockcities tokens (decimals) included interest earned on investment.
     * @param _assetowner    : Assest Owner's ethereum address.
     * @param _investor      : Investor's (one who invested in assest) ethreum address.
     * @param _initialAmount : Total number of blockcities tokens (decimals) submitted at the investment (Intial Amount(excluding interest)).
     */

    function claimReturns(
        uint256 _amount,
        address _assetowner,
        address _investor,
        uint256 _initialAmount
    ) public {
        IContractManager manager = IContractManager(
            managerAddress
        );
        address getsAddress = manager.getAddress(_BlockCities);
        IBlockCities BLKCT = IBlockCities(getsAddress);
        require(BLKCT.balanceOf(_assetowner) >= _amount, "Not enough balance");
        BLKCT.transferPrice(_assetowner, _investor, _amount);
        securityTokens[_investor] = securityTokens[_investor] - _initialAmount;
    }

    //** @dev func buyAsset()
    // * @param initailAssetTokenAmount : Total number of blockcities tokens (decimals) required to invest in asset.
    // * @param assetOwnerAddress : Assest Owner's ethereum address.
    // * @param feeTokenAmount : Fees charged by buyer is transffered to admin account.
    // * @param taxTokenAmount : Tax charged by buyer is transferred  to admin account.
    // * @param assetTitle : Title of the assest.
    // * @param unitNumber : alphaNumeric value of the asset
    // */
    
      function buyAsset(
        uint256 initialAssetTokenAmount,
        uint256 totalChargesInTokens,
        address assetOwnerAddress
      
    ) external{
        IContractManager manager = IContractManager(
            managerAddress
        );
        address getsAddress = manager.getAddress(_BlockCities);
        IBlockCities BLKCT = IBlockCities(getsAddress);
         require(
            BLKCT.balanceOf(msg.sender) >= 0,
             "ERROR : Not enough token to buy asset"
        );
        BLKCT.transferPrice(msg.sender, assetOwnerAddress, initialAssetTokenAmount);
        BLKCT.transferPrice(msg.sender, owner(), totalChargesInTokens);
        emit BuyEvent(initialAssetTokenAmount,totalChargesInTokens, assetOwnerAddress);
    }

    
    function setBlockCities(string memory _blockCitiesAddress) public onlyOwner {
        _BlockCities = _blockCitiesAddress;
    }

    
    function getBlockCities() public view returns(string memory) {
        return _BlockCities;
    }
}


