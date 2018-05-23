# Somewhat homomorphic encryption over elliptic curve using BGN algorithm

## Todo

* [x] Convert public key into human-friendly form.
* [ ] Write encrypt function
* [ ] Write decrypt function
* [ ] Convert plaintext or binary data into bit as a input for encryption/decryption process

## Installation (Ubuntu/Debian)

```
# apt-add-repository -y ppa:aims/sagemath
# apt-get update
# apt install sagemath-upstream-binary
```

### Test 

```
# sage -v
```

### Disable security warning

Add `export PYTHONWARNINGS="ignore:not adding directory '' to sys.path"` into `.bashrc`

## Run

```
# sage bgn.sage
```

### Running time

* ~ 18 seconds on i7-6820HQ (single core run at 3.6 GHz max)
* ~ 15 seconds on Xeon E5-2676 v3 (single core run at 3 GHz max)
* ~ 23 seconds on Xeon E5-2650 v4 (single core run at 2.9 GHz max)
* ~ 30 seconds on Xeon X5650 (single core run at 3.06 GHz max) (vCPU model is kvm64)
* ~ 19 seconds on Xeon X5650 (single core run at 3.06 GHz max) (vCPU model is host-passthrough)
* ~ 16 seconds on Xeon E5-2670 (single core run at 3.3 GHz max)
* ~ 17 seconds on Xeon E5-2683 v3 (single core run at 3 GHz max)
* ~ 25 seconds on Xeon E5-2683 v3 (single core run at 3 GHz max) (vCPU model is kvm64)
* ~ 17 seconds on Xeon E5-2683 v3 (single core run at 3.06 GHz max) (vCPU model is host-passthrough)

## Sample output

```
[Public key]
H4sIAOtiBVsC/yWUyU0EQQxFUxnNCSQO3hdSQeSfBs/NAWm6qLK//+Kft4qNiMn6qnbXdGTkchzqqlkp6SYlO+Hemr2xUTaVVr6TUqk+22bStt7SpZFDyVIJrZgQ7o1P87aCtxYdU+Oe1hWtEdP0qZlQPoHAQ49eal/REe9Yikc1MMo0PTy4HD2mxe3cvGbrImrtGlsFXuW/Y7HOC0kBmNKcppOuTgNVikiF7q47VbOru2dDrYR2yUvo4KVszKatxL6/Xu8PhxSd7AxRsHfLWPrmhi09mlM7kFqWYZOmcCM+uV4A7FooKGuDIG237jSeM0dnddFVbCFLbrKs0YaiLTB7zpEs06p8ngy0vGunZgDCEnahDyEWumECBaTceOCML5J5KkXTppdzs+ZXiNEC0ZYDHiqPwsE5Vbn3viH+WrsbjFxLXnXghZNltxqfxEpDqF1/C15NzyAOjV/fLz51gHFtMnnm6NtoO1joGFoR7FbtjNqSSAF8BtRStdN/IExlyilksCHnVjx1bVyYqhJrKCTABpJ5wRFG1hs9BfZLQBhHPIJp48Y6hwWKNX/Ye2jF7EyAO0qxYbbucABkyqAecMkG7sduINQ4z6MXwOMqCZpNb8OYZ+1ZkftATIusMzN2RiWuQajg3cH2eBIBdfw8ee7DcuYKcfr5GM/Qrjk6z1MSKdoK1hejzyjC4kdvKiIpB1sCR5dAbC/k24eIEGA04wgLkIcNf0J7H0zKBcMsJwbORDxnCmSqow47ZeaNHGYYDIcvFl9rIRyGjdHC9MLo9OYp1IKAnFfcOYJhcr+YohNRHRYOYGO4i4BQMW16qYH+TVyAfmiAxOClsDvjXSZpFQvgIo4ECOmRHNOcWYkrvsVtELZnPNRpRqOospaQHw0edW4xOSNgVHxJ9FlMRz0wKAsVtwc4JR1kBxrpDvUMfKCkTlQyaIyb5/28fQBk7MKtrFqWGD4HEdTxRbIOg5+yWADPwduVYC1AgcExjUjzeRqu5zYNoB4Q1PBnI6ECPCJp35zkHvCQz5aSyxPnbEMIOUbxCKsANCQbSrAe+j7rF435jfqQIBdxprB5FvqJ+2+83z/1bvfyKwYAAA==

[Private key]
H4sIAOtiBVsC/w2MwREAMAjCVhIExf0XazleXMIVR13a39YcE6LPbHbHw7ZoBRXfjFSMchuheonChiLBa0OH/fu3NlaV4p9RvnVVs6rFflTW3Wj8kcW/Zz5BLrzl9BweNuBXCZoAAAA=
```
