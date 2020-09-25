#INCLUDE 'totvs.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TBICONN.CH"


/*/{Protheus.doc} fRiscoSacado
    (long_description)
    @type  Function
    @author Francisco Rosa Neto
    @since 25/09/2020
    @version 1.0
    @param , , 
    @return Nil, 
    @(Criar planilha excel CSV para RISCO Sacado a parti do contas a pagar)
    /*/
User Function fRiscoSacado()

Private aCpoInfo    := {}
Private aCampos     := {}
Private aCpoData    := {}
Private oTable      := Nil
Private oMarkBrow   := Nil
Private aRotina     := MenuDef()

    FwMsgRun(,{ || fLoadData() }, 'Abrindo Titulos em Aberto', 'Carregando dados...')

    oMarkBrow := FwMarkBrowse():New()
    oMarkBrow:SetAlias('TRB')
    oMarkBrow:SetTemporary()
    oMarkBrow:SetColumns(aCampos)
    oMarkBrow:SetFieldMark('TMP_OK')
    //oMarkBrow:SetMenuDef('FINA07MK')
    oMarkBrow:SetDescription('Risco Sacado')
    oMarkBrow:SetAllMark( { || oMarkBrow:AllMark() } )
    oMarkBrow:Activate()

    If(Type('oTable') <> 'U')

        oTable:Delete()
        oTable := Nil

    Endif

Return

Static Function MenuDef
    Local aRotina := {}

    Add Option aRotina Title 'Exportar Excel'       Action 'U_RISCOPROC()'        Operation 6 Access 0
   // Add Option aRotina Title 'Marcar Todos'       Action 'U_FINA07MD(.T.)'      Operation 6 Access 0
    //Add Option aRotina Title 'Desmarcar Todos'    Action 'U_FINA07MD(.F.)'      Operation 8 Access 0    

Return(aRotina)

Static Function fLoadData

