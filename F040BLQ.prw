#Include 'Protheus.ch'

/*
Programa.: F040BLQ
Autor....: Danilo Jos� Grodzicki
Data.....: 16/08/2017 
Descri��o: O ponto de entrada F040BLQ � utilizado para, em determinadas situa��es, bloquear a utiliza��o das rotinas de inclus�o, exclus�o, altera��o e
substitui��o de titulos a receber. Este ponto de entrada possui retorno l�gico.
Uso......: AIR BP BRASIL LTDA
*/
User Function F040BLQ()

	Local cMsg

	Local lRet := .T.

	if Inclui
		Return(lRet)
	endif

	if Altera
		cMsg := "Altera��o Inv�lida."
	else
		if Right(cCadastro,10) == "SUBSTITUIR"
			cMsg := "Substituir Inv�lido."
		else
			cMsg := "Exclus�o Inv�lida."
		endif
	endif

	//if SE1->E1_XBILLIN == "T" // alterado Julio N�gri 23.10.17 - n�o pode excluir faturas cujo e-billing n�o foi gerado
	if SE1->E1_XBILLIN == "F" .AND. SE1->E1_MOEDA <> 1
		MsgStop("Foi gerado eBilling no dia "+DtoC(StoD(Left(SE1->E1_XDTHRBI,8)))+" - "+Right(SE1->E1_XDTHRBI,8)+". - "+cMsg,"ATEN��O")
		lRet := .F.
	endif

	if SE1->E1_XISP == "S" .AND. SE1->E1_MOEDA <> 1
		MsgStop("Foi gerado ISP no dia "+DtoC(StoD(Left(SE1->E1_XISPDT,8)))+" - "+Right(SE1->E1_XISPDT,8)+". - "+cMsg,"ATEN��O")
		lRet := .F.
	endif

	if SE1->E1_XIMI == "S" .AND. SE1->E1_MOEDA <> 1
		MsgStop("Foi gerado IMI no dia "+DtoC(StoD(Left(SE1->E1_XIMIDT,8)))+" - "+Right(SE1->E1_XIMIDT,8)+". - "+cMsg,"ATEN��O")
		lRet := .F.
	endif

Return(lRet)