pragma ton-solidity >= 0.44.0;

pragma AbiHeader expire;
pragma AbiHeader pubkey;

contract MemeFactoryWithdrawal {
    // Minimum TON amount to keep in storage
    uint128 constant MinTonForStorage = 0.01 ton;

    // Address of the deployer (set at deployment)
    address public deployer;

    // Modifier to restrict access to the deployer
    modifier onlyDeployer() {
        require(msg.sender == deployer, 101, "Only deployer is allowed to call this method");
        _;
    }

    // Constructor to initialize deployer
    constructor() {
        tvm.accept(); // Accept message for deployment
        deployer = msg.sender; // Set the deployer
    }

    // Fallback function to handle received funds
    receive() external {
        tvm.log("Funds received");
    }

    // Function to process withdrawal requests
    function withdraw(uint128 amount, address recipient) external onlyDeployer {
        tvm.accept(); // Accept incoming message

        // Calculate the transferable amount
        uint128 transferableAmount = math.min(
            amount,
            address(this).balance - msg.value - MinTonForStorage
        );

        // Ensure there is enough balance to transfer
        require(transferableAmount > 0, 102, "Insufficient balance");

        // Transfer funds
        recipient.transfer({
            value: uint64(transferableAmount), // Explicit conversion to varuint16-compatible type
            bounce: true,
            flag: 1 // Send all remaining value
        });
    }

    // Get the contract's current balance
    function getBalance() external view returns (uint128) {
        return address(this).balance; // Return balance in nanotons
    }
}
