pragma solidity ^0.8.1;

abstract contract ERC20{
  function balanceOf(address _owner) public virtual view returns (uint256 balance);
  function transfer(address to, uint256 value) public virtual returns (bool);
  function transferFrom(address _from, address _to, uint256 _value) public virtual returns (bool success);
}

contract PaidPool{
    
    address owner;
    
    address Paid;
    
    uint depositLimit; 
    
    bool active;
    
    mapping(address=>uint) shares;
    
    constructor(address _Paid, uint _depositLimit) {
        Paid = _Paid;
        depositLimit = _depositLimit;
        owner = msg.sender;
    }
    
    struct investorAllocationStatus {
        bool invested;
        bool paidOut;
    }
    
    struct allocation{
        address token;
        uint ethRequired;
        uint amountPaidOut;
        mapping(address => investorAllocationStatus) investorAllocationStatuses;
    }
    
    allocation[] allocations;
    
    
    
    function confirmAllocation(address token,uint ethRequired) public{
        allocation storage a = allocations[allocations.length];
        a.token = token;
        a.ethRequired = ethRequired;
    
    }
    
    function confirmPayout(uint allocationId,uint amount) public{
        require(active);
        require(ERC20(allocations[allocationId].token).balanceOf(address(this))==amount);
        allocations[allocationId].amountPaidOut = amount;
    }
    
    function deposit(uint amount) public{
        require(balance()<=depositLimit, "deposit Limit has been reached");

        if((balance()+amount)>depositLimit){
            amount = depositLimit-balance();
            active = true;
        }  
        
        ERC20(Paid).transferFrom(msg.sender,address(this),amount);
        shares[msg.sender] += amount;
    }
    
    function invest(uint allocationId) public payable {
        uint amount = (depositLimit* allocations[allocationId].ethRequired)/shares[msg.sender];
        require(msg.value==amount);
        require(allocations[allocationId].investorAllocationStatuses[msg.sender].invested==false);
        allocations[allocationId].investorAllocationStatuses[msg.sender].invested = true;
        
    }
    
    function getPayOut(uint allocationId) public {
        require(allocations[allocationId].amountPaidOut>0);
        require(allocations[allocationId].investorAllocationStatuses[msg.sender].invested = true);
        uint amount = (depositLimit* allocations[allocationId].amountPaidOut)/shares[msg.sender];
        ERC20(Paid).transfer(msg.sender,amount);
    }
    
    function balance() public view returns (uint){
        return(ERC20(Paid).balanceOf(address(this)));
    }
    
}
