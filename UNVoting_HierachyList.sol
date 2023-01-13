// SPDX-License-Identifier: Unlicensed

pragma experimental ABIEncoderV2;
pragma solidity ^0.8.0;

/**
 * @title Types
 * @dev All custom types that we have used in E-Voting will be declared here
 */

library HierarchyList {
    struct Voter {
        uint256 identityNumber; // voter unique ID
        string name;
        uint8 age;
        string gender;
        string useraddress;
        uint8 stateCode;
        uint8 constituencyCode;
        bool isAlive;
        uint256 votedTo; // identity number of the candidate
        bool UNmember;   //to get list of all UN Members (UN members can also [participate in voting)
    }
   

    struct Candidate {
        string name;
        string symbolOfElection;
        uint256 nominationNumber; // unique ID of candidate
        uint8 stateCode;
        uint8 constituencyCode;
    }

    struct Results {
        string name;
        string symbolOfElection;
        uint256 voteCount; // number of accumulated votes
        uint256 nominationNumber; // unique ID of candidate
        uint8 stateCode;
        uint8 constituencyCode;
    }
}


