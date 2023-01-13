// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./UNVoting_HierarchyList.sol";

/*
 * @title Ballot
 * @dev Implements voting process along with winning candidate
 */
contract Ballot {
    HierarchyList.Candidate[] public candidates; //list of candidates

    mapping(uint256 =>  HierarchyList.Voter) voter;
    mapping(uint256 =>  HierarchyList.Candidate) candidate;
    mapping(uint256 => uint256) internal votesCount;

    address  electionChief;
    //voting time-period
    uint256 private votingStartTime;
    uint256 private votingEndTime;


    /**
     * @dev Create a new ballot to choose one of 'candidateNames'
     * @param startTime_ When the voting process will start
     * @param endTime_ When the voting process will end
     */
    constructor(uint256 startTime_, uint256 endTime_) {
        votingStartTime = startTime_;
        votingEndTime = endTime_;
        electionChief = msg.sender;
    }

    /**
     * @dev Get candidate list.
     * @param voterIdentityNumber: Identity number of the current voter to send the relevent candidates list
     * @return candidatesList_ All the politicians who participate in the election
     */
    function getCandidateList(uint256 voterIdentityNumber)
        public
        view
        returns ( HierarchyList.Candidate[] memory)
    {
         HierarchyList.Voter storage voter_ = voter[voterIdentityNumber];
        uint256 _politicianOfMyConstituencyLength = 0;

        for (uint256 i = 0; i < candidates.length; i++) {
            if (
                voter_.stateCode == candidates[i].stateCode &&
                voter_.constituencyCode == candidates[i].constituencyCode
            ) _politicianOfMyConstituencyLength++;
        }
         HierarchyList.Candidate[] memory cc = new  HierarchyList.Candidate[](
            _politicianOfMyConstituencyLength
        );

        uint256 _indx = 0;
        for (uint256 i = 0; i < candidates.length; i++) {
            if (
                voter_.stateCode == candidates[i].stateCode &&
                voter_.constituencyCode == candidates[i].constituencyCode
            ) {
                cc[_indx] = candidates[i];
                _indx++;
            }
        }
        return cc;
    }

    /**
     * @dev Get voter list.
     * @param voterIdentityNumber Identity number of the current voter to send the relevent candidates list
     * @return voterEligible_ Whether the voter with provided identity is eligible or not
     */
    function isVoterEligible(uint256 voterIdentityNumber)
        public
        view
        returns (bool voterEligible_)
    {
         HierarchyList.Voter storage voter_ = voter[voterIdentityNumber];
        if (voter_.age >= 18 && voter_.isAlive) voterEligible_ = true;
    }
      function getVoterList()
        public
        view
        returns ( HierarchyList.Voter[] memory){
        }
    

    /**
     * @dev Get Users Vote: Know whether the voter casted their vote or not. If casted get candidate object.
     * @param voterIdentityNumber Identity number of the current voter
     * @return userVoted_ Boolean value which gives whether current voter casted vote or not
     * @return candidate_ Candidate details to whom voter casted his/her vote
     */
    function didCurrentVoterVoted(uint256 voterIdentityNumber)
        public
        view
        returns (bool userVoted_,  HierarchyList.Candidate memory candidate_)
    {
        userVoted_ = (voter[voterIdentityNumber].votedTo != 0);
        if (userVoted_)
            candidate_ = candidate[voter[voterIdentityNumber].votedTo];
    }

    /**
     * @dev Cast your vote to candidate.
     * @param nominationNumber Identity Number of the candidate
     * @param voterIdentityNumber Identity Number of the voter to avoid re-entry
     * @param currentTime_ To check if the election has started or not
     */
    function vote(
        uint256 nominationNumber,
        uint256 voterIdentityNumber,
        uint256 currentTime_
    )
        public
        votingLinesAreOpen(currentTime_)
        isEligibleVote(voterIdentityNumber, nominationNumber)
    {
        // updating the current voter values
        voter[voterIdentityNumber].votedTo = nominationNumber;

        // updates the votes to the politician
        uint256 voteCount_ = votesCount[nominationNumber];
        votesCount[nominationNumber] = voteCount_ + 1;
    }

    /**
     * @dev Gives ending epoch time of voting
     * @return endTime_ When the voting ends
     */
    function getVotingEndTime() public view returns (uint256 endTime_) {
        endTime_ = votingEndTime;
    }

    /**
     * @dev used to update the voting start & end times
     * @param startTime_ Start time that needs to be updated
     * @param currentTime_ Current time that needs to be updated
     */
    function updateVotingStartTime(uint256 startTime_, uint256 currentTime_)
        public
        isElectionChief
    {
        require(votingStartTime > currentTime_);
        votingStartTime = startTime_;
    }

    /**
     * @dev To extend the end of the voting
     * @param endTime_ End time that needs to be updated
     * @param currentTime_ Current time that needs to be updated
     */
    function extendVotingTime(uint256 endTime_, uint256 currentTime_)
        public
        isElectionChief
    {
        require(votingStartTime < currentTime_);
        require(votingEndTime > currentTime_);
        votingEndTime = endTime_;
    }

    /**
     * @dev sends all candidate list with their votes count
     * @param currentTime_ Current epoch time of length 10.
     * @return candidateList_ List of Candidate objects with votes count
     */
    function getResults(uint256 currentTime_)
        public
        view
        returns ( HierarchyList.Results[] memory)
    {
        require(votingEndTime < currentTime_);
         HierarchyList.Results[] memory resultsList_ = new  HierarchyList.Results[](
            candidates.length
        );
        for (uint256 i = 0; i < candidates.length; i++) {
            resultsList_[i] =  HierarchyList.Results({
                name: candidates[i].name,
                symbolOfElection: candidates[i].symbolOfElection,
                nominationNumber: candidates[i].nominationNumber,
                stateCode: candidates[i].stateCode,
                constituencyCode: candidates[i].constituencyCode,
                voteCount: votesCount[candidates[i].nominationNumber]
            });
        }
        return resultsList_;
    }

    /**
     * @notice To check if the voter's age is greater than or equal to 18
     * @param currentTime_ Current epoch time of the voter
     */
    modifier votingLinesAreOpen(uint256 currentTime_) {
        require(currentTime_ >= votingStartTime);
        require(currentTime_ <= votingEndTime);
        _;
    }

    /**
     * @notice To check if the voter's age is greater than or equal to 18
     * @param voterIdentity_ Identity number of the current voter
     * @param nominationNumber_ Nomination number of the candidate
     */
    modifier isEligibleVote(uint256 voterIdentity_, uint256 nominationNumber_) {
         HierarchyList.Voter memory voter_ = voter[voterIdentity_];
         HierarchyList.Candidate memory politician_ = candidate[nominationNumber_];
        require(voter_.age >= 18);
        require(voter_.isAlive);
        require(voter_.votedTo == 0);
        require(
            (politician_.stateCode == voter_.stateCode &&
                politician_.constituencyCode == voter_.constituencyCode)
        );
        _;
    }

    /**
     * @notice To check if the user is Election Chief or not
     */
    modifier isElectionChief() {
        require(msg.sender == electionChief);
        _;
    }
}
