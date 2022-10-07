pragma solidity ^0.8.0;

contract ZillowBlock {
    /* */
    event Transfer(
        address indexed _owner,
        address indexed _buyer,
        uint256 indexed _propertyhash
    );
    address private _owner;
    /* creating the Property data structure which will have the following properties*/
    struct Property {
        address propertyOwner;
        uint256 propertyhash;
        string propertyLocation;
        bool ForSale;
        uint256 Price;
    }

    /* creating the Owner data structure which will have the following properties*/
    struct Owner {
        address _owner;
        address Agent;
        uint256 numberOfProperties;
    }

    /* creating the buyer data structure which will have the following properties*/
    struct buyer {
        address _address;
    }

    /* we use the following modifier to ensure only the owner(person calling the contract) of the contract
    can perform functions/actions it is applied to*/
    modifier onlyOwner() {
        require(msg.sender == _owner, "Not owner");
        _;
    }

    /* The following mappings will make searching for data easier.
    some of them are public so users can easily view data from the contract*/
    mapping(address => Property) public ownerToProperty;
    mapping(uint256 => string) public PropertyHashToPropertyLocation;
    mapping(uint256 => address) public PropertyHashToOwner;
    mapping(address => uint256) ownerPropertyCount;
    mapping(uint256 => Property) public propertyhashToProperty;
    Property[] public AllProperties;
    Property[] public Ownerproperties;
    Property[] Buyerproperties;
    Property[] public ForSaleproperties;

    /* The following function will list a property to the market
    it take the owner's address, property location, for sale status and property price
    It will use owner's address, property location, for sale status and price to generate
    a unique hash for the property which can be used to look up the location and owner
    of the property.

    If the owner set the property's for sale bool as true, it will be included in the 
    forSaleproperties list. Whether the propert status is for sale or not, it will be 
    added to the all properties list.
    
    Anyone accessing the smart contract can use the owner's address and/or the property hash
    to find more info about the property*/

    function ListProperty(
        address _owner,
        string memory _propertyLocation,
        bool _ForSale,
        uint256 _price
    ) public onlyOwner {
        _owner = msg.sender;
        uint256 propertyhash = uint256(
            keccak256(
                abi.encodePacked(
                    msg.sender,
                    _propertyLocation,
                    _ForSale,
                    _price
                )
            )
        );
        Property memory newProperty = Property(
            _owner,
            propertyhash,
            _propertyLocation,
            _ForSale,
            _price
        );
        AllProperties.push(newProperty);
        Ownerproperties.push(newProperty);
        ownerToProperty[_owner] = newProperty;
        PropertyHashToOwner[propertyhash] = _owner;
        propertyhashToProperty[propertyhash] = newProperty;
        PropertyHashToPropertyLocation[propertyhash] = _propertyLocation;
        bool ForSale = _ForSale;
        if (ForSale = true) {
            ForSaleproperties.push(newProperty);
        }
    }

    /* The following function will be used to transfer ownership of property from
    one owner to another. It will take owner's address, buyer's address and property hash.
    
    It will automatically set the property forSale bool as "false" which will automatically 
    delist the property from the marketplace. The owner can then use the ListProperty function
    to list the property back to the market*/
    function transferOwnership(
        address _owner,
        address _buyer,
        uint256 propertyhash
    ) public onlyOwner {
        ownerPropertyCount[msg.sender]--;
        ownerPropertyCount[_buyer]--;
        ownerToProperty[_buyer] = propertyhashToProperty[propertyhash];
        propertyhashToProperty[propertyhash].ForSale = false; //updates forsale bool to false
        emit Transfer(_owner, _buyer, propertyhash);
    }

    function deListProperty(uint256 propertyhash) public onlyOwner {
        propertyhashToProperty[propertyhash].ForSale = false;
    }

    /* The following sell function will list the property to marketplace by 
    adding it to the ForSaleproperties list from which buyers can access it*/
    function sellProperty(uint256 propertyhash) public onlyOwner {
        Property memory newProperty = propertyhashToProperty[propertyhash];
        propertyhashToProperty[propertyhash].ForSale = false;
        ForSaleproperties.push(newProperty);
    }

    /* The follwing is a buy function. It is a payable function which means it accepts a payment.
    It will use the property's hash as input*/
    function buyProperty(uint256 _propertyhash) public payable onlyOwner {
        address _owner;
        address _originalOwner;
        PropertyHashToOwner[_propertyhash] = _originalOwner;
        Property memory _property = propertyhashToProperty[_propertyhash];
        require(_property.ForSale = true && msg.value >= _property.Price);
        transferOwnership(_originalOwner, _owner, _propertyhash);
    }
}
