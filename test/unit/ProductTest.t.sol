// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {MyContract} from "../../src/MyContract.sol";
import {DeployContract} from "../../script/DeployContract.s.sol";

contract ProductTest is Test {
    MyContract myContract;

    address USER1 = makeAddr("user1");
    address USER2 = makeAddr("user2");
    uint Starting_Balance = 10 ether;

    function setUp() external {
        DeployContract deployContract = new DeployContract();
        myContract = deployContract.run();
        vm.deal(USER1, Starting_Balance);
        vm.deal(USER2, Starting_Balance);
    }

    function testUsersEthValue() public view {
        assertEq(USER1.balance, Starting_Balance);
        assertEq(USER2.balance, Starting_Balance);
    }

    function testNotAdminUser1() public {
        address admin = myContract.getAdmin();
        vm.expectRevert();
        assertEq(USER1, admin);
    }

    function testNotAdminUser2() public {
        address admin = myContract.getAdmin();
        vm.expectRevert();
        assertEq(USER2, admin);
    }

    function testProductCreate() public {
        vm.prank(myContract.getAdmin());
        myContract.createProduct("a", 13, 2);
        assertEq(myContract.getProductName(1), "a");
        assertEq(myContract.getProductToPrice(1, "a"), 2 ether);
        assertEq(myContract.getProductToQuantity(1, "a"), 13);
    }

    modifier productCreated() {
        vm.prank(myContract.getAdmin());
        myContract.createProduct("a", 9, 1);
        _;
    }

    function testDeleteProduct() public productCreated {
        vm.prank(myContract.getAdmin());
        myContract.deleteProduct(1, "a");
        assertEq(myContract.getProductName(0), "");
        assertEq(myContract.getProductToPrice(1, "a"), 0);
        assertEq(myContract.getProductToQuantity(1, "a"), 0);
    }

    function testProductUpdate() public productCreated {
        vm.prank(myContract.getAdmin());
        myContract.updateProduct(1, "b", 4, 6);
        assertEq(myContract.getProductName(1), "b");
        assertEq(myContract.getProductToPrice(1, "b"), 6 * 1 ether);
        assertEq(myContract.getProductToQuantity(1, "b"), 4);
    }

    function testBuyProductWithoutFund() public productCreated {
        vm.expectRevert();
        myContract.buyProducts(1, "a", 1);
    }

    function testBuyProductWithFund() public productCreated {
        uint adminBalance = myContract.getAdmin().balance;
        uint buyerBalance = address(USER1).balance;

        vm.prank(USER1);
        myContract.buyProducts{value: 5 ether}(1, "a", 1);

        uint endingAdminBalance = myContract.getAdmin().balance;
        uint endingBuyerBalance = address(USER1).balance;
        assertEq(
            endingAdminBalance + endingBuyerBalance,
            adminBalance + buyerBalance
        );
    }

    function testNoProductLeft() public productCreated {
        vm.prank(USER1);
        myContract.buyProducts{value: 9 ether}(1, "a", 9);
        assertEq(myContract.getProductName(1), "");
    }

    function testDeliveryDelivered() public productCreated {
        vm.prank(USER1);
        myContract.buyProducts{value: 5 ether}(1, "a", 1);
        vm.prank(myContract.getAdmin());
        myContract.fulfillDelivery(1, "a");
        assertEq(myContract.getDeliveryStatus(1, "a"), true);
    }
}
