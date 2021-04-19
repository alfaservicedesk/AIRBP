
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MA020TOK �Autor  � Renato Tadeu Pianta� Data �  13/01/17   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida a obrigatoriedade de digita��o para o campo A2_CGC  ���
���          � Devido a exist�ncia de fornecedores estrangeiros o campo   ���
���          � n�o ser� colocado com preenchimento obrigat�rio, sendo que ���
���          � quando A2_EST != "EX", exige a digita��o do mesmo.         ���
�������������������������������������������������������������������������͹��
���Uso       � Espec�fico AirBP                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function MA020TOK

local _lRet := .T.

if M->A2_EST != "EX" .and. empty(M->A2_CGC)
	Aviso("Cadastro de Fornecedores","� necess�rio digitar o CNPJ/CPF para este Fornecedor. Verifique!",{"Ok"},1,"Aten��o!")	
	_lRet := .F.
Endif

Return _lRet