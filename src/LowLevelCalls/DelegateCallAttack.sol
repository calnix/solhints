contract Victim{

    uint256 public indicator;

    fallback() external payable {
        indicator = 1;
    }

    receive() external payable {
        indicator = 2;
    }
}

contract Attack {

    uint256 public indicator;


    function execute(address implementation, bytes calldata data) external {
        (bool success,) = implementation.delegatecall(data);
        require(success, "Execution failed");
    }

}


/*
data = []
receive was executed.

data = 0x123456
fallback was executed


msg.data empty
 -> receive exists? execute receive
 -> if no receive, execute fallback
 -> if neither exists, revert.

 msg.data has data: delegatecall(data)
 -> function selector match? yes, execute that function
 -> if no match, execute fallback 
 -> If no fallback, revert

 If msg.data must be empty, then receive is called.
 - used to receive ether.

 fallback is executed if msg.data is non-empty and no functions match the function selector.
*/