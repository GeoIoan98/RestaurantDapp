pragma solidity ^0.4.24;

contract Competition {

    struct Restaurant {
        address addr;
        string name;
        uint256 amount;
        uint256 expiration;
        address winner;
        Customer[] customers;
        uint256 length;
    }

    struct Customer {
        address addr;
        string name;
    }

    mapping (address => Restaurant) public restaurants;
    mapping (uint256 => Customer) public customers;

    address public owner;

    //event PaymentSuccessful(address _from, address _to);

    constructor() public {
        owner = msg.sender;
    }

    function add_restaurant_to_competition(string name, uint256 expiration) public payable {
        //require(restaurants[addr] == 0); to ensure not again in competition
        Restaurant restaurant;
        restaurant.addr = msg.sender;
        restaurant.name = name;
        restaurant.amount = msg.value;
        restaurant.expiration = expiration;
        restaurant.length = 0;
        restaurants[msg.sender] = restaurant;
    }

    function add_customer_to_competition(string name, address restaurant) public {
        require(restaurants[msg.sender].addr == 0); // customer is not a restaurant
        require(now < restaurants[restaurant].expiration); // check that it is within the given period

        for (uint256 i = 0; i < restaurants[restaurant].length; i += 1) {
            require(restaurants[restaurant].customers[i].addr != msg.sender); // First time I am added to the competition, checks against replay attack
        }

        Customer customer;
        customer.addr = msg.sender;
        customer.name = name;

        restaurants[restaurant].customers.push(customer);
        restaurants[restaurant].length += 1;
    }

    function get_winner(address restaurant) view public returns(address) {
        require(now >= restaurants[restaurant].expiration);
        require(restaurants[restaurant].winner == 0);
        uint256 length = restaurants[restaurant].length;
        uint randomnumber = uint(keccak256(abi.encodePacked(now, msg.sender))) % length;
        restaurants[restaurant].winner = restaurants[restaurant].customers[randomnumber].addr;

        restaurants[restaurant].winner.transfer(restaurants[restaurant].amount);

        return restaurants[restaurant].customers[randomnumber].addr;

    }






}
