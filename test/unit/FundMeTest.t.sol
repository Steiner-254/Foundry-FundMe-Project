// SPDX-License-Identifier: MIT
// SHOULD BE IN THE 'test/unit' FOLDER BUT BROUGHT ERRORS AND GOT FIXED IN 'test' folder
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    // The setUp function is called before each test. It deploys the FundMe contract
    function setUp() external {
        // us -> FundMeTest -> FundMe
        // This line was commented out as it hardcodes the address of the FundMe contract
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);

        // Instead, we deploy a new instance of the FundMe contract using the DeployFundMe script
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();

        // using the 'deal' cheatcode
        vm.deal(USER, STARTING_BALANCE);
    }

    // This function tests that the minimum dollar amount in the contract is 5 USD.
    // The function is now marked as `view` because it doesn't modify the blockchain state.
    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    // This function tests that the owner of the contract is the message sender.
    // It is also marked as `view` for the same reason.
    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    // This function tests that the price feed version returned by the contract is accurate.
    // The `view` keyword indicates this function doesn't modify state.
    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        
        // Output the version for debugging purposes
        console.log("Version returned by getVersion:", version);

        // The expected version is 4, this assert will fail if the version isn't 4
        assertEq(version, 4);
    }

    function testFundFailsWIthoutEnoughETH() public {
        // `forge test --match-test testFundFailsWIthoutEnoughETH` on the terminal to test the specific function
        vm.expectRevert(); // <- The next line after this one should revert! If not test fails.
        fundMe.fund(); // <- We send 0 value
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // The next TX will be sent by the user

        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    // function testFundUpdatesFundDataStrucutre() public {
    //     fundMe.fund{value: 10 ether}();
    //     uint256 amountFunded = fundMe.getAddressToAmountFunded(msg.sender);
    //     assertEq(amountFunded, 10 ether);
    // }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        // vm.stopPrank();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        // assert(address(fundMe).balance > 0);
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        // fundMe.fund{value: SEND_VALUE}();

        vm.expectRevert();
        // vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithDrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act 
        // uint256 gasStart = gasleft();
        // vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw(); // should have spent gas???

        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        // console.log(gasUsed);

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);

        // vm.expectRevert();
        // fundMe.withdraw();
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Arrange setup
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for(
            uint160 i = startingFunderIndex;
            i < numberOfFunders;
            i++) {
                // vm.prank new addres
                // vm.deal new address
                hoax(address(i), SEND_VALUE);
                fundMe.fund{value: SEND_VALUE}();
                // fund the fundMe
            }
        
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act setup
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert setup
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance );
    }
}


// pragma solidity ^0.8.18;

// import {Test, console} from "forge-std/Test.sol";
// import {FundMe} from "../src/FundMe.sol";
// import {DeployFundMe} from "../script/DeployFundMe.s.sol";

// contract FundMeTest is Test {
//     FundMe fundMe;

//     function setUp() external {
//         // us -> FundMeTest -> FundMe
//         // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
//         DeployFundMe deployFundMe = new DeployFundMe();
//         fundMe = deployFundMe.run();
//     }

//     function testMinimumDollarIsFive() public {
//         assertEq(fundMe.MINIMUM_USD(), 5e18);

//     }

//     function testOwnerIsMsgSender() public {
//         assertEq(fundMe.i_owner(), msg.sender);
//     }

//     function testPriceFeedVersionIsAccurate() public {
//     uint256 version = fundMe.getVersion();
//     assertEq(version, 4);
//     }
// }
