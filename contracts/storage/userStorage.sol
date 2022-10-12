// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "../access/Ownable.sol";

contract UserRegister is Ownable {
    mapping(address => UserRegisterKYC) public user;
    struct UserRegisterKYC {
        bool registered;
        string Profession;
    }
    function userKyc(address _user) public onlyOwner {
        user[_user].registered = true;
    }
    function userExist(address _user) public view returns (bool) {
        return user[_user].registered;
    }
    function upgradeProfession(address addr, string memory _professions)
        external
        onlyOwner
    {
        require(
            user[addr].registered == true,
            " ERROR: NO USER FOUND."
        );
        user[addr].Profession = _professions;
    }
    function degradeProfession(string memory Profession) public {
        require(
            keccak256(abi.encodePacked(user[msg.sender].Profession)) ==
                keccak256(abi.encodePacked(Profession)), "ERROR : NO PROFESSION ASSIGNED" 
        );
        delete user[msg.sender].Profession;
    }
    function userProfession(address _user) external view returns (string memory) {
        return user[_user].Profession;
    }

  
}
