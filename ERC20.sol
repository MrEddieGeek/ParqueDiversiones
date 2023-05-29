// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol";


//Ediveloper 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
//Eddigeek   0x5B38Da6a701c568545dCfcB03FcB875f56beddC4_
//Eddie ge   0x5B38Da6a701c568545dCfcB03FcB875f56beddC4

//Interface del token lustucru
interface IERC20{
    //Muestra la cantidad de tokens en existencia
    function totalSupply() external view returns(uint256);

    //Muestra la cantidad de tokens de una direccion indicada por parametros
    function balanceOf(address account) external view returns(uint);

    //devuelve el numero de tokens que el spender podra gastar en nombre del owner
    function allowance(address owner, address spender) external view returns(uint256);
       
    //devuelve un valor booleano de la trnasferencia
    function transfer(address recipient, uint256 amount) external  returns(bool);

    function transferencia_disney(address _cliente, address recipient, uint256 amount) external  returns(bool);


    //Devuelve un valor booleano con el resultado de la operacion de gasto
    function approve(address spender, uint256 amount) external returns(bool);

    //Devue;ve un valor booleano con la cantidad de tokens de la trasaccion usando allowance()
    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);



    //Evento de notificacion cuando una cantodad pase de un origen a un destino 
    event Transfer(address indexed from, address indexed to, uint256 amount);

    //Envento de notificacion cuando se establece una asignacion con el metodo allowance()
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

//Implementacion de las funciones del token
contract ERC20Basic is IERC20{

    string public constant name = "LustucruCoin";
    string public constant symbol = "LUSTU";
    uint8 public constant decimals = 2;



    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed owner, address indexed spender, uint256 tokens);


    using SafeMath for uint256;

    mapping (address => uint) balances;
    mapping (address => mapping(address => uint)) allowed;
    uint256 totalSupply_; 

    constructor(uint256 initialSupply) public{
        totalSupply_ = initialSupply;
        balances[msg.sender] = totalSupply_;
    }



    function totalSupply() public override view returns(uint256){
        return totalSupply_; 
    }

    function increaseTotalSupply(uint newTokensAmount) public{
        totalSupply_ += newTokensAmount;
        balances[msg.sender] += newTokensAmount;
    }

    function balanceOf(address tokenOwner) public override view returns(uint){
        return  balances[tokenOwner];
    }

    function allowance(address owner, address delegate) public override  view returns(uint256){
        return allowed[owner][delegate];
    }

    function transfer(address recipient, uint256 numTokens) public override  returns(bool){
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[recipient] = balances[recipient].add(numTokens);
        emit Transfer(msg.sender, recipient, numTokens);
        return true;
    }
    
    function transferencia_disney(address _cliente, address recipient, uint256 numTokens) public override  returns(bool){
        require(numTokens <= balances[_cliente]);
        balances[_cliente] = balances[_cliente].sub(numTokens);
        balances[recipient] = balances[recipient].add(numTokens);
        emit Transfer(_cliente, recipient, numTokens);
        return true;
    }


    function approve(address delegate, uint256 numTokens) public override returns(bool){
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns(bool){
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner,buyer, numTokens);

        return true;
    }
}