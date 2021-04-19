#include 'protheus.ch'



//-------------------------------------------------------------------
/*/{Protheus.doc} F460E5
Tratamento do t�tulo na Liquida��o 
Utilizado para retirar as informa��es de fatura pela rotina de 
liquida��o.
@author  ERPSERV
@since   13/03/2019
@version 1.0
/*/
//-------------------------------------------------------------------
user function F460E5()



        Reclock("SE1", .F.)
        SE1->E1_TIPOFAT  := ""
        SE1->E1_DTFATUR := stod("")
        SE1->E1_FATPREF:= ""
        SE1->E1_FATURA := ""
        SE1->(msUnlock())
    


return