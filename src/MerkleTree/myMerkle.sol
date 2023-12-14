
contract MerkleTreeCreator {

    // The root of the merkle tree, generated by constructTree().
    bytes32 public immutable ROOT;

    // Whether a member has claimed their drop.
    // Note this assumes each members is only eligible for a single drop, i.e.,
    // they occur in the merkle tree only once.
    mapping (address => bool) public hasClaimed;

    constructor(bytes32 root) payable {
        ROOT = root;
    }

    /**
     1. get the height of tree: members /2 till 1
     2. create nested tree with height
     3. fill up each of the nested arrays. tree[0]: hashed leaves 
     */
    function constructTree(address[] memory members, uint256[] memory claimAmounts) external pure returns (bytes32, bytes32[][] memory) {
        
        require(members.length > 0 && members.length == claimAmounts.length, "wrong Dims");

        //get height/no. of layers: div 2 till get 1
        uint256 height = 0;
        uint256 n = members.length;
        
        while(n > 0){
            // if (n == 1) n = 0; else n = (n + 1)/2;
            // (n + 1) to deal w/ odd numbers: 6 --> 3: (treated as 4) --> 2 --> 1
            n = n == 1 ? 0 : (n + 1) / 2;
            ++height;
        }
       
        //create tree: to-level fixed, nested dynamic
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



    function verify(bytes32 leaf, bytes32[] memory siblings) public view returns (bool) {
        // In a sparse tree, empty leaves have a value of 0, so don't allow 0 as input.
        require(leaf != 0, 'invalid leaf value');  

        bytes32 node = leaf;

        // Siblings are always hashed in sorted order.   
        for (uint256 i = 0; i < siblings.length; ++i){
            node = keccak256(node > siblings[i] ? abi.encode(siblings[i], node) : abi.encode(node, siblings[i]));
        }   
        
        return node == ROOT; 
    }

    // Given a merkle tree and a member index (leaf node index), generate a proof.
    // The proof is simply the list of sibling nodes/hashes leading up to the root.
    function createProof(uint256 memberIndex, bytes32[][] memory tree) external pure returns(bytes32[] memory) {
        
        uint256 height = tree.length;
        uint256 nodeIndex = memberIndex;

        // list of intermediate hashes, less the initial leaf
        bytes32[] memory proof = new bytes32[](height - 1);

        //cycle thru the layers
        for(uint256 h = 0; h < proof.length; ++h){
            // is the index even? if even, look forward, else look backward 
            uint256 sibilingIndex = nodeIndex % 2 == 0 ? nodeIndex + 1 : nodeIndex - 1;

            if(sibilingIndex < tree[h].length){        // will terminate the root
                proof[h] = tree[h][sibilingIndex];
            } 

            nodeIndex /= 2;     // div by 2, rounded down. index for the next layer.
        }

        return proof;
    }

}