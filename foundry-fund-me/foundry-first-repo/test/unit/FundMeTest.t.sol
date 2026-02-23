// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    address alice = makeAddr("alice");
    FundMe fundMe;
    uint256 constant SEND_VALUE = 1 ether;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    /* The setUp function deploys the contract that is being tested */

    function testMinimumDepositIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18); //This checks as compares that MINIMUM_USD is 5 * 10**18
        console.log("Minimum deposit is %s", fundMe.MINIMUM_USD());
    }

    function testMsgSenderIsTheOwner() public view {
        //To help debug we can log the outputs of i_owner and msg.sender
        console.log("The msg.sender address is: %s", msg.sender);
        console.log("The test contract address is: %s", address(this)); //0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38
        console.log("The owners address is: %s", fundMe.i_owner()); //0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496

        assertEq(fundMe.i_owner(), msg.sender); //Address This measns the FUndMETest Address who is the i_owner

        //Since we used a deploy script the vm.startBroadcast() the owner changed to the person calling it = me

        /* The i_owner and msg.sedner are diffrent because
        we => call FundMeTest => FUndMETest calls => FundME so the owner is FundMeTest and not us(msg.sender) */
    }

    function testPriceFeedIsAccurate() public view {
        /* The test fails because AggregatorV3Interface calls a sepolia address and since,
    we have not specified an rpc url foundry defaults to the anvil one and it does not have the address we are passing */
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testMsgValueConvertedLessThanMinimumUsdReverts() public {
        vm.expectRevert();
        fundMe.fund(); //Should fail because we are sending zero eth but test should pass because we ecpect it to fail
    }

    function testGetterFunctions() public funded {
        uint256 amountFunded = fundMe.getAddressToAmout(alice);

        address firstFundersAddress = fundMe.getFunders(0);

        assertEq(SEND_VALUE, amountFunded);
        assertEq(alice, firstFundersAddress);

        console.log(amountFunded);
        console.log(firstFundersAddress);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert(); //This expects the next call to revert

        vm.prank(alice); //The first prank was for fund we put another one for withdraw
        fundMe.withdraw();
    }

    function testSinglePersonCanWithdraw() public funded {
        uint256 startinFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;

        assertEq(endingFundMeBalance, 0);

        assertEq(
            startinFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testMultiplePeopleCanWithdraw() public {
        uint160 numberOfFunders = 10;
        uint160 startingIndex = 1;

        for (
            uint160 i = startingIndex;
            i < numberOfFunders + startingIndex;
            i++
        ) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }

    modifier funded() {
        vm.prank(alice);
        vm.deal(alice, SEND_VALUE);

        fundMe.fund{value: SEND_VALUE}();
        assert(address(fundMe).balance > 0);
        _;
    }
}
