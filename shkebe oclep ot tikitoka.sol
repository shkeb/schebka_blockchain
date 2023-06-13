pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol"; 

contract ShkebTok is ERC1155{

    constructor() ERC1155(""){
        libAdmin=msg.sender;
    }

    uint amountAccounts = 1;
    address libAdmin;
    uint public priceForWeek = 10000 wei;
    uint balance;

    mapping (uint => string) accountNumber;
    mapping (uint => uint) public accountBalance;
    mapping (uint => address) rentedTo;
    mapping  (address => uint) public whereIsAccountSt;

    function createAccount(string calldata _url) public payable  {
        require(libAdmin==msg.sender, "Only admin");
        //book creation
        accountNumber[amountAccounts] =_url;
        //Cоздание токена
        _mint(libAdmin, amountAccounts, 1, "");
        //Пополнение баланса
    
        amountAccounts++;
    }

    function getAmount() public view returns(uint) {
        return amountAccounts - 1;
    }

    function url(uint _accountId) public view returns(string memory) {
        return "https://github.com/shkeb/schebka_blockchain/blob/main/ShkebCoin.json";
    }

    //Аренда
    function rentBook(uint _accountId, uint _week) public payable {
        uint amount = priceForWeek * _week;
        require(whereIsAccountSt[msg.sender] == 0, "You have an account");
        require(_accountId < amountAccounts, "Not exist");
        require(amount== msg.value, "Not enough funds");
        require(balanceOf(libAdmin, _accountId) != 0, "Already rented");
        rentedTo[_accountId] = msg.sender;
        //Согласие админа на управление токенами
        _setApprovalForAll(libAdmin, msg.sender, true);
        //Передача токена
        safeTransferFrom(libAdmin, msg.sender, _accountId, 1, "");
        //Запрет админа на управление токенами
        _setApprovalForAll(libAdmin, msg.sender, false);
        uint adminProcent = amount * 90/100;
        uint other  = amount - adminProcent;
        accountBalance[_accountId] += other;
        whereIsAccountSt[msg.sender] = _accountId;
        payable(libAdmin).transfer(adminProcent); 
    }

    //Admin
    function withdraw(uint _accountId) public { 
        require(accountBalance[_accountId] > 1020); 
        uint different = accountBalance[_accountId] - 1020;
        payable(msg.sender).transfer(different); 
        accountBalance[_accountId] -= different;
    }

    function whereIsAccount(uint _accountId) public view returns(address) {
        require(_accountId < amountAccounts || _accountId == 0, "Not exist");
        return rentedTo[_accountId];
    }

    function whichAccount() public view returns(uint) {
        return whereIsAccountSt[msg.sender];
    }

    function viewVideo(uint _accountId) public {
       require(msg.sender == whereIsAccount(_accountId), "Its not your account");
       accountBalance[_accountId] += 1 wei;
    }

    function upoadVideo(uint _accountId) public {
        require(accountBalance[_accountId] > 100 wei);
        require(msg.sender == whereIsAccount(_accountId), "Its not your account");
        accountBalance[_accountId] -= 100 wei;
    }

    function returnAccount(uint _accountId) public{
        require(msg.sender == rentedTo[_accountId], "Only admin");
        safeTransferFrom(msg.sender, libAdmin, _accountId, 1, "");
        delete rentedTo[_accountId];
    }


}