Local nI        := 0
Local _cAlias   := GetNextAlias()

    If(Type('oTable') <> 'U')

        oTable:Delete()
        oTable := Nil

    Endif

    oTable     := FwTemporaryTable():New('TRB')

    aCampos     := {}
    aCpoInfo    := {}
    aCpoData    := {}

    aAdd(aCpoInfo, {'Marcar'            , '@!'                         , 1})
    aAdd(aCpoInfo, {'Filial'            , '@!'                         , 1})
    aAdd(aCpoInfo, {'Forcedor'          , '@!'                         , 1})
    aAdd(aCpoInfo, {'CNPJ'              , '@R 99.999.999/9999-99'      , 1})
    aAdd(aCpoInfo, {'Agencia'           , '@!'                         , 1})
    aAdd(aCpoInfo, {'Conta'             , '@!'                         , 1})
    aAdd(aCpoInfo, {'Nome'              , '@!'                         , 1})
    aAdd(aCpoInfo, {'Emissão'           , '@D'                         , 1})
    aAdd(aCpoInfo, {'Nota'              , '@!'                         , 1})
    aAdd(aCpoInfo, {'Valor'             , '@E 999,999,999.99'          , 1})
    aAdd(aCpoInfo, {'Vencto'            , '@D'                         , 1})


    aAdd(aCpoData, {'TMP_OK'        , 'C'                           , 2                                                     , 0})
    aAdd(aCpoData, {'TMP_FILIAL'    , TamSx3('E2_FILIAL')[3]        , TamSx3('E2_FILIAL')[1]                                , 0})
    aAdd(aCpoData, {'TMP_FORNEC'    , TamSx3('E2_FORNECE')[3]       , TamSx3('E2_FORNECE')[1]                               , 0})
    aAdd(aCpoData, {'TMP_CGC'       , TamSx3('A2_CGC')[3]           , TamSx3('A2_CGC')[1]                                   , 0})
    aAdd(aCpoData, {'TMP_AG'        , TamSx3('A2_AGENCIA')[3]       , TamSx3('A2_AGENCIA')[1]                               , 0})
    aAdd(aCpoData, {'TMP_CONTA'     , TamSx3('A2_NUMCON')[3]        , TamSx3('A2_NUMCON')[1]                                , 0})
    aAdd(aCpoData, {'TMP_NOMFOR'    , TamSx3('A2_NOME')[3]          , TamSx3('A2_NOME')[1]                                  , 0})    
    aAdd(aCpoData, {'TMP_EMISS'     , TamSx3('E2_EMIS1')[3]         , TamSx3('E2_EMIS1')[1]                                 , 0})    
    aAdd(aCpoData, {'TMP_NOTA'      , TamSx3('E2_NUM')[3]           , TamSx3('E2_NUM')[1]                                   , 0})    
    aAdd(aCpoData, {'TMP_VALOR'     , TamSx3('E2_VALOR')[3]         , TamSx3('E2_VALOR')[1]+TamSx3('E2_VALOR')[2]           , 0}) 
    aAdd(aCpoData, {'TMP_VENCTO'    , TamSx3('E2_VENCREA')[3]       , TamSx3('E2_VENCREA')[1]                               , 0})    


    For nI := 1 To Len(aCpoData)

        If(aCpoData[nI][1] <> 'TMP_OK' .and. aCpoData[nI][1] <> 'TMP_RECNO')

            aAdd(aCampos, FwBrwColumn():New())

            aCampos[Len(aCampos)]:SetData( &('{||' + aCpoData[nI,1] + '}') )
            aCampos[Len(aCampos)]:SetTitle(aCpoInfo[nI,1])
            aCampos[Len(aCampos)]:SetPicture(aCpoInfo[nI,2])
            aCampos[Len(aCampos)]:SetSize(aCpoData[nI,3])
            aCampos[Len(aCampos)]:SetDecimal(aCpoData[nI,4])
            aCampos[Len(aCampos)]:SetAlign(aCpoInfo[nI,3])

        EndIf

    Next nI    

    oTable:SetFields(aCpoData)

    oTable:Create()

    BeginSql Alias _cAlias

        %NoParser%
        SELECT
            E2_FILIAL,
            E2_FORNECE,
            A2_CGC,
            A2_AGENCIA,
            A2_NUMCON,
            A2_NOME,
            E2_EMIS1,
            E2_LOJA,
            E2_NOMFOR,
            E2_NUM,
            E2_VALOR,
            E2_VENCREA
        FROM 
            %Table:SE2% SE2
            INNER JOIN %Table:SA2% SA2
            ON E2_FORNECE = A2_COD
            AND E2_LOJA = A2_LOJA
            AND LEN(A2_CGC) = 14
        WHERE
            E2_BAIXA = '' 
            AND E2_SALDO > 0 
            AND SE2.D_E_L_E_T_ = ''
        ORDER BY
            E2_FORNECE, E2_EMIS1, E2_NUM

    EndSQL

    (_cAlias)->(DbGoTop())

    DbSelectArea('TRB')

    While(!(_cAlias)->(EoF()))

        RecLock('TRB', .T.)

            TRB->TMP_FILIAL     := (_cAlias)->E2_FILIAL
            TRB->TMP_FORNEC     := (_cAlias)->E2_FORNECE
            TRB->TMP_CGC        := (_cAlias)->A2_CGC
            TRB->TMP_AG         := (_cAlias)->A2_AGENCIA
            TRB->TMP_CONTA      := (_cAlias)->A2_NUMCON
            TRB->TMP_NOMFOR     := (_cAlias)->A2_NOME
            TRB->TMP_EMISS      := STOD( (_cAlias)->E2_EMIS1 )
            TRB->TMP_NOTA       := (_cAlias)->E2_NUM
            TRB->TMP_VALOR      := (_cAlias)->E2_VALOR 
            TRB->TMP_VENCTO     := STOD( (_cAlias)->E2_VENCREA )

        TRB->(MsUnlock())

        (_cAlias)->(DbSkip())

    EndDo

    TRB->(DbGoTop())

    (_cAlias)->(DbCloseArea())

Return
