#Include 'Protheus.ch'

/*
Programa.: M410STTS
Autor....: Danilo Jos� Grodzicki
Data.....: 13/10/2016 
Descricao: Ponto de Entrada localizado ap�s a grava��o das informa��es padr�es do tributo para t�tulo a ser gerado no financeiro, 
           isso vale para todos os impostos processados na fun��o GravaTit(). Deve ser utilizado para complementar ou alterar os valores padr�es
           j� gravados no t�tulo gerado pelos programas MATA461 (Nota Fiscal de Sa�da) ou MATA103 (Nota Fiscal de Entrada) atrav�s da configura��o
           via F12 para gerar t�tulos de ICMS-ST e DIFAL. O registro da tabela SE2 est� posicionado. � passado como par�metro para o ponto de entrada
           o nome da rotina que est� sendo executada no momento para facilitar o desenvolvimento de situa��es especificas dentro do ponto de entrada,
           o segundo par�metro identifica o tipo do imposto contido na guia de recolhimento da tabela SF6 e o �ltimo par�metro identifica se o t�tulo
           a ser gravado no momento se trata de DIFAL. Tamb�m � utilizado por outras rotinas, como MATA954 (Apura��o de ISS),
           MATA953 (Apura��o de ICMS), etc....
Uso......: AIR BP BRASIL LTDA
*/
User Function TITICMST()

Local cOrigem  := PARAMIXB[1]
Local cTipoImp := PARAMIXB[2]
Local lDifal   := PARAMIXB[3]
Local aAreaSF6 := SF6->(GetArea())

DbSelectArea("SF6")
SF6->(DbSetOrder(03))

If AllTrim(cOrigem)= "MATA953" .or. AllTrim(cOrigem)= "MATA954" .or. AllTrim(cOrigem)= "FISA091"
	RestArea(aAreaSF6)
	Return({SE2->E2_NUM,SE2->E2_VENCTO})
endif

If RecLock("SE2",.F.)
	SE2->E2_VENCTO  := dDataBase
	SE2->E2_VENCREA := dDataBase 
	SE2->(MsUnLock())
endif

if SF6->(DbSeek(xFilial("SF6")+"2"+SF2->F2_TIPO+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
	If RecLock("SF6",.F.)
		SF6->F6_DTVENC := dDataBase 
		SF6->(MsUnLock())
	endif
endif

RestArea(aAreaSF6)

Return({SE2->E2_NUM,SE2->E2_VENCTO})