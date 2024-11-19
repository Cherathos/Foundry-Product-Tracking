// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

error NotAdmin();

contract MyContract {
    error Product__CreateFailed();
    error Product__UpdateFailed();
    error Product__DeleteFailed();

    mapping(uint productIndex => mapping(string productName => uint price))
        public s_productToPrice;
    mapping(uint productIndex => mapping(string productName => uint quantity))
        public s_productToQuantity;
    mapping(uint productIndex => string productName) public s_indexToProduct;
    mapping(uint orderIndex => mapping(string productName => bool fulfilled))
        public s_deliveryStatus;
    mapping(uint orderIndex => mapping(string productName => uint quantity))
        public s_deliveryQuantity;

    uint private orderIndexCounter = 1;
    uint private productIndexCounter = 1;

    address private immutable admin;

    string private constant messageHata = "Hata";

    event productDeleted(uint indexed productIndex);
    event productUpdated(uint indexed productIndex);
    event productCreated(uint indexed productIndex);

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        if (msg.sender != admin) {
            revert NotAdmin();
        }
        _;
    }

    function createProduct(
        string memory _productName,
        uint _quantity,
        uint _price
    ) public onlyAdmin returns (string memory, uint) {
        if (_quantity >= 1 && _price >= 1) {
            s_indexToProduct[productIndexCounter] = _productName;
            s_productToPrice[productIndexCounter][_productName] =
                _price *
                1 ether;
            s_productToQuantity[productIndexCounter][_productName] = _quantity;
            emit productCreated(productIndexCounter);
            productIndexCounter++;
            return ("Urun Numarasi:", productIndexCounter - 1);
        } else {
            revert Product__CreateFailed();
        }
    }

    function deleteProduct(
        uint _productIndex,
        string memory _productName
    ) public onlyAdmin {
        delete s_indexToProduct[_productIndex];
        delete s_productToPrice[_productIndex][_productName];
        delete s_productToQuantity[_productIndex][_productName];
        if (s_productToPrice[_productIndex][_productName] == 0) {
            emit productDeleted(_productIndex);
        } else {
            revert Product__DeleteFailed();
        }
    }

    function updateProduct(
        uint _productIndex,
        string memory _productName,
        uint _quantity,
        uint _price
    ) public onlyAdmin {
        s_indexToProduct[_productIndex] = _productName;
        s_productToPrice[_productIndex][_productName] = _price * 1 ether;
        s_productToQuantity[_productIndex][_productName] = _quantity;
        if (s_productToPrice[_productIndex][_productName] == _price * 1 ether) {
            emit productUpdated(_productIndex);
        } else {
            revert Product__UpdateFailed();
        }
    }

    function buyProducts(
        uint _productIndex,
        string memory _productName,
        uint _quantity
    ) public payable returns (string memory, uint) {
        uint price = s_productToPrice[_productIndex][_productName];
        uint quantity = s_productToQuantity[_productIndex][_productName];
        uint totalPrice = price * _quantity;
        if (quantity < _quantity) {
            revert("Yeterli Miktarda Urun Bulunmamakta");
        } else if (msg.value >= totalPrice) {
            uint refundAmount = msg.value - totalPrice;
            if (refundAmount > 0) {
                (bool refundSuccess, ) = payable(msg.sender).call{
                    value: refundAmount
                }("");
                require(refundSuccess, "Para Ustu Iade Edilemedi");
            }
        } else {
            revert("Yetersiz Bakiye: Odeme Miktari Toplam Fiyatin Altinda");
        }
        (bool adminTransferSuccess, ) = admin.call{value: totalPrice}("");
        require(adminTransferSuccess, "Satin Alim Basarili Olmustur");

        uint newQuantity = quantity - _quantity;

        s_productToQuantity[_productIndex][_productName] = newQuantity;
        s_deliveryStatus[orderIndexCounter][_productName] = false;
        s_deliveryQuantity[orderIndexCounter][_productName] = _quantity;

        if (newQuantity == 0) {
            delete s_indexToProduct[_productIndex];
            delete s_productToPrice[_productIndex][_productName];
            delete s_productToQuantity[_productIndex][_productName];
        }

        orderIndexCounter++;
        return ("Siparis Numaraniz: ", orderIndexCounter - 1);
    }

    function fulfillDelivery(
        uint _orderIndex,
        string memory _productName
    ) public onlyAdmin {
        s_deliveryStatus[_orderIndex][_productName] = true;
    }

    function deleteFulfilledDelivery(
        uint _orderNumber,
        string memory _productName
    ) public onlyAdmin {
        delete s_deliveryQuantity[_orderNumber][_productName];
        delete s_deliveryStatus[_orderNumber][_productName];
    }

    function seeDeliveryStatus(
        uint _orderIndex,
        string memory _productName
    ) public view returns (bool, uint) {
        return (
            s_deliveryStatus[_orderIndex][_productName],
            s_deliveryQuantity[_orderIndex][_productName]
        );
    }

    function errorMsg() private pure returns (string memory) {
        return messageHata;
    }

    receive() external payable {
        errorMsg();
    }

    fallback() external {
        errorMsg();
    }

    function getProductToPrice(
        uint _productIndex,
        string memory _product
    ) external view returns (uint) {
        return s_productToPrice[_productIndex][_product];
    }

    function getProductToQuantity(
        uint _productIndex,
        string memory _product
    ) external view returns (uint) {
        return s_productToQuantity[_productIndex][_product];
    }

    function getDeliveryStatus(
        uint _orderIndex,
        string memory _product
    ) external view returns (bool) {
        return s_deliveryStatus[_orderIndex][_product];
    }

    function getDeliveryQuantity(
        uint _orderIndex,
        string memory _product
    ) external view returns (uint) {
        return s_deliveryQuantity[_orderIndex][_product];
    }

    function getProductName(
        uint _productIndex
    ) external view returns (string memory) {
        return s_indexToProduct[_productIndex];
    }

    function getAdmin() external view returns (address) {
        return admin;
    }
}
