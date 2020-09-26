#include 'PROTHEUS.CH' 

/*/{Protheus.doc} REST0002
    Cosnulta o Cnpj na receita 
    Pode ser implementado atrves de gatilho no protheus
    *Free: A Receita permite apenas 3 consultas por minuto e 100 no m
    @type  Function
    @author Francisco Rosa Neto
    @since 25/09/2020
    @version 1.0

Fonte de Inspiração https://userfunction.com.br/   Servidor REST

A Finalidade de desse é apenas para estudo.

    /*/

User function REST0002(cCNPJ)

    Local cUrl  := 'https://www.receitaws.com.br'
    Local cPath := '/v1/cnpj/' + cCNPJ
    Local oJson := JsonObject():New()
    Local oRest, cJson, cCodMun, cMun

    If Len(cCNPJ) == 14

        oRest := FwRest():New(cUrl)

        oRest:setPath(cPath)

        If oRest:get()
            cJson := DecodeUtf8(oRest:GetResult())

            oJson:FromJson(cJson)

            If oJson['situacao'] == "ATIVA" .AND. oJson['status'] == "OK"

            FWFldPut("A2_NOME"   , oJson['nome']                                                                                                                         )
            FWFldPut("A2_NREDUZ" , Iif(oJson['fantasia'] == '', SubStr(oJson['nome'], 1, TamSX3("A2_NREDUZ")[1]),  SubStr(oJson['fantasia'], 1, TamSX3("A2_NREDUZ")[1])) )
            FWFldPut("A2_END"    , oJson['logradouro'] + ", "+ oJson['numero']                                                                                           )            
            FWFldPut("A2_COMPLEM", SubStr(oJson['complemento'], 1, TamSX3("A2_COMPLEM")[1])                                                                              )        
            FWFldPut("A2_BAIRRO" , oJson['bairro']                                                                                                                       )    
            FWFldPut("A2_CEP"    , removePontos(oJson['cep'])                                                                                                            )
            FWFldPut("A2_EST"    , oJson['uf']                                                                                                                           )
            
            cCodMun := POSICIONE("CC2", 4, xFilial("CC2")+oJson['uf']+oJson['municipio'], "CC2_CODMUN" )
            //   FWFldPut(<cCampo >, <xConteudo >, [ nLinha ], [ oModel ], [ lShowMsg ], [ lLoad ])-> lRet
                                                                                                                            
            FWFldPut("A2_COD_MUN", cCodMun,,,,.T.                                                                                                                      )

            cMun := AllTrim(POSICIONE("CC2", 4, xFilial("CC2")+oJson['uf']+oJson['municipio'], "CC2_MUN" ))

            FWFldPut("A2_MUN"    ,cMun ,,,,.T.                                                                                                                        )
            FWFldPut("A2_EMAIL"  , oJson['email']                                                                                                                        )
            


            Else
                MsgAlert("Empresa "+ oJson['situacao'])

            EndIf
        Else
            MsgAlert(oRest:GetLastError())

        EndIf
    EndIf
Return &(ReadVar())

Static Function removePontos(cTexto)
    cTexto := StrTran(cTexto, "-", "")
    cTexto := StrTran(cTexto, ".", "")
    cTexto := StrTran(cTexto, ",", "")
    cTexto := StrTran(cTexto, " ", "")
Return cTexto
