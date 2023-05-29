// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
import "./ERC20.sol";

contract Disney{

    //-----------------------------Declaraciones iniciales -----------------------------

    //Instancia del contrato token
    ERC20Basic private token;

    //direccion del Owner
    address payable  public owner;

    //constructor
    constructor () public {
        token = new ERC20Basic(10000);
        owner = msg.sender;
    }

    //Estructura de datos para almacenar a los cleites
    struct cliente {
        uint tokens_comprados;
        string [] atracciones_disfrutadas;
    }

    mapping (address => cliente) public Clientes;

    //--------------------------------------GESTION DE TOKENS---------------------------

    //funcion para establecer el valor del token
    function PrecioTokens(uint _numTokens) internal pure returns(uint){
        return _numTokens*(1 ether);
    }

    //Funcion para comprar tokens
    function CompraTokens(uint _numTokens) public payable {

        //Estable cel precio de los tokens
        uint coste = PrecioTokens(_numTokens);

        //Revisa si el saldo es suficiente para la compra
        require (msg.value >= coste, "Saldo insuficiente deposita mas ethers");

        //Diferencia del pago del cliente
        uint returnValue = msg.value - coste;

        //Regreso de balance de sobra en la compra
        msg.sender.transfer(returnValue);

        //Regresa el nyumero de tokens disponibles
        uint Balance = balanceOf();
        require(_numTokens <= Balance, "Compra menos tokens");

        //Transferencia de tokesn al cliente
        token.transfer(msg.sender, _numTokens);

        //Registro de tokens comprados
        Clientes[msg.sender].tokens_comprados += _numTokens;
        
    }

    //Balance de tokens del parque de diversiones
    function balanceOf() public view returns(uint){
        return token.balanceOf(address(this));
    }

    //Visualizar el numero de tokens restante de un cliente
    function Mistokens () public view returns (uint){
        return token.balanceOf(msg.sender);
    }

    //Funcion para generar mas tokens
    function GeneraTokens(uint _numTokens) public Unicamente(msg.sender){
        token.increaseTotalSupply(_numTokens);
    }

    //Modificador para controlar las funciones ejecutables por disney
    modifier Unicamente(address _direccion){
        require(_direccion == owner, "No tienes permisos para ejecutar esta funcion");
        _;
    }

    //-----------------------------Declaraciones iniciales -----------------------------

    //Eventos
    event disfruta_atraccion(string);
    event nueva_atraccion(string);
    event baja_atraccion(string);

    //estructura de datos de la atraacion
    struct atraccion{
        string _nombre_atraccion;
        uint precio_atraccion;
        bool estado_atraccion;
    }

    //Mapping para relacionar el nombre de la atraccion con la estructura de datos de la atraccion
    mapping (string => atraccion) public MappingAtracciones;

    //Array para almacenar elestado de las atracciones
    string [] Atracciones;

    //Mapping para relacionar una identidad(cliente) con las transacciones
    mapping (address => string []) HistorialAtracciones;


    //Crear nuevas atracciones (Solo ejecutable por el owner dle contrato
    function NuevaAtraccion(string memory _nombreAtraccion, uint _precio) public Unicamente(msg.sender){
        
        //Creacion de una atraccion
        MappingAtracciones [_nombreAtraccion] = atraccion(_nombreAtraccion, _precio, true);

        //Almacenar en un array el nombre d ela atraccion
        Atracciones.push(_nombreAtraccion);

        //Emision del evento para la nueva atraccion
        emit nueva_atraccion(_nombreAtraccion);
    }

    //Dar de baja atracciones
    function BajaAtraccion (string memory _nombreAtraccion) public Unicamente(msg.sender){

        //Cuando pasa a False significa que no esta en uso
        MappingAtracciones [_nombreAtraccion].estado_atraccion = false;

        //Emison de evento
        emit baja_atraccion(_nombreAtraccion);
    }

    //visualizar todas las atraccion
    function AtraccionesDisponibles() public view returns(string[] memory){
        return Atracciones;
    }

    //Funcion para subirse a una atraccion  
    function SubirseAtraccion(string memory _nombreAtraccion) public{
        
        //Precio de la atraccion 
        uint tokens_atraccion = MappingAtracciones[_nombreAtraccion].precio_atraccion;

        //Verifica el estado de la atraccion para su uso
        require(MappingAtracciones[_nombreAtraccion].estado_atraccion == true, "La atraccion no esta disponile");

        //Verificar si el saldo es nsuficiente para el acceso
        require(tokens_atraccion <= Mistokens(), "No tienes los suficientes tokens");

        //El cliente paga la atraccion // fue necesario agregar una funcion al en ERC20.sol/transferencia_disney
        token.transferencia_disney(msg.sender, address(this), tokens_atraccion);

        //Alamacenar el hostorial del cliente
        HistorialAtracciones[msg.sender].push(_nombreAtraccion);

        //Evento para dar acceso a la atraccion
        emit disfruta_atraccion(_nombreAtraccion);
    }

    //visualizar lista de ataracciones
    function Historial() public view returns(string [] memory){
        return HistorialAtracciones[msg.sender];
    }

    //Funcion para devolver tokens
    function DevolverTokens (uint _numTokens) public payable {
        //Verificar que el numero de tokens es positivo
        require (_numTokens > 0, "No tienes tokens para devover");

        //user debe de tener la cantidad de token a devolver
        require (_numTokens <= Mistokens(), "No tienes tokens");

        //El cliente devulve los tokens
        token.transferencia_disney(msg.sender, address(this), _numTokens);

        //Devolucion de ethers al cleinte
        msg.sender.transfer(PrecioTokens(_numTokens));
    }

}