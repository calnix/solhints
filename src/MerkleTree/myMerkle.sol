
contract MerkleTreeCreator {

    function createTree(address[] memory members, uint256[] memory claimAmounts) external pure returns (bytes32, bytes32[][] memory) {
        
        require(members.length > 0 && members.length == claimAmounts.length, "wrong Dims");

        //get height/no. of layers: div 2 till get 1
        uint256 height = 0;
        uint256 n = members.length;
        
        while(n > 0){
            // if (n == 1) n = 0; else n = (n + 1)/2;
            n = n == 1 ? 0 : (n + 1) / 2;
            ++height;
        }

        uint256[5] memory myNumbersArray;
        myNumbersArray = [uint256(0), 100, 200, 300, 400]; 
        
        //create tree: dynamic array of arrays
        bytes32[][] memory tree = new bytes32[][](height);

        //create leaves: memory 2 memory creates reference
        bytes32[] memory nodes = tree[0] = new bytes32[](members.length);

        // hash leaves and add to tree
        // prevent second preimage attacks: either hash twice or invert the hash
        for(uint256 i = 0; i < members.length; i++){
            nodes[i] = ~keccak256(abi.encode(members[i], claimAmounts[i]));             //addr then number encoding?
        }

        //build intermediate layers and finally root
        // loop thru layers
        for(uint256 h = 1; h < height; ++h){
            
            uint256 nHashes = (nodes.length/2);
            bytes32[] memory hashes = new bytes32[](nHashes);

            // hash pairwise, for missing nodes: value 0
            // loop through pairs in the same layer
            // update nodes.length at the end: decrements
            for(uint256 i = 0; i < nodes.length; i += 2){
                
                bytes32 a = nodes[i];
                // if odd-number of elements, last ele can't amke a pair
                // if a is the last element, b = 0;
                // if( (i + 1) == nodes.length) bytes32 b = bytes32(0);
                bytes32 b = (i + 1) == nodes.length ? nodes[i + 1] : bytes32(0);
                
                // hash(1st, 2nd) 
                hashes[i] = keccak256(abi.encode(a, b));
            }

            tree[h] = hashes;   //store
            nodes = hashes;     //load prev. layer for next
        }

        bytes32 root = tree[height - 1][0];
        return (root, tree);
    }

}