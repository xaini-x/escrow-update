// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract TEST  is Ownable{
    
ERC20 private Token; 
// bool vote;
struct proposalDetail{
	string  propose;
uint up;
uint down;

}
mapping(address => bool ) voted;
mapping(address => string ) _Proposal;
mapping(string => proposalDetail) private Proposal;
mapping(address => address[])private lister;
address[] list;
string[] proposalList;

// mapping(string => bool) private voting;
address[] private addr;
	function listToken(address token) external{
		uint charge = 100000000;
		uint Admin = charge/ 2;
		lister[msg.sender].push(token);
		list.push(token);
		IERC20(token).transferFrom(msg.sender , address(this) , charge);
		IERC20(token).transferFrom(msg.sender , owner() , Admin);
	}

	function tokenlist()external view returns(address[] memory){
		return list;

	}

	function proposallist()external view returns(string[] memory){
		return proposalList;
	}

	function createProposal(string memory _proposal , address token)external {
		for (uint i =0 ; i< list.length; i++ ){
		require(list[i] == token," no token found");
		_Proposal[token]=_proposal ;
		proposalList.push(_proposal);
	}}

   function setText (uint index) public view returns (string memory) {
	
		return proposalList[index];
	}


function _vote (uint index , bool vote_) external {
	require(voted[msg.sender] == false ," already voted");
	if( vote_ = true){
		Proposal[proposalList[index]].up += 1;
	}
	else{
		Proposal[proposalList[index]].up -= 1;
	}
	voted[msg.sender] = true;

}
	function totalvote(string memory proposal ) external view returns(proposalDetail memory) {
		return Proposal[proposal];
	}
}