#Include 'Protheus.ch'

/*
Programa.: M410INIC
Autor....: Danilo Jos� Grodzicki
Data.....: 02/11/2017 
Descricao: Este ponto de entrada � chamado antes da abertura da tela de inclus�o do pedido de vendas com o objetivo de permitir a valida��o do usu�rio. 
Uso......: AIR BP BRASIL LTDA
*/
User Function M410INIC()

if !U_ZA5TRAVA("SC5")
	Help( ,, 'Trava de Estoque',, 'Filial temporariamente n�o autorizada a lan�ar Pedido de Venda.', 1, 0 )
endif

Return Nil