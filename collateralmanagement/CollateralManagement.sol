pragma solidity ^0.4.17;
contract CollateralManagement {
    
    BankLoan[] public bankLoans;//Array containing 10 BankLoan objects
    
    constructor() public payable{
       // lenders[msg.sender] = Lender({lenderId: 1, lenderAddr: msg.sender});
    }
    // Data
    //Structure to hold details of the Bank
    struct Lender {
        uint lenderId; // id of the Bank
        address lenderAddr;
    }
    
    struct Collateral {
        uint documentId;
        uint value;
        address borrowerAddr;
        address docAddress;
    }
   //Structure to hold the details of a persons
    struct Borrower {
        uint borrowerId; // it serves as tokenId as well
        address lenderAddr;
        address borrowerAddr;
    }
 
    struct BankLoan {
        uint loanAcctId;
        uint loanAmount;
        address borrowerAddr;
        address collateralAddr;
        address lenderAddr;
        uint remainingColAmt;
        uint status; // 1 for open, 0 for closed
    }
    mapping(address => Lender) public lenders; //address to Lender
    mapping(address => mapping(address => Borrower)) public borrowers; //address lenders -> Borrowers
    mapping(address => mapping(address => Collateral)) public collaterals; //collaterals mapped to Lender's address
    
    
    modifier onlyLender {
        require(
            lenders[msg.sender].lenderAddr == msg.sender,
            "Only Lender can call this."
        );
        _;
    }
    modifier uniqueLenderOnly {
        require(
            lenders[msg.sender].lenderAddr != msg.sender,
            "Only Unique Lender can be registered."
        );
        _;
    }
    event LoanRejected();
    event LoanApproved();
    event LenderRegistered();
    event CollateralSubmitted();
    event invalidCollateral();
    
    function isValidCollateral(address docAddr) view private returns (bool isValid) {
        for(uint i=0; i<bankLoans.length; i++){
            BankLoan storage loan = bankLoans[i];
            if(loan.status > 0 && loan.collateralAddr == docAddr && loan.remainingColAmt > 0){
                return false;
            }
        }
        return true;
    }
    /*Register the Banks/Lenders*/
    function registerLender(uint lenderId) public payable uniqueLenderOnly returns (bool success){
        lenders[msg.sender] = Lender({lenderId:lenderId, lenderAddr: msg.sender});
        return true;
    }
    
    /*Register the Borrowers with the Bank/Lender*/
    function registerBorrower(address bAddr, uint id) public onlyLender returns (bool success){
        if(lenders[bAddr].lenderAddr == bAddr){ // donot register lender as borrower
            revert();
        }
        if(borrowers[msg.sender][bAddr].borrowerAddr == bAddr){ //duplicate Borrower for the lender
            revert();
        }
        borrowers[msg.sender][bAddr] = Borrower({borrowerId:id, lenderAddr: msg.sender, borrowerAddr: bAddr});
        return true;
    }
    
    /*Register the collaterals of the borrower with the Bank*/
    function submitCollateral(address docAddr, address owner, uint docId, uint amount) public payable onlyLender {
        if(!isValidCollateral(docAddr)){
            emit invalidCollateral();
            revert();  
        } 
        
        Collateral memory col = Collateral({documentId: docId, value: amount, borrowerAddr: owner, docAddress: docAddr });
        collaterals[msg.sender][docAddr] = col;
        emit CollateralSubmitted();
    }
    /*Mimic the Bank loan approval process. This process assumes that the loan is approved 
    and a LoanId is created by the bank and a Collateral is submitted by the borrower 
    which is associted with the approved loan. This function can be improved to associate 
    multiple Collateral documents with the same Loan account*/
    function approveLoan(uint loanAcctId, uint loanAmount, address colAddr, address borrw) public payable onlyLender {
        if(!isValidCollateral(colAddr)){
            emit invalidCollateral();
            emit LoanRejected();
            revert();  
        } 
        bankLoans.push(BankLoan({loanAcctId: loanAcctId, loanAmount: loanAmount, lenderAddr: msg.sender, borrowerAddr: borrw, collateralAddr: colAddr, remainingColAmt: loanAmount, status: 1}));
        emit LoanApproved();
    }
}
