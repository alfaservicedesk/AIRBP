#INCLUDE 'Protheus.ch'
#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � UPDDESCA �Autor  �Danilo Jos� Grodzicki� Data�  28/09/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � Compatibilizador para Desc�lculo no pedido de venda.       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AIR BP BRASIL LTDA                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function UPDDESCA()

Local aSay      := {}
Local aButton   := {}
Local aMarcadas := {}
Local cTitulo   := "ATUALIZA��O DE DICION�RIOS E TABELAS"
Local cDesc1    := "Esta rotina tem como objetivo realizar a atualiza��o dos dicion�rios do Sistema ( SX?/SIX )."
Local cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja n�o podem haver outros usu�rios "
Local cDesc3    := "ou jobs utilizando o sistema. � extremamente recomend�vel que se fa�a um BACKUP DOS "
Local cDesc4    := "DICION�RIOS e da BASE DE DADOS antes desta atualiza��o, para que caso ocorra eventuais"
Local cDesc5    := "falhas, esse backup seja restaurado."
Local cDesc6    := ""
Local cDesc7    := ""
Local lOk       := .F.

Private oMainWnd  := NIL
Private oProcess  := NIL

#IFDEF TOP
    TCInternal( 5, '*OFF' ) // Desliga Refresh no Lock do Top
#ENDIF

__cInterNet := NIL
__lPYME     := .F.

Set Dele On

// Mensagens de Tela Inicial
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
aAdd( aSay, cDesc4 )
aAdd( aSay, cDesc5 )
//aAdd( aSay, cDesc6 )
//aAdd( aSay, cDesc7 )

// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

FormBatch(  cTitulo,  aSay,  aButton )

If lOk
	aMarcadas := EscEmpresa()

	If !Empty( aMarcadas )
		If  ApMsgNoYes( 'Confirma a atualiza��o dos dicion�rios ?', cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas ) }, 'Atualizando', 'Aguarde, atualizando ...', .F. )
			oProcess:Activate()

			If lOk
				Final( 'Atualiza��o Conclu�da.' )
			Else
				Final( 'Atualiza��o n�o Realizada.' )
			EndIf

		Else
			Final( 'Atualiza��o n�o Realizada.' )

		EndIf

	Else
		Final( 'Atualiza��o n�o Realizada.' )

	EndIf

EndIf

Return NIL

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � FSTProc  � Autor � Microsiga        � Data �  25/07/2011   ���
�������������������������������������������������������������������������͹��
��� Descricao� Funcao de processamento da grava��o dos arquivos           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � FSTProc  - Gerado por EXPORDIC / Upd. V.4.01 EFS           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FSTProc( lEnd, aMarcadas )
Local   aInfo     := {}
Local   aRecnoSM0 := {}
Local   cAux      := ''
Local   cFile     := ''
Local   cFileLog  := ''
Local   cMask     := 'Arquivos Texto (*.TXT)|*.txt|'
Local   cTCBuild  := 'TCGetBuild'
Local   cTexto    := ''
Local   cTopBuild := ''
Local   lOpen     := .F.
Local   lRet      := .T.
Local   nI        := 0
Local   nPos      := 0
Local   nRecno    := 0
Local   nX        := 0
Local   oDlg      := NIL
Local   oFont     := NIL
Local   oMemo     := NIL

Private aArqUpd   := {}

