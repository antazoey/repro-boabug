# @version 0.3.10

interface Claim:
    def mint(to: address) -> bool: nonpayable
    def setMinter(minter: address): nonpayable

CLAIM_BLUEPRINT: immutable(address)

owner: public(address)
merkle_root: public(bytes32)
claims: public(HashMap[String[128], address])

event ClaimCreated:
    claim_address: address

@external
def __init__(claim_blueprint: address, merkle_root: bytes32):
    self.owner = msg.sender
    CLAIM_BLUEPRINT = claim_blueprint
    self.merkle_root = merkle_root

@external
def setMerkleRoot(merkle_root: bytes32):
    assert msg.sender == self.owner
    self.merkle_root = merkle_root

@external
def createClaim(baseURI: String[56], name: String[128], symbol: String[128], description: String[1024]):
    assert self.claims[symbol] == empty(address)
    claim_address: address = create_from_blueprint(CLAIM_BLUEPRINT, baseURI, name, symbol, description, code_offset=3)
    log ClaimCreated(claim_address)
    self.claims[symbol] = claim_address

@external
def mint(proof: DynArray[bytes32, 160], leaf: bytes32, receiver: address=msg.sender):
    token_id: bytes32 = convert(msg.sender, bytes32)
    assert self._check(proof, token_id), "Invalid receiver"

@external
def claim(proof: DynArray[bytes32, 10000], amount: uint256, symbol: String[128], receiver: address=msg.sender):
    key: uint256 = convert(receiver, uint256)
    leaf_node: bytes32 = keccak256(convert(amount, bytes32))
    assert self._process_proof(proof, leaf_node, key) == self.merkle_root
    Claim(self.claims[symbol]).mint(receiver)

@internal
def _check(proof: DynArray[bytes32, 10000], leaf: bytes32) -> bool:
    computed_hash: bytes32 = leaf
    for i in proof:
        if (convert(computed_hash, uint256) < convert(i, uint256)):
            computed_hash = keccak256(concat(computed_hash, i))
        else:
            computed_hash = keccak256(concat(i, computed_hash))

    return computed_hash == self.merkle_root


@internal
@pure
def _process_proof(proof: DynArray[bytes32, 10000], leaf: bytes32, key: uint256) -> bytes32:
    node: bytes32 = leaf
    target_bit: uint256 = 1
    for sibling in proof:
        if key & target_bit != 0:
            node = keccak256(concat(sibling, node))    
        else:
            node = keccak256(concat(node, sibling))
        
        target_bit <<= 1
    
    return node
