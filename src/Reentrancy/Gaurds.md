# Reentrancy Guards (Mutex)

Sometimes you can't organize your code according to CEI. Maybe you depend on the output of an external interaction to compute the final state to be committed. In these cases, you can use some form of a reentrancy guard.

Reentrancy guards are essentially temporary state that indicates an operation is ongoing, which you can check to prevent two mutually exclusive operations (or the same operation) from occurring before the first one has completed. Many contracts use a dedicated storage variable as this mutex (see the [standard OpenZeppelin implementation](https://docs.openzeppelin.com/contracts/4.x/api/security#ReentrancyGuard)) and share it across any at-risk functions. Often reentrancy guards are wrapped in a modifier that asserts the state flag, toggles on the flag, executes the function body, then resets the flag.

Here is Alice with a reentrancy guard:


```solidity
contract Alice {
    ...
    bool private _reentrancyGuard;

    modifier nonReentrant() {
        require(!_reentrancyGuard);
        _reentrancyGuard = true;
        _;
        _reentrancyGuard = false;
    }

    // Unaltered, vulnerable code from original example but with reentrancy guard
    // modifier added.
    function claimApple() external nonReentrant {
        require(!_hasReceivedApple[msg.sender]);
        APPLES.safeMint(msg.sender);
        _hasReceivedApple[msg.sender] = true;

    }
}
```

Now if Bob attempts to call `claimApple()` again before it has completed the modifier will see that the reentrancy guard is activated and the call will revert.

The reentrancy guard approach is pretty convenient and takes much less thought to apply, which makes it a very popular solution. However, it comes with some considerations.

- The reentrancy flag usually occupies its own storage slot. Writing to a new storage slot (especially an empty one) introduces significant gas cost. Even though the majority of it will be refunded (because the slot is reset by the modifier), it raises the execution gas limit of the transaction which causes some extra sticker shock to users.
    - Sometimes you can avoid using a dedicated reentrancy guard state variable. Instead you can reuse a state variable that you would write to during the operation anyway, checking and setting it to some preordained invalid value that would act the same way a dedicated reentrancy guard would.
- The naive version of a reentrancy guard can only protect reentrancy within a single contract. Protocols are often composed of several contracts with mutually exclusive operations across them. In these situations, you may need to come up with a way to surface the reentrancy guard state across the rest of the system.
