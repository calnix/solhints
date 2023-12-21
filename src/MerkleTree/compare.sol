contract compare {

    /**
     1. get the height of tree: members /2 till 1
     2. create nested tree with height
     3. fill up each of the nested arrays. tree[0]: hashed leaves 
     */
    function failedTree(address[] memory members, uint256[] memory votes) external pure returns (bytes32, bytes32[][] memory) {
        require(members.length != 0 && members.length == votes.length, "wrong Dims");

        //get height/no. of layers: div 2 till get 1
        uint256 height = 0;
        {
            uint256 n = members.length;
            while(n > 0){
                // if (n == 1) n = 0; else n = (n + 1)/2;
                // (n + 1) to deal w/ odd numbers: 6 --> 3: (treated as 4) --> 2 --> 1
                n = n == 1 ? 0 : (n + 1) / 2;
                ++height;
            }
        }      
        //create tree: to-level fixed, nested dynamic
        bytes32[][] memory tree = new bytes32[][](height);

        //create leaves: memory 2 memory creates reference
        bytes32[] memory nodes = tree[0] = new bytes32[](members.length);

        // hash leaves and add to tree
        // prevent second preimage attacks: either hash twice or invert the hash
        for(uint256 i = 0; i < members.length; i++){
            nodes[i] = ~keccak256(abi.encode(members[i], votes[i]));         
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

    function workingTree(address[] memory members, uint256[] memory claimAmounts) public pure returns (bytes32 root, bytes32[][] memory tree) {
        require(members.length != 0 && members.length == claimAmounts.length);
        
        // Determine tree height: keep dividing no. of leaves by 2 till you get 1
        uint256 height = 0;
        {
            uint256 n = members.length; // no. of leaves
            while (n != 0) {
                n = n == 1 ? 0 : (n + 1) / 2;   // n+1: cos index starts from 0. 
                ++height;
            }
        }
        tree = new bytes32[][](height);     // 2-D array: bytes32[][height]tree. top-level is height.

        // The first layer of the tree contains the leaf nodes, which are hashes of each member and claim amount.
        bytes32[] memory nodes = tree[0] = new bytes32[](members.length);

        for (uint256 i = 0; i < members.length; ++i) {
            // Leaf hashes are inverted to prevent second preimage attacks.
            nodes[i] = ~keccak256(abi.encode(members[i], claimAmounts[i]));
        }

        // Build up subsequent layers until we arrive at the root hash.
        // Each parent node is the hash of the two children below it.
        // E.g.,
        //              H0         <-- root (layer 2)
        //           /     \
        //        H1        H2
        //      /   \      /  \
        //    L1     L2  L3    L4  <--- leaves (layer 0)
        for (uint256 h = 1; h < height; ++h) {
            
            // calc no.f of hashes for that layer
            uint256 nHashes = (nodes.length + 1) / 2;       // (3+1)/2 = 2 | (4+1)/2 = 2 @audit could be failed cos of this, check again.
            bytes32[] memory hashes = new bytes32[](nHashes);   //bytes32[nHashes] memory hashes -> cre8 array based on number of hashes for that layer
            
            // nodes.length = total no. of members
            for (uint256 i = 0; i < nodes.length; i += 2) {
                
                bytes32 a = nodes[i];

                // Tree is sparse. Missing nodes will have a value of 0.
                bytes32 b = i + 1 < nodes.length ? nodes[i + 1] : bytes32(0);
                // Siblings are always hashed in sorted order.
                hashes[i / 2] = keccak256(a > b ? abi.encode(b, a) : abi.encode(a, b));     //0/2 = 0
            }

            tree[h] = nodes = hashes;
        }
        
        // Note the tree root is at the bottom.
        root = tree[height - 1][0];
    }

}