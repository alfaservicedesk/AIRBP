/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A140IPRD  �Autor  � Alex Rodrigues     � Data �  15/07/16   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada na rotina MATA140I.PRW para definir o     ���
���          � c�digo de produto antes de olhar em produtosXfornecedir    ���
���          � no schedule do Totvs Colabora��o                           ���
�������������������������������������������������������������������������͹��
���Uso       � Air BP                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function A140IPRD() 

Local cFornec := PARAMIXB[1]
Local cLoja := PARAMIXB[2]
Local cPRD := PARAMIXB[3]
Local oDetItem := PARAMIXB[4] 
Local cNewPRD := ""         
Local lTemImp := .F.

Conout("A140IPRD -> Fornecedor/Produto: "+cFornec+"/"+cPrd)

If ALLTRIM(cFornec) == "000001"  //PETROBR�S - TODAS AS LOJAS

	//Tag IPI->cEnq = 002 - Internacional
	//Tag IPI->cEnq = 004 - Nacional
	If Alltrim(oDetItem:_imposto:_IPI:_cEnq:Text) == "004"
		lTemImp := .T.
		Conout("A140IPRD -> tem imposto")	
	EndIf

	If Alltrim(cPrd) == "PB641" 
		If lTemImp //QUEROSENE DE AVIA��O - CODIGO PETROBR�S
			cNewPRD := SuperGETMV("XCEJENA",.F.,"A08601N") //JET NACIONAL
			Conout("A140IPRD -> Produto: Nacional -> "+cNewPRD)			
		Else                                                             
			cNewPRD := SuperGETMV("XCEJEEX",.F.,"A08601E") //JET EXPORTA��O
			Conout("A140IPRD -> Produto: Exporta��o -> "+cNewPRD)						
		Endif
	Endif
Endif

//se o retorno for em branco, ele ir� buscar no cadastro de produto x fornecedor
Return cNewPRD