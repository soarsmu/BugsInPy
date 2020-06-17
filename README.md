# BugsInPy
BugsInPy: Benchmarking Bugs in Python Projects
##  Top 3 Contributors (of all time)
Name | Bugs Data | Verified Bugs Data
--- | --- | --- 
simshengqin | 250 | 250
Camellia Lok | 152 | 152
Qi Haodi | 89 | 89
##  Top 3 Contributors (last week)
Name | Bugs Data | Verified Bugs Data
--- | --- | --- 
simshengqin | 85 | 85
Camellia Lok | 60 | 60
Qi Haodi | 29 | 29
#### Total data : 661
#### Total verified bugs data : 652
###### Note: this list is based on the dataset bug without verifying the data. We will update this list of contributors based on the output of verify.sh that you pushed on the repo.

# Steps to set up BugsInPy
1. Clone BugsInPy:
    - `git clone https://github.com/soarsmu/BugsInPy`
2. Add BugsInPy executables path:
    - `export PATH=$PATH:<bugsinpy_path>/framework/bin`

# BugsInPy Command
Command | Description
--- | ---
checkout	| Checkout buggy or fixed version project from dataset
compile	| Compile sources from project that have been checkout
test	| Run test cases that relevant with bugs, single-test case, or all test cases from project
coverage |	Run code coverage analysis from test cases that relevant with bugs, single-test case, or all test cases
mutation |	Run mutation analysis from input user or test cases that relevant with bugs 

# Example BugsInPy Command
- Help usage from checkout command:
    - `bugsinpy-checkout --help`
- Checkout a buggy source code version (youtube-dl, bug 2, buggy version):
    - `bugsinpy-checkout -p youtube-dl -v 0 -i 2 -w /temp/projects`
- Compile sources and tests, and run tests from current directory:
    - `bugsinpy-compile`
    - `bugsinpy-test`

