pragma solidity ^0.4.0;
contract Coin {
    address public minter;
    mapping(address => uint) balances;
    
    function Coin() {
        minter = msg.sender;
    }
    
    function mint(address receiver, uint amount) public {
        if(msg.sender != minter) return;
        balances[receiver] += amount;
    }
    function send(address receiver, uint amount) public {
        if(balances[msg.sender] < amount) return;
        balances[receiver] += amount;
        balances[msg.sender] -= amount;
        sent(msg.sender, receiver, amount);
    }
    function sent(address from, address to, uint amount) {
        
    }
    function queryBalance(address x) public constant returns(uint){
        return balances[x];
    }
}
