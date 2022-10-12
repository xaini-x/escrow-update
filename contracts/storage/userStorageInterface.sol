// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface UserStorageInterface {
    function createProfession(string [] memory _professions) external;

    function showProfession() external view returns (string[] memory);

    function applyUser(string memory UserType, string memory uri) external;

    function approveUser(address addr , bool exist) external;

   function userType(address addr) external view returns ( string memory);

    function deleteUser(address addr) external;

    function isRegistered(address addr) external view returns(bool );
     function userProfession(address _user) external view returns (string memory) ;
     function userExist(address _user) external view returns (bool) ;
}
