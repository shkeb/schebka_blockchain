// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;


contract Library{
    constructor(){
        libAdmin=msg.sender;
    }

    uint amountBooks = 0;
    address libAdmin;
    uint public priceForMonth = 1000 gwei;

    struct Book {
        string name;
        string picture;
        bool availability;
    }

    mapping (uint => Book) bookNumber;
    mapping (uint => address) rentedTo;

    //------------Admin

    function changeAdmin(address _newAdmin) public {
        require(libAdmin==msg.sender, "Only admin");
        libAdmin = _newAdmin;
    }
    function withdraw() public { 
        require(libAdmin==msg.sender, "Only admin"); 
        payable(libAdmin).transfer(address(this).balance); 
    }

    //------------Book

    function createBook(string calldata _name, string calldata _image) public returns(uint){
        require(libAdmin==msg.sender, "Only admin");
        //book creation
        bookNumber[amountBooks] = Book(_name, _image, true);
        amountBooks++;
        return amountBooks--;

    }

    function bookInfo(uint _bookID) public view returns ( Book memory){
        require(_bookID<amountBooks, "Not exist");
        return bookNumber[_bookID];
    }
    function rentBook(uint _bookID, uint _month) public payable{
        require(_bookID<amountBooks, "Not exist");
        require(priceForMonth*_month==msg.value, "Not enough founds");
        //require(rentedTo[_bookID]==0x0000000000000000000000000000000000000000, "Already rented");
        require(bookNumber[_bookID].availability, "Already rented");
        rentedTo[_bookID] = msg.sender;
        bookNumber[_bookID].availability = false;
    }
    function whereIsBook(uint _bookID) public view returns(address){
        require(_bookID<amountBooks, "Not exist");
        return  rentedTo[_bookID];
    }

    function returnBook(uint _bookID)public{
        require(msg.sender==libAdmin || msg.sender == rentedTo[_bookID], "Only admin ");
        bookNumber[_bookID].availability = true;
        delete rentedTo[_bookID];
    }


}
