import boa
from pathlib import Path

def test_repro():
    hack_details = (
        "XBridgeHack Claim 2024-06-26",  # Name
        "XBridgeHack_20240626",  # Symbol
        "The X-Bridge hack resulting in the loss off ...",  # Description
    )
    nft = boa.load(
        Path(__file__).parent.parent / "Claim.vy",
        f"ipfs://{abs(hash('boa.example.com'))}",
        *hack_details,
    )
    owner = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
    hacker = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8"

    nft.setMinter(owner, sender=owner)
    nft.mint(hacker, sender=hacker)
    with boa.reverts():
        nft.mint(hacker, sender=hacker)
