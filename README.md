# How to Repro https://github.com/vyperlang/titanoboa/issues/143

* Install titanoba
* Run: `pytest`

The test fails and show a weird nested revert:

```python
boa.vyper.contract.BoaError: Revert("Revert(b'')")
```
