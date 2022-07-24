// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

struct Payment {
    address sender;
    address to;
    address token;
    uint256 amount;
}

interface IPaymentCallback {
    function onPaymentSuccess(Payment memory payment) external returns (bool);
}

contract TinyPaymentGateway {
    function onlyPay(
        address token,
        address to,
        uint256 amount
    ) public {
        bool success = IERC20(token).transferFrom(msg.sender, to, amount);
        require(success, "Payment Fail");
    }

    function pay(
        address token,
        address to,
        uint256 amount,
        address callbackContract
    ) public {
        bool success = IERC20(token).transferFrom(msg.sender, to, amount);
        require(success, "Payment Fail!");
        bool result = IPaymentCallback(callbackContract).onPaymentSuccess(
            Payment(msg.sender, to, token, amount)
        );
        require(result, "Payment Callback Fail!");
    }
