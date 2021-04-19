#Include 'Protheus.ch'

/*
Programa.: M440STTS
Autor....: Danilo Jos� Grodzicki
Data.....: 29/04/2017 
Descricao: Antes de gravar o numero da Autorizacao de Entrega. Este P.E. e utilizado para permitir gravar cpos de usuarios em itens de SC9. 
Uso......: AIR BP BRASIL LTDA
Controle de altera��ao:
- Solicitado em 17/08/17 a grava��o do campo SC5->C5_XDTEMIS em campo do SC9
	Criado campo no SC9->C9_XDTEMIS,D,8 (Data do Abastecimento)
	
*/
User Function M440SC9I()                            

Local aAreaSC9

if !Empty(SC5->C5_XNUMCE)  // Tem CE

	aAreaSC9 := SC9->(GetArea())  // Grava o n�mero da CE no SC9
	
	DbSelectArea("SC9")
	SC9->(DbSetOrder(01))
	
	if SC9->(DbSeek(xFilial("SC9")+SC5->C5_NUM))
		while SC9->C9_FILIAL+SC9->C9_PEDIDO == SC5->C5_FILIAL+SC5->C5_NUM .and. SC9->(!Eof())
			If RecLock("SC9",.F.)
				SC9->C9_XNUMCE  := SC5->C5_XNUMCE
				SC9->C9_XCODAER := SC5->C5_XCODAER
				SC9->C9_XNUMVOO := SC5->C5_XNUMVOO
				SC9->C9_XDTEMIS := SC5->C5_XDTEMIS //Data do Abastecimento - altera��o efetuada em 17/08 RTP
				SC9->(MsUnlock())
			endif
			SC9->(DbSkip())
		enddo
	endif
	
	RestArea(aAreaSC9)

endif

Return Nil