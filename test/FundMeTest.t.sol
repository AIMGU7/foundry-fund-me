//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test,console} from "lib/forge-std/src/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import{DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test{

    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 USDAMOUNT = 0.1 ether;
    uint256 STARTINGBALANCE = 10 ether;


    function setUp() external{
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTINGBALANCE); 

    }



    function testMinUsdIsFive() public{
        console.log(fundMe.MINIMUM_USD());
        assertEq(fundMe.MINIMUM_USD(),5e18);

    }

    function testOwner() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public{
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundNotEnoughEth() public{
        vm.expectRevert(); //Next line should revert
        fundMe.fund();
    }

    function testFundEnoughEth() public{
        vm.prank(USER);
        fundMe.fund{value: USDAMOUNT}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        
        assertEq(amountFunded,USDAMOUNT);
    }

    function AddsFunderToArrayOfFunders() public{
        vm.prank(USER);
        fundMe.fund{value: USDAMOUNT}();
        assertEq(fundMe.getFunder(0),USER);
    }

    function testWithdrawErrorNotOwner() public funded{
        vm.prank(USER);
        vm.expectRevert(); //Next line should revert
        fundMe.withdraw();
    }

    function testWithdrawByOwner() public funded{
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        console.log(startingOwnerBalance);

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance,endingOwnerBalance);

    }

    function testCheaperWithdrawByOwner() public funded{
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        console.log(startingOwnerBalance);

        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance,endingOwnerBalance);

    }

    function testFundFromMultipleAddresses() public{
        uint160 startingFunderIndex = 1;
        uint160 numberOfFunders = 10;
        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            hoax(address(i),USDAMOUNT);
            fundMe.fund{value: USDAMOUNT}();
        }

        assertEq(address(fundMe).balance, USDAMOUNT*9);
    }


    modifier funded(){
        vm.prank(USER);
        fundMe.fund{value: USDAMOUNT}();
        _;
    }
}