If ( lOpen := MyOpenSm0Ex() )

	dbSelectArea( 'SM0' )
	dbGoTop()

	While !SM0->( EOF() )
		// So adiciona no aRecnoSM0 se a empresa for diferente
		If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 ;
		   .AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0
			aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO } )
		EndIf
		SM0->( dbSkip() )
	End

	If lOpen

		For nI := 1 To Len( aRecnoSM0 )

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			RpcSetType( 2 )
			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			cTexto += Replicate( '-', 128 ) + CRLF
			cTexto += 'Empresa : ' + SM0->M0_CODIGO + '/' + SM0->M0_NOME + CRLF + CRLF

			oProcess:SetRegua1( 8 )

			//����������������������������������Ŀ
			//�Atualiza o dicion�rio SX2         �
			//������������������������������������
			oProcess:IncRegua1( 'Dicion�rio de arquivos - ' + SM0->M0_CODIGO + ' ' + SM0->M0_NOME + ' ...' )
			FSAtuSX2( @cTexto )

			//����������������������������������Ŀ
			//�Atualiza o dicion�rio SX3         �
			//������������������������������������
			FSAtuSX3( @cTexto )

			//����������������������������������Ŀ
			//�Atualiza o dicion�rio SIX         �
			//������������������������������������
			oProcess:IncRegua1( 'Dicion�rio de �ndices - ' + SM0->M0_CODIGO + ' ' + SM0->M0_NOME + ' ...' )
			FSAtuSIX( @cTexto )

			oProcess:IncRegua1( 'Dicion�rio de dados - ' + SM0->M0_CODIGO + ' ' + SM0->M0_NOME + ' ...' )
			oProcess:IncRegua2( 'Atualizando campos/�ndices')


			// Alteracao fisica dos arquivos
			__SetX31Mode( .F. )

			If FindFunction(cTCBuild)
				cTopBuild := &cTCBuild.()
			EndIf

			For nX := 1 To Len( aArqUpd )

				If cTopBuild >= '20090811' .AND. TcInternal( 89 ) == 'CLOB_SUPPORTED'
					If ( ( aArqUpd[nX] >= 'NQ ' .AND. aArqUpd[nX] <= 'NZZ' ) .OR. ( aArqUpd[nX] >= 'O0 ' .AND. aArqUpd[nX] <= 'NZZ' ) ) .AND.;
						!aArqUpd[nX] $ 'NQD,NQF,NQP,NQT'
						TcInternal( 25, 'CLOB' )
					EndIf
				EndIf

				If Select( aArqUpd[nX] ) > 0
					dbSelectArea( aArqUpd[nX] )
					dbCloseArea()
				EndIf

				X31UpdTable( aArqUpd[nX] )

				If __GetX31Error()
					Alert( __GetX31Trace() )
					ApMsgStop( 'Ocorreu um erro desconhecido durante a atualiza��o da tabela : ' + aArqUpd[nX] + '. Verifique a integridade do dicion�rio e da tabela.', 'ATEN��O' )
					cTexto += 'Ocorreu um erro desconhecido durante a atualiza��o da estrutura da tabela : ' + aArqUpd[nX] + CRLF
				EndIf

				If cTopBuild >= '20090811' .AND. TcInternal( 89 ) == 'CLOB_SUPPORTED'
					TcInternal( 25, 'OFF' )
				EndIf

			Next nX

			//����������������������������������Ŀ
			//�Atualiza o dicion�rio SX6         �
			//������������������������������������
			oProcess:IncRegua1( 'Dicion�rio de par�metros - ' + SM0->M0_CODIGO + ' ' + SM0->M0_NOME + ' ...' )
			FSAtuSX6( @cTexto )

			//����������������������������������Ŀ
			//�Atualiza o dicion�rio SX7         �
			//������������������������������������
			oProcess:IncRegua1( 'Dicion�rio de gatilhos - ' + SM0->M0_CODIGO + ' ' + SM0->M0_NOME + ' ...' )
			FSAtuSX7( @cTexto )

			//����������������������������������Ŀ
			//�Atualiza o dicion�rio SXA         �
			//������������������������������������
			oProcess:IncRegua1( 'Dicion�rio de pastas - ' + SM0->M0_CODIGO + ' ' + SM0->M0_NOME + ' ...' )
			FSAtuSXA( @cTexto )

			//����������������������������������Ŀ
			//�Atualiza o dicion�rio SXB         �
			//������������������������������������
			oProcess:IncRegua1( 'Dicion�rio de consultas padr�o - ' + SM0->M0_CODIGO + ' ' + SM0->M0_NOME + ' ...' )
			FSAtuSXB( @cTexto )

			//����������������������������������Ŀ
			//�Atualiza o dicion�rio SX5         �
			//������������������������������������
			oProcess:IncRegua1( 'Dicion�rio de tabelas sistema - '  + SM0->M0_CODIGO + ' ' + SM0->M0_NOME + ' ...' )
			FSAtuSX5( @cTexto )

			//����������������������������������Ŀ
			//�Atualiza o dicion�rio SX9         �
			//������������������������������������
			oProcess:IncRegua1( 'Dicion�rio de relacionamentos - '  + SM0->M0_CODIGO + ' ' + SM0->M0_NOME + ' ...' )
			FSAtuSX9( @cTexto )

			//����������������������������������Ŀ
			//�Atualiza os helps                 �
			//������������������������������������
			oProcess:IncRegua1( 'Helps de Campo - '  + SM0->M0_CODIGO + ' ' + SM0->M0_NOME + ' ...' )
			FSAtuHlp( @cTexto )

			RpcClearEnv()

			If !( lOpen := MyOpenSm0Ex() )
				Exit
			EndIf

		Next nI

		If lOpen

			cAux += Replicate( '-', 128 ) + CRLF
			cAux += Replicate( ' ', 128 ) + CRLF
			cAux += 'LOG DA ATUALIZACAO DOS DICION�RIOS' + CRLF
			cAux += Replicate( ' ', 128 ) + CRLF
			cAux += Replicate( '-', 128 ) + CRLF
			cAux += CRLF
			cAux += ' Dados Ambiente'        + CRLF
			cAux += ' --------------------'  + CRLF
			cAux += ' Empresa / Filial...: ' + cEmpAnt + '/' + cFilAnt  + CRLF
			cAux += ' Nome Empresa.......: ' + Capital( AllTrim( GetAdvFVal( 'SM0', 'M0_NOMECOM', cEmpAnt + cFilAnt, 1, '' ) ) ) + CRLF
			cAux += ' Nome Filial........: ' + Capital( AllTrim( GetAdvFVal( 'SM0', 'M0_FILIAL' , cEmpAnt + cFilAnt, 1, '' ) ) ) + CRLF
			cAux += ' DataBase...........: ' + DtoC( dDataBase )  + CRLF
			cAux += ' Data / Hora........: ' + DtoC( Date() ) + ' / ' + Time()  + CRLF
			cAux += ' Environment........: ' + GetEnvServer()  + CRLF
			cAux += ' StartPath..........: ' + GetSrvProfString( 'StartPath', '' )  + CRLF
			cAux += ' RootPath...........: ' + GetSrvProfString( 'RootPath', '' )  + CRLF
			cAux += ' Versao.............: ' + GetVersao(.T.)  + CRLF
			cAux += ' Usuario Microsiga..: ' + __cUserId + ' ' +  cUserName + CRLF
			cAux += ' Computer Name......: ' + GetComputerName()  + CRLF

			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				cAux += ' '  + CRLF
				cAux += ' Dados Thread' + CRLF
				cAux += ' --------------------'  + CRLF
				cAux += ' Usuario da Rede....: ' + aInfo[nPos][1] + CRLF
				cAux += ' Estacao............: ' + aInfo[nPos][2] + CRLF
				cAux += ' Programa Inicial...: ' + aInfo[nPos][5] + CRLF
				cAux += ' Environment........: ' + aInfo[nPos][6] + CRLF
				cAux += ' Conexao............: ' + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), '' ), Chr( 10 ), '' ) )  + CRLF
			EndIf
			cAux += Replicate( '-', 128 ) + CRLF
			cAux += CRLF

			cTexto := cAux + cTexto

			cFileLog := MemoWrite( CriaTrab( , .F. ) + '.log', cTexto )

			Define Font oFont Name 'Mono AS' Size 5, 12

			Define MsDialog oDlg Title 'Atualizacao concluida.' From 3, 0 to 340, 417 Pixel

			@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			oMemo:oFont     := oFont

			Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
			Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, '' ), If( cFile == '', .T., ;
			MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel // Salva e Apaga //'Salvar Como...'

			Activate MsDialog oDlg Center

		EndIf

	EndIf

Else

	lRet := .F.

EndIf

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � FSAtuSX2 � Autor � Microsiga          � Data �  25/07/2011 ���
�������������������������������������������������������������������������͹��
��� Descricao� Funcao de processamento da gravacao do SX2 - Arquivos      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � FSAtuSX2 - Gerado por EXPORDIC / Upd. V.4.01 EFS           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FSAtuSX2( cTexto )
Local aEstrut   := {}
Local aSX2      := {}
Local cAlias    := ''
Local cEmpr     := ''
Local cPath     := ''
Local nI        := 0
Local nJ        := 0

cTexto  += 'Inicio da Atualizacao do SX2' + CRLF + CRLF

aEstrut := { 'X2_CHAVE'  , 'X2_PATH'    , 'X2_ARQUIVO' , 'X2_NOME'    , 'X2_NOMESPA' , 'X2_NOMEENG' , ;
             'X2_ROTINA' , 'X2_MODO'    , 'X2_MODOUN'  , 'X2_MODOEMP' , 'X2_UNICO'   , 'X2_PYME'    , ;
             'X2_MODULO' , 'X2_DISPLAY' ,'X2_SYSOBJ'   , 'X2_USROBJ' }


dbSelectArea( 'SX2' )
SX2->( dbSetOrder( 1 ) )
SX2->( dbGoTop() )
cPath := SX2->X2_PATH
cEmpr := Substr( SX2->X2_ARQUIVO, 4 )

//
// Atualizando dicion�rio
//
oProcess:SetRegua2( Len( aSX2 ) )

dbSelectArea( 'SX2' )
dbSetOrder( 1 )

For nI := 1 To Len( aSX2 )

	oProcess:IncRegua2( 'Atualizando Arquivos (SX2)...')

	If !SX2->( dbSeek( aSX2[nI][1] ) )

		If !( aSX2[nI][1] $ cAlias )
			cAlias += aSX2[nI][1] + '/'
			cTexto += 'Foi inclu�da a tabela ' + aSX2[nI][1] + CRLF
		EndIf

		RecLock( 'SX2', .T. )
		For nJ := 1 To Len( aSX2[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				If AllTrim( aEstrut[nJ] ) == 'X2_ARQUIVO'
					FieldPut( FieldPos( aEstrut[nJ] ), SubStr( aSX2[nI][nJ], 1, 3 ) + cEmpAnt +  '0' )
				Else
					FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
				EndIf
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()

	Else

		If  !( StrTran( Upper( AllTrim( SX2->X2_UNICO ) ), ' ', '' ) == StrTran( Upper( AllTrim( aSX2[nI][12]  ) ), ' ', '' ) )
			If MSFILE( RetSqlName( aSX2[nI][1] ),RetSqlName( aSX2[nI][1] ) + '_UNQ'  )
				TcInternal( 60, RetSqlName( aSX2[nI][1] ) + '|' + RetSqlName( aSX2[nI][1] ) + '_UNQ' )
				cTexto += 'Foi alterada chave unica da tabela ' + aSX2[nI][1] + CRLF
			Else
				cTexto += 'Foi criada   chave unica da tabela ' + aSX2[nI][1] + CRLF
			EndIf
		EndIf

	EndIf

Next nI

cTexto += CRLF + 'Final da Atualizacao do SX2' + CRLF + Replicate( '-', 128 ) + CRLF + CRLF

Return aClone( aSX2 )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � FSAtuSX3 � Autor � Microsiga          � Data �  25/07/2011   ���
�������������������������������������������������������������������������͹��
��� Descricao� Funcao de processamento da gravacao do SX3 - Campos        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � FSAtuSX3 - Gerado por EXPORDIC / Upd. V.4.01 EFS           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FSAtuSX3( cTexto )
Local aEstrut   := {}
Local aSX3      := {}
Local cAlias    := ''
Local cAliasAtu := ''
Local cMsg      := ''
Local cSeqAtu   := ''
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nPosArq   := 0
Local nPosCpo   := 0
Local nPosOrd   := 0
Local nPosSXG   := 0
Local nPosTam   := 0
Local nSeqAtu   := 0
Local nTamSeek  := Len( SX3->X3_CAMPO )

cTexto  += 'Inicio da Atualizacao do SX3' + CRLF + CRLF

aEstrut := { 'X3_ARQUIVO' , 'X3_ORDEM'   , 'X3_CAMPO'  , 'X3_TIPO'    , 'X3_TAMANHO' , 'X3_DECIMAL' , ;
             'X3_TITULO'  , 'X3_TITSPA'  , 'X3_TITENG' , 'X3_DESCRIC' , 'X3_DESCSPA' , 'X3_DESCENG' , ;
             'X3_PICTURE' , 'X3_VALID'   , 'X3_USADO'  , 'X3_RELACAO' , 'X3_F3'      , 'X3_NIVEL'   , ;
             'X3_RESERV'  , 'X3_TRIGGER' , 'X3_PROPRI' , 'X3_BROWSE'  , 'X3_VISUAL'  , 'X3_CONTEXT' , ;
             'X3_OBRIGAT' , 'X3_VLDUSER' , 'X3_CBOX'   , 'X3_CBOXSPA' , 'X3_CBOXENG' , 'X3_PICTVAR' , ;
             'X3_WHEN'    , 'X3_INIBRW'  , 'X3_GRPSXG' , 'X3_FOLDER'  , 'X3_PYME'    , 'X3_IDXSRV'  , ;
             'X3_ORTOGRA' , 'X3_IDXFLD'  , 'X3_TELA'   , 'X3_AGRUP' }

//
// Tabela SC6
//

aAdd( aSX3, { ;
	'SC6'													, ;  // X3_ARQUIVO
	'G2'													, ;  // X3_ORDEM
	'C6_XDESCAL'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	1														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Descalculo'											, ;  // X3_TITULO
	'Descalculo'											, ;  // X3_TITSPA
	'Descalculo'											, ;  // X3_TITENG
	'Faz Descalculo'										, ;  // X3_DESCRIC
	'Faz Descalculo'										, ;  // X3_DESCSPA
	'Faz Descalculo'										, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	'"N"'													, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'A'														, ;  // X3_VISUAL
	'R'														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	'Pertence("SN").and.U_RFATA023()'					, ;  // X3_VLDUSER
	'S=Sim;N=Nao'											, ;  // X3_CBOX
	'S=Sim;N=Nao'											, ;  // X3_CBOXSPA
	'S=Sim;N=Nao'											, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'SC6'													, ;  // X3_ARQUIVO
	'G3'													, ;  // X3_ORDEM
	'C6_XPRCORI'											, ;  // X3_CAMPO
	'N'														, ;  // X3_TIPO
	18														, ;  // X3_TAMANHO
	5														, ;  // X3_DECIMAL
	'Prc.Orig.Ven'										, ;  // X3_TITULO
	'Prc.Orig.Ven'										, ;  // X3_TITSPA
	'Prc.Orig.Ven'										, ;  // X3_TITENG
	'Preco Original de Venda'							, ;  // X3_DESCRIC
	'Preco Original de Venda'							, ;  // X3_DESCSPA
	'Preco Original de Venda'							, ;  // X3_DESCENG
	'@E 999,999,999,999.99999'							, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'S'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	'R'														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'SC6'													, ;  // X3_ARQUIVO
	'G4'													, ;  // X3_ORDEM
	'C6_XUSUARI'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	20														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Nome Usuario'										, ;  // X3_TITULO
	'Nome Usuario'										, ;  // X3_TITSPA
	'Nome Usuario'										, ;  // X3_TITENG
	'Nome do Usuario'										, ;  // X3_DESCRIC
	'Nome do Usuario'										, ;  // X3_DESCSPA
	'Nome do Usuario'										, ;  // X3_DESCENG
	'@!'													, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	'R'														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'SC6'													, ;  // X3_ARQUIVO
	'G5'													, ;  // X3_ORDEM
	'C6_XDTDESC'											, ;  // X3_CAMPO
	'D'														, ;  // X3_TIPO
	8														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Dt. Descalc'											, ;  // X3_TITULO
	'Dt. Descalc'											, ;  // X3_TITSPA
	'Dt. Descalc'											, ;  // X3_TITENG
	'Data do Descalculo'									, ;  // X3_DESCRIC
	'Data do Descalculo'									, ;  // X3_DESCSPA
	'Data do Descalculo'									, ;  // X3_DESCENG
	''														, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	'R'														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

aAdd( aSX3, { ;
	'SC6'													, ;  // X3_ARQUIVO
	'G6'													, ;  // X3_ORDEM
	'C6_XHRDESC'											, ;  // X3_CAMPO
	'C'														, ;  // X3_TIPO
	8														, ;  // X3_TAMANHO
	0														, ;  // X3_DECIMAL
	'Hr. Descalcu'										, ;  // X3_TITULO
	'Hr. Descalcu'										, ;  // X3_TITSPA
	'Hr. Descalcu'										, ;  // X3_TITENG
	'Hora do Descalculo'									, ;  // X3_DESCRIC
	'Hora do Descalculo'									, ;  // X3_DESCSPA
	'Hora do Descalculo'									, ;  // X3_DESCENG
	''														, ;  // X3_PICTURE
	''														, ;  // X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) 		, ;  // X3_USADO
	''														, ;  // X3_RELACAO
	''														, ;  // X3_F3
	1														, ;  // X3_NIVEL
	Chr(254) + Chr(192)									, ;  // X3_RESERV
	''														, ;  // X3_TRIGGER
	'U'														, ;  // X3_PROPRI
	'N'														, ;  // X3_BROWSE
	'V'														, ;  // X3_VISUAL
	'R'														, ;  // X3_CONTEXT
	''														, ;  // X3_OBRIGAT
	''														, ;  // X3_VLDUSER
	''														, ;  // X3_CBOX
	''														, ;  // X3_CBOXSPA
	''														, ;  // X3_CBOXENG
	''														, ;  // X3_PICTVAR
	''														, ;  // X3_WHEN
	''														, ;  // X3_INIBRW
	''														, ;  // X3_GRPSXG
	''														, ;  // X3_FOLDER
	'S'														, ;  // X3_PYME
	'N'														, ;  // X3_IDXSRV
	'N'														, ;  // X3_ORTOGRA
	'N'														, ;  // X3_IDXFLD
	''														, ;  // X3_TELA
	''														} )  // X3_AGRUP

//
// Atualizando dicion�rio
//

nPosArq := aScan( aEstrut, { |x| AllTrim( x ) == 'X3_ARQUIVO' } )
nPosOrd := aScan( aEstrut, { |x| AllTrim( x ) == 'X3_ORDEM'   } )
nPosCpo := aScan( aEstrut, { |x| AllTrim( x ) == 'X3_CAMPO'   } )
nPosTam := aScan( aEstrut, { |x| AllTrim( x ) == 'X3_TAMANHO' } )
nPosSXG := aScan( aEstrut, { |x| AllTrim( x ) == 'X3_GRPSXG'  } )

aSort( aSX3,,, { |x,y| x[nPosArq]+x[nPosOrd]+x[nPosCpo] < y[nPosArq]+y[nPosOrd]+y[nPosCpo] } )

oProcess:SetRegua2( Len( aSX3 ) )

dbSelectArea( 'SX3' )
dbSetOrder( 2 )
cAliasAtu := ''

For nI := 1 To Len( aSX3 )

	//
	// Verifica se o campo faz parte de um grupo e ajsuta tamanho
	//
	If !Empty( aSX3[nI][nPosSXG] )
		SXG->( dbSetOrder( 1 ) )
		If SXG->( MSSeek( aSX3[nI][nPosSXG] ) )
			If aSX3[nI][nPosTam] <> SXG->XG_SIZE
				aSX3[nI][nPosTam] := SXG->XG_SIZE
				cTexto += 'O tamanho do campo ' + aSX3[nI][nPosCpo] + ' nao atualizado e foi mantido em ['
				cTexto += AllTrim( Str( SXG->XG_SIZE ) ) + ']'+ CRLF
				cTexto += '   por pertencer ao grupo de campos [' + SX3->X3_GRPSXG + ']' + CRLF + CRLF
			EndIf
		EndIf
	EndIf

	SX3->( dbSetOrder( 2 ) )

	If !( aSX3[nI][nPosArq] $ cAlias )
		cAlias += aSX3[nI][nPosArq] + '/'
		aAdd( aArqUpd, aSX3[nI][nPosArq] )
	EndIf

	If !SX3->( dbSeek( PadR( aSX3[nI][nPosCpo], nTamSeek ) ) )

		//
		// Busca ultima ocorrencia do alias
		//
		If ( aSX3[nI][nPosArq] <> cAliasAtu )
			cSeqAtu   := '00'
			cAliasAtu := aSX3[nI][nPosArq]

			dbSetOrder( 1 )
			SX3->( dbSeek( cAliasAtu + 'ZZ', .T. ) )
			dbSkip( -1 )

			If ( SX3->X3_ARQUIVO == cAliasAtu )
				cSeqAtu := SX3->X3_ORDEM
			EndIf

			nSeqAtu := Val( RetAsc( cSeqAtu, 3, .F. ) )
		EndIf

		nSeqAtu++
		cSeqAtu := RetAsc( Str( nSeqAtu ), 2, .T. )

		RecLock( 'SX3', .T. )
		For nJ := 1 To Len( aSX3[nI] )
			If     nJ == 2    // Ordem
				FieldPut( FieldPos( aEstrut[nJ] ), cSeqAtu )

			ElseIf FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX3[nI][nJ] )

			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		cTexto += 'Criado o campo ' + aSX3[nI][nPosCpo] + CRLF

	Else

		//
		// Verifica se o campo faz parte de um grupo e ajsuta tamanho
		//
		If !Empty( SX3->X3_GRPSXG ) .AND. SX3->X3_GRPSXG <> aSX3[nI][nPosSXG]
			SXG->( dbSetOrder( 1 ) )
			If SXG->( MSSeek( SX3->X3_GRPSXG ) )
				If aSX3[nI][nPosTam] <> SXG->XG_SIZE
					aSX3[nI][nPosTam] := SXG->XG_SIZE
					cTexto += 'O tamanho do campo ' + aSX3[nI][nPosCpo] + ' nao atualizado e foi mantido em ['
					cTexto += AllTrim( Str( SXG->XG_SIZE ) ) + ']'+ CRLF
					cTexto += '   por pertencer ao grupo de campos [' + SX3->X3_GRPSXG + ']' + CRLF + CRLF
				EndIf
			EndIf
		EndIf

		//
		// Verifica todos os campos
		//
		For nJ := 1 To Len( aSX3[nI] )

			//
			// Se o campo estiver diferente da estrutura
			//
			If aEstrut[nJ] == SX3->( FieldName( nJ ) ) .AND. ;
				PadR( StrTran( AllToChar( SX3->( FieldGet( nJ ) ) ), ' ', '' ), 250 ) <> ;
				PadR( StrTran( AllToChar( aSX3[nI][nJ] )           , ' ', '' ), 250 ) .AND. ;
				AllTrim( SX3->( FieldName( nJ ) ) ) <> 'X3_ORDEM'

				cMsg := 'O campo ' + aSX3[nI][nPosCpo] + ' est� com o ' + SX3->( FieldName( nJ ) ) + ;
				' com o conte�do' + CRLF + ;
				'[' + RTrim( AllToChar( SX3->( FieldGet( nJ ) ) ) ) + ']' + CRLF + ;
				'que ser� substituido pelo NOVO conte�do' + CRLF + ;
				'[' + RTrim( AllToChar( aSX3[nI][nJ] ) ) + ']' + CRLF + ;
				'Deseja substituir ? '

				If      lTodosSim
					nOpcA := 1
				ElseIf  lTodosNao
					nOpcA := 2
				Else
					nOpcA := Aviso( 'ATUALIZA��O DE DICION�RIOS E TABELAS', cMsg, { 'Sim', 'N�o', 'Sim p/Todos', 'N�o p/Todos' }, 3,'Diferen�a de conte�do - SX3' )
					lTodosSim := ( nOpcA == 3 )
					lTodosNao := ( nOpcA == 4 )

					If lTodosSim
						nOpcA := 1
						lTodosSim := ApMsgNoYes( 'Foi selecionada a op��o de REALIZAR TODAS altera��es no SX3 e N�O MOSTRAR mais a tela de aviso.' + CRLF + 'Confirma a a��o [Sim p/Todos] ?' )
					EndIf

					If lTodosNao
						nOpcA := 2
						lTodosNao := ApMsgNoYes( 'Foi selecionada a op��o de N�O REALIZAR nenhuma altera��o no SX3 que esteja diferente da base e N�O MOSTRAR mais a tela de aviso.' + CRLF + 'Confirma esta a��o [N�o p/Todos]?' )
					EndIf

				EndIf

				If nOpcA == 1
					cTexto += 'Alterado o campo ' + aSX3[nI][nPosCpo] + CRLF
					cTexto += '   ' + PadR( SX3->( FieldName( nJ ) ), 10 ) + ' de [' + AllToChar( SX3->( FieldGet( nJ ) ) ) + ']' + CRLF
					cTexto += '            para [' + AllToChar( aSX3[nI][nJ] )          + ']' + CRLF + CRLF

					RecLock( 'SX3', .F. )
					FieldPut( FieldPos( aEstrut[nJ] ), aSX3[nI][nJ] )
					dbCommit()
					MsUnLock()

				EndIf

			EndIf

		Next

	EndIf

	oProcess:IncRegua2( 'Atualizando Campos de Tabelas (SX3)...' )

Next nI

cTexto += CRLF + 'Final da Atualizacao do SX3' + CRLF + Replicate( '-', 128 ) + CRLF + CRLF

Return aClone( aSX3 )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � FSAtuSIX � Autor � Microsiga          � Data �  25/07/2011 ���
�������������������������������������������������������������������������͹��
��� Descricao� Funcao de processamento da gravacao do SIX - Indices       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � FSAtuSIX - Gerado por EXPORDIC / Upd. V.4.01 EFS           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FSAtuSIX( cTexto )
Local aEstrut   := {}
Local aSIX      := {}
Local lAlt      := .F.
Local lDelInd   := .F.
Local nI        := 0
Local nJ        := 0

cTexto  += 'Inicio da Atualizacao do SIX' + CRLF + CRLF

aEstrut := { 'INDICE'  , 'ORDEM'  , 'CHAVE' , 'DESCRICAO' , 'DESCSPA'  , ;
             'DESCENG' , 'PROPRI' , 'F3'    , 'NICKNAME'  , 'SHOWPESQ' }   


//
// Atualizando dicion�rio
//
oProcess:SetRegua2( Len( aSIX ) )

dbSelectArea( 'SIX' )
SIX->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSIX )

	lAlt := .F.

	If !SIX->( dbSeek( aSIX[nI][1] + aSIX[nI][2] ) )
		RecLock( 'SIX', .T. )
		lDelInd := .F.
		cTexto += '�ndice criado ' + aSIX[nI][1] + '/' + aSIX[nI][2] + ' - ' + aSIX[nI][3] + CRLF
	Else
		lAlt := .F.
		RecLock( 'SIX', .F. )
	EndIf

	If !StrTran( Upper( AllTrim( CHAVE )       ), ' ', '') == ;
	    StrTran( Upper( AllTrim( aSIX[nI][3] ) ), ' ', '' )
		aAdd( aArqUpd, aSIX[nI][1] )

		If lAlt
			lDelInd := .T.  // Se for alteracao precisa apagar o indice do banco
			cTexto += '�ndice alterado ' + aSIX[nI][1] + '/' + aSIX[nI][2] + ' - ' + aSIX[nI][3] + CRLF
		EndIf

		For nJ := 1 To Len( aSIX[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSIX[nI][nJ] )
			EndIf
		Next nJ

		If lDelInd
			TcInternal( 60, RetSqlName( aSIX[nI][1] ) + '|' + RetSqlName( aSIX[nI][1] ) + aSIX[nI][2] ) // Exclui sem precisar baixar o TOP
		EndIf

	EndIf

	dbCommit()
	MsUnLock()

	oProcess:IncRegua2( 'Atualizando �ndices...' )

Next nI

cTexto += CRLF + 'Final da Atualizacao do SIX' + CRLF + Replicate( '-', 128 ) + CRLF + CRLF

Return aClone( aSIX )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � FSAtuSX6 � Autor � Microsiga          � Data �  25/07/2011 ���
�������������������������������������������������������������������������͹��
��� Descricao� Funcao de processamento da gravacao do SX6 - Par�metros    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � FSAtuSX6 - Gerado por EXPORDIC / Upd. V.4.01 EFS           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FSAtuSX6( cTexto )
Local aEstrut   := {}
Local aSX6      := {}
Local cAlias    := ''
Local cMsg      := ''
Local lContinua := .T.
Local lReclock  := .T.
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nTamFil   := Len( SX6->X6_FIL )
Local nTamVar   := Len( SX6->X6_VAR )

cTexto  += 'Inicio da Atualizacao do SX6' + CRLF + CRLF

aEstrut := { 'X6_FIL'    , 'X6_VAR'  , 'X6_TIPO'   , 'X6_DESCRIC', 'X6_DSCSPA' , 'X6_DSCENG' , 'X6_DESC1'  , 'X6_DSCSPA1',;
             'X6_DSCENG1', 'X6_DESC2', 'X6_DSCSPA2', 'X6_DSCENG2', 'X6_CONTEUD', 'X6_CONTSPA', 'X6_CONTENG', 'X6_PROPRI' , 'X6_PYME' }

//
// Atualizando dicion�rio
//
oProcess:SetRegua2( Len( aSX6 ) )

dbSelectArea( "SX6" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX6 )
	lContinua := .F.
	lReclock  := .F.

	If !SX6->( dbSeek( PadR( aSX6[nI][1], nTamFil ) + PadR( aSX6[nI][2], nTamVar ) ) )
		lContinua := .T.
		lReclock  := .T.
		cTexto += "Foi inclu�do o par�metro " + aSX6[nI][1] + aSX6[nI][2] + " Conte�do [" + AllTrim( aSX6[nI][13] ) + "]"+ CRLF
	EndIf

	If lContinua
		If !( aSX6[nI][1] $ cAlias )
			cAlias += aSX6[nI][1] + "/"
		EndIf

		RecLock( "SX6", lReclock )
		For nJ := 1 To Len( aSX6[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX6[nI][nJ] )
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()
	EndIf

	oProcess:IncRegua2( "Atualizando Arquivos (SX6)..." )

Next nI

cTexto += CRLF + "Final da Atualizacao" + " SX6" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return aClone( aSX6 )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � FSAtuSX7 � Autor � Microsiga          � Data �  25/07/2011   ���
�������������������������������������������������������������������������͹��
��� Descricao� Funcao de processamento da gravacao do SX7 - Gatilhos      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � FSAtuSX7 - Gerado por EXPORDIC / Upd. V.4.01 EFS           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FSAtuSX7( cTexto )
Local aEstrut   := {}
Local aSX7      := {}
Local cAlias    := ''
Local nI        := 0
Local nJ        := 0
Local nTamSeek  := Len( SX7->X7_CAMPO )

cTexto  += 'Inicio da Atualizacao do SX7' + CRLF + CRLF

aEstrut := { 'X7_CAMPO', 'X7_SEQUENC', 'X7_REGRA', 'X7_CDOMIN', 'X7_TIPO', 'X7_SEEK', ;
             'X7_ALIAS', 'X7_ORDEM'  , 'X7_CHAVE', 'X7_PROPRI', 'X7_CONDIC' }

//
// Atualizando dicion�rio
//

oProcess:SetRegua2( Len( aSX7 ) )

dbSelectArea( "SX7" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX7 )

	If !SX7->( dbSeek( PadR( aSX7[nI][1], nTamSeek ) + aSX7[nI][2] ) )

		If !( aSX7[nI][1] $ cAlias )
			cAlias += aSX7[nI][1] + "/"
			cTexto += "Foi inclu�do o gatilho " + aSX7[nI][1] + "/" + aSX7[nI][2] + CRLF
		EndIf

		RecLock( "SX7", .T. )
		For nJ := 1 To Len( aSX7[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX7[nI][nJ] )
			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

	EndIf
	oProcess:IncRegua2( "Atualizando Arquivos (SX7)..." )

Next nI

cTexto += CRLF + 'Final da Atualizacao do SX7' + CRLF + Replicate( '-', 128 ) + CRLF + CRLF

Return aClone( aSX7 )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � FSAtuSXA � Autor � Microsiga          � Data �  25/07/2011   ���
�������������������������������������������������������������������������͹��
��� Descricao� Funcao de processamento da gravacao do SXA - Pastas        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � FSAtuSXA - Gerado por EXPORDIC / Upd. V.4.01 EFS           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FSAtuSXA( cTexto )
Local aEstrut   := {}
Local aSXA      := {}
Local cAlias    := ''
Local nI        := 0
Local nJ        := 0

cTexto  += 'Inicio da Atualizacao do SXA' + CRLF + CRLF

aEstrut := { 'XA_ALIAS', 'XA_ORDEM', 'XA_DESCRIC', 'XA_DESCSPA', 'XA_DESCENG', 'XA_PROPRI' }

cTexto += CRLF + 'Final da Atualizacao do SXA' + CRLF + Replicate( '-', 128 ) + CRLF + CRLF

Return aClone( aSXA )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � FSAtuSXB � Autor � Microsiga          � Data �  25/07/2011 ���
�������������������������������������������������������������������������͹��
��� Descricao� Funcao de processamento da gravacao do SXB - Consultas Pad ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � FSAtuSXB - Gerado por EXPORDIC / Upd. V.4.01 EFS           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FSAtuSXB( cTexto )
Local aEstrut   := {}
Local aSXB      := {}
Local cAlias    := ''
Local cMsg      := ''
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0

cTexto  += 'Inicio da Atualizacao do SXB' + CRLF + CRLF

aEstrut := { 'XB_ALIAS',  'XB_TIPO'   , 'XB_SEQ'    , 'XB_COLUNA' , ;
             'XB_DESCRI', 'XB_DESCSPA', 'XB_DESCENG', 'XB_CONTEM' }


//
// Atualizando dicion�rio
//

oProcess:SetRegua2( Len( aSXB ) )

dbSelectArea( "SXB" )
dbSetOrder( 1 )

For nI := 1 To Len( aSXB )

	If !Empty( aSXB[nI][1] )

		If !SXB->( dbSeek( PadR( aSXB[nI][1], Len( SXB->XB_ALIAS ) ) + aSXB[nI][2] + aSXB[nI][3] + aSXB[nI][4] ) )

			If !( aSXB[nI][1] $ cAlias )
				cAlias += aSXB[nI][1] + "/"
				cTexto += "Foi inclu�da a consulta padr�o " + aSXB[nI][1] + CRLF
			EndIf

			RecLock( "SXB", .T. )

			For nJ := 1 To Len( aSXB[nI] )
				If !Empty( FieldName( FieldPos( aEstrut[nJ] ) ) )
					FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
				EndIf
			Next nJ

			dbCommit()
			MsUnLock()

		Else

			//
			// Verifica todos os campos
			//
			For nJ := 1 To Len( aSXB[nI] )

				//
				// Se o campo estiver diferente da estrutura
				//
				If aEstrut[nJ] == SXB->( FieldName( nJ ) ) .AND. ;
					!StrTran( AllToChar( SXB->( FieldGet( nJ ) ) ), " ", "" ) == ;
					 StrTran( AllToChar( aSXB[nI][nJ]            ), " ", "" )

					cMsg := "A consulta padrao " + aSXB[nI][1] + " est� com o " + SXB->( FieldName( nJ ) ) + ;
					" com o conte�do" + CRLF + ;
					"[" + RTrim( AllToChar( SXB->( FieldGet( nJ ) ) ) ) + "]" + CRLF + ;
					", e este � diferente do conte�do" + CRLF + ;
					"[" + RTrim( AllToChar( aSXB[nI][nJ] ) ) + "]" + CRLF +;
					"Deseja substituir ? "

					If      lTodosSim
						nOpcA := 1
					ElseIf  lTodosNao
						nOpcA := 2
					Else
						nOpcA := Aviso( "ATUALIZA��O DE DICION�RIOS E TABELAS", cMsg, { "Sim", "N�o", "Sim p/Todos", "N�o p/Todos" }, 3, "Diferen�a de conte�do - SXB" )
						lTodosSim := ( nOpcA == 3 )
						lTodosNao := ( nOpcA == 4 )

						If lTodosSim
							nOpcA := 1
							lTodosSim := MsgNoYes( "Foi selecionada a op��o de REALIZAR TODAS altera��es no SXB e N�O MOSTRAR mais a tela de aviso." + CRLF + "Confirma a a��o [Sim p/Todos] ?" )
						EndIf

						If lTodosNao
							nOpcA := 2
							lTodosNao := MsgNoYes( "Foi selecionada a op��o de N�O REALIZAR nenhuma altera��o no SXB que esteja diferente da base e N�O MOSTRAR mais a tela de aviso." + CRLF + "Confirma esta a��o [N�o p/Todos]?" )
						EndIf

					EndIf

					If nOpcA == 1
						RecLock( "SXB", .F. )
						FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
						dbCommit()
						MsUnLock()

						If !( aSXB[nI][1] $ cAlias )
							cAlias += aSXB[nI][1] + "/"
							cTexto += "Foi Alterada a consulta padrao " + aSXB[nI][1] + CRLF
						EndIf

					EndIf

				EndIf

			Next

		EndIf

	EndIf

	oProcess:IncRegua2( "Atualizando Consultas Padroes (SXB)..." )

Next nI

cTexto += CRLF + 'Final da Atualizacao do SXB' + CRLF + Replicate( '-', 128 ) + CRLF + CRLF

Return aClone( aSXB )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � FSAtuSX5 � Autor � Microsiga          � Data �  25/07/2011 ���
�������������������������������������������������������������������������͹��
��� Descricao� Funcao de processamento da gravacao do SX5 - Indices       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � FSAtuSX5 - Gerado por EXPORDIC / Upd. V.4.01 EFS           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FSAtuSX5( cTexto )
Local aEstrut   := {}
Local aSX5      := {}
Local cAlias    := ''
Local nI        := 0
Local nJ        := 0

cTexto  += 'Inicio Atualizacao SX5' + CRLF + CRLF

aEstrut := { 'X5_FILIAL', 'X5_TABELA', 'X5_CHAVE', 'X5_DESCRI', 'X5_DESCSPA', 'X5_DESCENG' }

//
// Atualizando dicion�rio
//

cTexto += CRLF + 'Final da Atualizacao do SX5' + CRLF + Replicate( '-', 128 ) + CRLF + CRLF

Return aClone( aSX5 )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � FSAtuSX9 � Autor � Microsiga          � Data �  25/07/2011 ���
�������������������������������������������������������������������������͹��
��� Descricao� Funcao de processamento da gravacao do SX9 - Relacionament ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � FSAtuSX9 - Gerado por EXPORDIC / Upd. V.4.01 EFS           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FSAtuSX9( cTexto )
Local aEstrut   := {}
Local aSX9      := {}
Local cAlias    := ''
Local nI        := 0
Local nJ        := 0
Local nTamSeek  := Len( SX9->X9_DOM )

cTexto  += 'Inicio da Atualizacao do SX9' + CRLF + CRLF

aEstrut := { 'X9_DOM'   , 'X9_IDENT'  , 'X9_CDOM'   , 'X9_EXPDOM', 'X9_EXPCDOM' ,'X9_PROPRI', ;
             'X9_LIGDOM', 'X9_LIGCDOM', 'X9_CONDSQL', 'X9_USEFIL', 'X9_ENABLE' }

cTexto += CRLF + 'Final da Atualizacao do SX9' + CRLF + Replicate( '-', 128 ) + CRLF + CRLF

Return aClone( aSX9 )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � FSAtuHlp � Autor � Microsiga          � Data �  25/07/2011 ���
�������������������������������������������������������������������������͹��
��� Descricao� Funcao de processamento da gravacao dos Helps de Campos    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � FSAtuHlp - Gerado por EXPORDIC / Upd. V.4.01 EFS           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FSAtuHlp( cTexto )
Local aHelpPor := {}
Local aHelpEng := {}
Local aHelpSpa := {}

cTexto += 'Inicio da Atualizacao ds Helps de Campos' + CRLF + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "Se realiza o desc�lculo." )
aAdd( aHlpEng, "Se realiza o desc�lculo." )
aAdd( aHlpSpa, "Se realiza o desc�lculo." )
PutHelp( "PC6_XDESCAL", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C6_XDESCAL" + CRLF

aHlpPor := {}
aHlpEng := {}
aHlpSpa := {}
aAdd( aHlpPor, "Pre�o unit�rio original." )
aAdd( aHlpEng, "Pre�o unit�rio original." )
aAdd( aHlpSpa, "Pre�o unit�rio original." )
PutHelp( "PC6_XPRCORI", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "C6_XPRCORI" + CRLF

cTexto += CRLF + 'Final da Atualizacao dos Helps de Campos' + CRLF + Replicate( '-', 128 ) + CRLF + CRLF

Return {}

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Rotina    �ESCEMPRESA�Autor  � Ernani Forastieri  � Data �  27/09/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Funcao Generica para escolha de Empresa, montado pelo SM0_ ���
���          � Retorna vetor contendo as selecoes feitas.                 ���
���          � Se nao For marcada nenhuma o vetor volta vazio.            ���
�������������������������������������������������������������������������͹��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function EscEmpresa()
//��������������������������������������������Ŀ
//� Parametro  nTipo                           �
//� 1  - Monta com Todas Empresas/Filiais      �
//� 2  - Monta so com Empresas                 �
//� 3  - Monta so com Filiais de uma Empresa   �
//�                                            �
//� Parametro  aMarcadas                       �
//� Vetor com Empresas/Filiais pre marcadas    �
//�                                            �
//� Parametro  cEmpSel                         �
//� Empresa que sera usada para montar selecao �
//����������������������������������������������
Local   aSalvAmb := GetArea()
Local   aSalvSM0 := {}
Local   aRet     := {}
Local   aVetor   := {}
Local   oDlg     := NIL
Local   oChkMar  := NIL
Local   oLbx     := NIL
Local   oMascEmp := NIL
Local   oMascFil := NIL
Local   oButMarc := NIL
Local   oButDMar := NIL
Local   oButInv  := NIL
Local   oSay     := NIL
Local   oOk      := LoadBitmap( GetResources(), 'LBOK' )
Local   oNo      := LoadBitmap( GetResources(), 'LBNO' )
Local   lChk     := .F.
Local   lOk      := .F.
Local   lTeveMarc:= .F.
Local   cVar     := ''
Local   cNomEmp  := ''
Local   cMascEmp := '??'
Local   cMascFil := '??'

Local   aMarcadas  := {}


If !MyOpenSm0Ex()
	ApMsgStop( 'N�o foi poss�vel abrir SM0 exclusivo.' )
	Return aRet
EndIf


dbSelectArea( 'SM0' )
aSalvSM0 := SM0->( GetArea() )
dbSetOrder( 1 )
dbGoTop()

While !SM0->( EOF() )

	If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0
		aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
	EndIf

	dbSkip()
End

RestArea( aSalvSM0 )

Define MSDialog  oDlg Title '' From 0, 0 To 270, 396 Pixel

oDlg:cToolTip := 'Tela para M�ltiplas Sele��es de Empresas/Filiais'

oDlg:cTitle := 'Selecione a(s) Empresa(s) para Atualiza��o'

@ 10, 10 Listbox  oLbx Var  cVar Fields Header ' ', ' ', 'Empresa' Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 112, 10 CheckBox oChkMar Var  lChk Prompt 'Todos'   Message 'Marca / Desmarca Todos' Size 40, 007 Pixel Of oDlg;
on Click MarcaTodos( lChk, @aVetor, oLbx )

@ 123, 10 Button oButInv Prompt '&Inverter'  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message 'Inverter Sele��o' Of oDlg

// Marca/Desmarca por mascara
@ 113, 51 Say  oSay Prompt 'Empresa' Size  40, 08 Of oDlg Pixel
@ 112, 80 MSGet  oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture '@!'  Valid (  cMascEmp := StrTran( cMascEmp, ' ', '?' ), cMascFil := StrTran( cMascFil, ' ', '?' ), oMascEmp:Refresh(), .T. ) ;
Message 'M�scara Empresa ( ?? )'  Of oDlg
@ 123, 50 Button oButMarc Prompt '&Marcar'    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message 'Marcar usando m�scara ( ?? )'    Of oDlg
@ 123, 80 Button oButDMar Prompt '&Desmarcar' Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message 'Desmarcar usando m�scara ( ?? )' Of oDlg

Define SButton From 111, 125 Type 1 Action ( RetSelecao( @aRet, aVetor ), oDlg:End() ) OnStop 'Confirma a Sele��o'  Enable Of oDlg
Define SButton From 111, 158 Type 2 Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) OnStop 'Abandona a Sele��o' Enable Of oDlg
Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
dbSelectArea( 'SM0' )
dbCloseArea()

Return  aRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Rotina    �MARCATODOS�Autor  � Ernani Forastieri  � Data �  27/09/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Funcao Auxiliar para marcar/desmarcar todos os itens do    ���
���          � ListBox ativo                                              ���
�������������������������������������������������������������������������͹��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()

Return NIL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Rotina    �INVSELECAO�Autor  � Ernani Forastieri  � Data �  27/09/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Funcao Auxiliar para inverter selecao do ListBox Ativo     ���
�������������������������������������������������������������������������͹��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function InvSelecao( aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()

Return NIL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Rotina    �RETSELECAO�Autor  � Ernani Forastieri  � Data �  27/09/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Funcao Auxiliar que monta o retorno com as selecoes        ���
�������������������������������������������������������������������������͹��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function RetSelecao( aRet, aVetor )
Local  nI    := 0

aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
	EndIf
Next nI

Return NIL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Rotina    � MARCAMAS �Autor  � Ernani Forastieri  � Data �  20/11/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Funcao para marcar/desmarcar usando mascaras               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0

For nZ := 1 To Len( aVetor )
	If cPos1 == '?' .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
		If cPos2 == '?' .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
			aVetor[nZ][1] :=  lMarDes
		EndIf
	EndIf
Next

oLbx:nAt := nPos
oLbx:Refresh()

Return NIL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Rotina    � VERTODOS �Autor  � Ernani Forastieri  � Data �  20/11/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Funcao auxiliar para verificar se estao todos marcardos    ���
���          � ou nao                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � MyOpenSM � Autor � Microsiga          � Data �  25/07/2011   ���
�������������������������������������������������������������������������͹��
��� Descricao� Funcao de processamento abertura do SM0 modo exclusivo     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � MyOpenSM - Gerado por EXPORDIC / Upd. V.4.01 EFS           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MyOpenSM0Ex()

Local lOpen := .F.
Local nLoop := 0

For nLoop := 1 To 20
	dbUseArea( .T., , 'SIGAMAT.EMP', 'SM0', .F., .F. )

	If !Empty( Select( 'SM0' ) )
		lOpen := .T.
		dbSetIndex( 'SIGAMAT.IND' )
		Exit
	EndIf

	Sleep( 500 )

Next nLoop

If !lOpen
	ApMsgStop( 'N�o foi poss�vel a abertura da tabela ' + ;
		'de empresas de forma exclusiva.', 'ATEN��O' )
EndIf

Return lOpen