// code from https://docs.openzeppelin.com/contracts/5.x/governance
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IGovernor, Governor} from "@openzeppelin/contracts/governance/Governor.sol";
import {GovernorCountingSimple} from "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import {GovernorVotes} from "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import {GovernorVotesQuorumFraction} from "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import {GovernorTimelockControl} from "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";
import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";
import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract MyGovernor is Governor, GovernorCountingSimple, GovernorVotes, GovernorVotesQuorumFraction, GovernorTimelockControl, AccessControl {
    constructor(
        IVotes _token,
        TimelockController _timelock
    ) Governor("MyGovernor") GovernorVotes(_token) GovernorVotesQuorumFraction(4) GovernorTimelockControl(_timelock) {}

    function supportsInterface(bytes4 interfaceId) public view virtual override(Governor, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId) || Governor.supportsInterface(interfaceId) || AccessControl.supportsInterface(interfaceId);
    }

    bytes32 public constant MEMBER_ROLE = keccak256("MEMBER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant ISSUER_ROLE = keccak256("ISSUER_ROLE");
    bytes32 public constant REVIEWER_ROLE = keccak256("REVIEWER_ROLE");

    modifier onlyMember() {
        require(isMember(msg.sender), "Account is not a member.");
        _;
    }
    // manager can be owner, admin or committee
    modifier onlyManager() {
        require(isManager(msg.sender), "Only manager allowed.");
        _;
    }

    modifier onlyIssuer() {
        require(isIssuer(msg.sender), "Only issuer allowed.");
        _;
    }

    modifier onlyReviewer() {
        require(isReviewer(msg.sender), "Only reviewer allowed.");
        _;
    }

    function isMember(address _member) public view returns (bool) {
        return hasRole(MEMBER_ROLE, _member);
    }

    function isManager(address _member) public view returns (bool) {
        return hasRole(MANAGER_ROLE, _member);
    }

    function isIssuer(address _member) public onlyMember view returns (bool) {
        return hasRole(ISSUER_ROLE, _member);
    }

    function isReviewer(address _member) public onlyMember view returns (bool) {
        return hasRole(REVIEWER_ROLE, _member);
    }

    function addMember(address _member) public onlyManager returns (bool) {
        require(!isMember(_member), "The account is already a member.");
        grantRole(MEMBER_ROLE, _member);
        return true;
    }

    function addIssuer(address _member) public onlyManager returns (bool) {
        require(!isIssuer(_member), "The member is already an issuer.");
        grantRole(ISSUER_ROLE, _member);
        return true;
    }

    function addReviewer(address _member) public onlyManager returns (bool) {
        require(!isReviewer(_member), "The member is already a reviewer.");
        grantRole(REVIEWER_ROLE, _member);
        return true;
    }

    function votingDelay() public pure override returns (uint256) {
        return 7200; // 1 day
    }

    function votingPeriod() public pure override returns (uint256) {
        return 50400; // 1 week
    }

    function proposalThreshold() public pure override returns (uint256) {
        return 0;
    }

    // The functions below are overrides required by Solidity.
    function state(uint256 proposalId) public view override(Governor, GovernorTimelockControl) returns (ProposalState) {
        return super.state(proposalId);
    }

    function proposalNeedsQueuing(
        uint256 proposalId
    ) public view virtual override(Governor, GovernorTimelockControl) returns (bool) {
        return super.proposalNeedsQueuing(proposalId);
    }

    function _queueOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) returns (uint48) {
        return super._queueOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _executeOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) {
        super._executeOperations(proposalId, targets, values, calldatas, descriptionHash);
    }
    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) returns (uint256) {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor() internal view override(Governor, GovernorTimelockControl) returns (address) {
        return super._executor();
    }

}