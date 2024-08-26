// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

// Import the script that deploys the contracts and the contract to be deployed
import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // Initialize the HelperConfig to get the active network configuration
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

        // Start broadcasting the transaction
        vm.startBroadcast();
        
        // Deploy the FundMe contract using the dynamic price feed address
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        
        // Stop broadcasting the transaction
        vm.stopBroadcast();

        return fundMe;
    }
}


// pragma solidity 0.8.18;

// // import the script -> that deploys the contracts & also import the contract to be deployed!
// import {Script} from "forge-std/Script.sol";
// import {FundMe} from "../src/FundMe.sol";
// import {HelperConfig} from "./HelperConfig.s.sol";

// contract DeployFundMe is Script {
//         function run() external returns (FundMe) {

//             // Before startBroadcast "that's not a real tx transaction"
//         HelperConfig helperConfig = new HelperConfig();
//         address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

//            // After startBroadcast "that's a real tx transaction"
//         vm.startBroadcast();
//         FundMe fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
//         vm.stopBroadcast();
//         return fundMe;
//     }  
// }
