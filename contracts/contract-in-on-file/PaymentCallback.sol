// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

struct Payment {
    address sender;
    address to;
    address token;
    uint256 amount;
}

interface IPaymentCallback {
    function onPaymentSuccess(Payment memory payment) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract CertifiedPaymentGateway is Ownable {
    mapping(address => bool) gateways;

    function isPaymentGatewayCertified(address gateway)
        public
        view
        virtual
        returns (bool)
    {
        return gateways[gateway];
    }

    function _checkGateway(address gateway) internal view virtual {
        require(
            isPaymentGatewayCertified(gateway),
            "CertifiedPaymentGateway: the gateway is not certified"
        );
    }

    modifier onlyCertifiedGateway() {
        _checkGateway(_msgSender());
        _;
    }

    function setCertifiedGateway(address gate, bool status)
        public
        virtual
        onlyOwner
    {
        gateways[gate] = status;
    }
}

contract PaymentCallbackDemo is CertifiedPaymentGateway, IPaymentCallback {
    address public beneficiaryAddress;
    address public token;
    uint256 public amount;
    mapping(address => uint256) private _balances;

    constructor(
        address _beneficiaryAddress,
        address _token,
        uint256 _amount
    ) {
        beneficiaryAddress = _beneficiaryAddress;
        token = _token;
        amount = _amount;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function onPaymentSuccess(Payment memory payment)
        public
        onlyCertifiedGateway
        returns (bool)
    {
        require(
            payment.to == beneficiaryAddress &&
                payment.token == token &&
                payment.amount == amount,
            "Not right payment"
        );
        // do something
        _balances[payment.sender] = _balances[payment.sender] + 1;
        return true;
    }
}
