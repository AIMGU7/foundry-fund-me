//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "lib/forge-std/src/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "src/FundMe.sol";


contract FundFundMe is Script {

    uint256 SEND_VALUE = 0.01 ether;
    function fundFundMe(address mostRecenlyDeployed) public {
        vm.startBroadcast();
        FundMe(mostRecenlyDeployed).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
    }
    function run() external{
        address mostRecenlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        fundFundMe(mostRecenlyDeployed);

    }




}

contract WithdrawFundMe is Script {

    



}