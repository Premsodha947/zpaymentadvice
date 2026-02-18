CLASS zpayment_advice_print DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS:
      read_post
        IMPORTING
                  VALUE(document)    TYPE CHAR10
*           VALUE(companycode) TYPE string
*           VALUE(fiscalyear) TYPE string
*           VALUE(plant) TYPE string
*           VALUE(PostingDate) type string



*      VALUE(document) type I_Operatio
                  VALUE(companycode) TYPE I_OperationalAcctgDocItem-CompanyCode
                  VALUE(fiscalyear)  TYPE I_OperationalAcctgDocItem-FiscalYear
                  VALUE(plant)       TYPE  string
*                  VALUE(PostingDate) TYPE I_OperationalAcctgDocItem-PostingDate



        RETURNING VALUE(result12)    TYPE string
        RAISING   cx_static_check.
    INTERFACES : if_http_service_extension, if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES: BEGIN OF ty_item,
             doc_no                 TYPE string,
             documentdate           TYPE dats,
             accountingdocumenttype TYPE string,
             unit                   TYPE string,
             invoiceno              TYPE string,
             invoicedate            TYPE dats,
             invoiceamount          TYPE p LENGTH 15 DECIMALS 2,
             tds                    TYPE p LENGTH 15 DECIMALS 2,
             otherdeductions        TYPE p LENGTH 15 DECIMALS 2,

             netamount              TYPE p LENGTH 15 DECIMALS 2,
           END OF ty_item.


ENDCLASS.



CLASS ZPAYMENT_ADVICE_PRINT IMPLEMENTATION.


  METHOD read_post.





    SELECT SINGLE FROM zc_payment_advice
    FIELDS VendorNo , VendorName , AccountingDocument,
           Paymentdate , CHQNo , VendorAddress,
           typeofaccounting , remark , Bankname
    WHERE ( typeofaccounting = 'KZ'
         OR typeofaccounting = 'ZP' )
      AND AccountingDocument = @document
      AND CompanyCode        = @companycode
      AND FiscalYear         = @fiscalyear
*  AND Plant              = @plant
    INTO @DATA(header).







*    DATA plant1 TYPE string.
*    DATA Address1 TYPE string.
*    DATA Address2 TYPE string.
*    DATA Address3 TYPE string.
*
*    IF   plant = '1001'.
*
*
*      Address1 = 'Gat No. 15 & 16, Nandur Road, Taluka Daund,'.
*      Address2 = 'Sahajpur, Pune - 412202,'.
*      Address3 = 'Maharashtra, India'.
*    ELSEIF
*
*
*   plant = '1002'.
*
*      Address1 = 'Plot No. 502 & 503, S. No. 338 & 339, Belur Industrial Estate,'.
*      Address2 = 'Road No. 23, Dharwad - 580011,'.
*      Address3 = 'Karnataka, India'.
*    ELSEIF
*
*
*   plant = '1003'.
*      Address1 = 'Plot No. 98, S. No. 262, Belur Industrial Area,'.
*      Address2 = 'Road No. 23, Dharwad - 580011,'.
*      Address3 = 'Karnataka, India'.

* ELSEIF
*
*  HS-Plant = '3001'.
* Address1 = 'Office No. 28, 10th Floor, Suyog Platinum Tower,'.
* Address2 = 'Near Conrad, Sangamwadi,'.
* Address3 = 'Pune - 411001'.
*    ENDIF.
    """""""""""""""""""""""""""""""""""""""""""""""""""



    TYPES: BEGIN OF ty_invoice,
             SupplierInvoice        TYPE i_supplierinvoiceapi01-SupplierInvoice,
             FiscalYear             TYPE i_supplierinvoiceapi01-FiscalYear,
             AccountingDocumentType TYPE i_supplierinvoiceapi01-AccountingDocumentType,
             InvoiceGrossAmount     TYPE i_supplierinvoiceapi01-InvoiceGrossAmount,
             DocumentDate           TYPE i_supplierinvoiceapi01-DocumentDate,
             billno                 TYPE i_supplierinvoiceapi01-SupplierInvoiceIDByInvcgParty,
           END OF ty_invoice.


    DATA: lt_all_docs TYPE STANDARD TABLE OF ty_invoice,
          ls_all_docs TYPE ty_invoice,
          ls_itab     TYPE ty_invoice.

    SELECT * FROM I_OperationalAcctgDocItem
      WHERE accountingdocument         = @document
  AND CompanyCode                  = @companycode
  AND FiscalYear                   = @fiscalyear
  INTO TABLE @DATA(lt_alldata).                            " TO GET ALL DOCUMENTS


    SELECT SINGLE AccountingDocument
    FROM I_OperationalAcctgDocItem
    WHERE ClearingJournalEntry = @document
      AND CompanyCode          = @companycode
      AND FiscalYear           = @fiscalyear
    INTO @DATA(lv_doc).                                     " CHECK FIRST ITS CLEARED OR NOT

    IF sy-subrc = 0.                                        " IF YES

      " Get invoice number
      SELECT  substring( originalreferencedocument, 1, 10 )
        FROM I_OperationalAcctgDocItem
        WHERE ClearingJournalEntry         = @document
          AND CompanyCode                  = @companycode
          AND FiscalYear                   = @fiscalyear
          AND ( TransactionTypeDetermination = 'KBS'
                 or FinancialAccountType         = 'K' )
        INTO TABLE @DATA(lv_invoiceno).


      LOOP AT lv_invoiceno INTO DATA(wa).

        " Get invoice details
        IF lv_invoiceno IS NOT INITIAL.
          SELECT SINGLE SupplierInvoice,
                        FiscalYear,
                        AccountingDocumentType,
                        InvoiceGrossAmount,
                        DocumentDate,
                        supplierinvoiceidbyinvcgparty
            FROM I_SupplierInvoiceAPI01
            WHERE SupplierInvoice = @wa
            INTO @ls_itab.



          IF sy-subrc = 0.
            APPEND ls_itab TO lt_all_docs.
          ENDIF.
        ENDIF.
      ENDLOOP.

    ELSE.                               " IF NO

      SELECT SINGLE invoicereference FROM i_journalentryitem
      WHERE accountingdocument = @document
           AND CompanyCode  = @companycode
          AND FiscalYear       = @fiscalyear
          AND ledger = '0L'
          AND FinancialAccountType = 'K'
          INTO @DATA(lv_acdoc).

      SELECT SINGLE referencedocument FROM i_journalentryitem
      WHERE accountingdocument = @lv_acdoc
      INTO @DATA(lv_miro).

      SELECT SINGLE amountintransactioncurrency FROM i_journalentryitem
WHERE accountingdocument = @lv_acdoc
AND TransactionTypeDetermination = 'WIT'
INTO @DATA(lv_tdsAMOUNT).


      IF lv_miro IS NOT INITIAL.
        SELECT SINGLE SupplierInvoice,
                      FiscalYear,
                      AccountingDocumentType,
                      InvoiceGrossAmount,
                      DocumentDate,
                      supplierinvoiceidbyinvcgparty
          FROM I_SupplierInvoiceAPI01
          WHERE SupplierInvoice = @lv_miro
          INTO @ls_itab.

        IF sy-subrc = 0.
          APPEND ls_itab TO lt_all_docs.
        ENDIF.
      ENDIF.

      """"""""""""""" count line items """"""""""""
*DATA(lv_doc_countall) = 0.
*
*LOOP AT lt_all_docs INTO DATA(ls_doc) .
*  IF ls_doc-supplierinvoice IS NOT INITIAL.
*    lv_doc_countall += 1.
*  ENDIF.
*ENDLOOP.


    ENDIF.
    """""""""""""""""""""""""advance """"""""""""""""""""""
    DATA: lt_adv_docs TYPE STANDARD TABLE OF i_operationalacctgdocitem,
          ls_adv_docs TYPE i_operationalacctgdocitem,
          wa_tab      TYPE i_operationalacctgdocitem.


    IF lt_all_docs IS INITIAL.
      " Fetch base document
      SELECT SINGLE *
        FROM i_operationalacctgdocitem
        WHERE companycode = @companycode
          AND fiscalyear = @fiscalyear
          AND accountingdocument = @document
          AND financialaccounttype = 'K'
          AND SpecialGLCode = 'A'
        INTO @wa_tab.

      IF sy-subrc = 0.
        APPEND wa_tab TO lt_adv_docs.
      ENDIF.

    ENDIF.
    """"""""""""""""UNIT"""""""""""""'

    SELECT CASE
      WHEN right( profitcenter , 4 ) = '1001' THEN 'H1'
       WHEN right( profitcenter , 4 ) = '1002' THEN 'H2'
       WHEN right( profitcenter , 4 ) = '1003' THEN 'H3' ELSE NULL END AS Unit
    FROM i_journalentryitem
          WHERE accountingdocument         = @document
      AND CompanyCode                  = @companycode
      AND FiscalYear                   = @fiscalyear
      AND FinancialAccountType = 'K'
      INTO @DATA(lv_UNIT).
    ENDSELECT.
    """"""""""""""""""""""""""""""" INVOICE NO"""""""""'

    SELECT SINGLE *
FROM i_journalentry
WHERE companycode        = @companycode
  AND fiscalyear         = @fiscalyear
  AND accountingdocument = @document
INTO @DATA(tabu12).


    """"""""""""""""""remark"""""""""""""""""""""

    SELECT SINGLE * FROM i_journalentryitem WHERE
         companycode = @companycode AND
         fiscalyear = @fiscalyear AND
         financialaccounttype = 'K' AND
         accountingdocument = @document
         INTO @DATA(remark).


    SELECT SINGLE * FROM i_journalentry
    WHERE  companycode = @companycode AND
           fiscalyear = @fiscalyear AND
           accountingdocument = @document
           INTO @DATA(remark1).

    DATA : lv_narration TYPE string.

    IF remark-documentitemtext IS NOT INITIAL.
      lv_narration = remark-documentitemtext.
    ELSE.
      lv_narration = remark1-accountingdocumentheadertext.
    ENDIF.

    """""""""""""""""""""""withholdingtax""""""""""""

    SELECT SINGLE withholdingtaxamount FROM I_OperationalAcctgDocItem
WHERE ClearingJournalEntry = @document
AND TransactionTypeDetermination = 'KBS'
INTO @DATA(lv_clearing_wth).




    DATA: lv_tds TYPE P DECIMALS 2.

    IF lv_clearing_wth IS NOT INITIAL.
      lv_tds = lv_clearing_wth.
    ELSE.
      lv_tds = lv_tdsAMOUNT.
    ENDIF.

    IF sy-subrc = 0.

    ELSE.

    ENDIF.

    """""""""""""""GSTIN


    DATA gstin TYPE string.

    IF lv_UNIT = 'H1'.

      gstin = '27AAACH7381L1Z6' .

    ELSEIF

     lv_UNIT = 'H2' OR lv_UNIT = 'H3' .

      gstin = '29AAACH7381L1Z2'.

    ENDIF.

    """""""""""""""""""


    DATA Address1 TYPE string.
    DATA Address2 TYPE string.
    DATA Address3 TYPE string.

    IF lv_UNIT = 'H1'.

      Address1 = 'Gat No. 15 & 16, Nandur Road, Taluka Daund,'.
      Address2 = 'Sahajpur, Pune - 412202,'.
      Address3 = 'Maharashtra, India'.
    ELSEIF

   lv_UNIT = 'H2'.
      Address1 = 'Plot No. 502 & 503, S. No. 338 & 339, Belur Industrial Estate,'.
      Address2 = 'Road No. 23, Dharwad - 580011,'.
      Address3 = 'Karnataka, India'.
    ELSEIF

    lv_UNIT = 'H3'.


      Address1 = 'Plot No. 98, S. No. 262, Belur Industrial Area,'.
      Address2 = 'Road No. 23, Dharwad - 580011,'.
      Address3 = 'Karnataka, India'.

    ENDIF.
    """""""""""""""""""""






    DATA(lv_xml) =

     | <form1>|  &&
     | <ADDRESS1>{ address1 }</ADDRESS1> | &&
     | <ADDRESS2>{ address2 }</ADDRESS2> | &&
     | <ADDRESS3>{ address3 }</ADDRESS3>|  &&
     | <GST>{ gstin }</GST>|  &&
     | <VENDORCODE>{ header-VendorNo }</VENDORCODE>|  &&
     | <MS>{ header-VendorName }</MS>|  &&
     | <addr>{ header-VendorAddress }</addr>|  &&
     | <DOCUMENTNO>{ header-AccountingDocument }</DOCUMENTNO>|  &&
     | <documentdate>{ header-Paymentdate }</documentdate> | &&
     | <CHQNO>{ header-CHQNo }</CHQNO>|  &&
     | <BANKNAME>{ header-Bankname }</BANKNAME>| .





    DATA(lv_grand_total) = 0.
    DATA(lv_srno) = 0.



    IF lt_all_docs IS INITIAL.
      LOOP AT lt_adv_docs INTO ls_adv_docs.




        lv_srno += 1.
*        lv_grand_total += ls_item-netamount.

        DATA : lv_deduction TYPE P DECIMALS 2.

        lv_deduction = ( ls_adv_docs-AmountInTransactionCurrency +  lv_tds ) - abs( ls_adv_docs-amountintransactioncurrency ).
        lv_xml = lv_xml &&
          | <Row1>| &&
          |   <Srno>{ lv_srno }</Srno>| &&
          |   <docno>{ ls_adv_docs-accountingdocument }</docno>| &&
          |   <docdate>{ ls_adv_docs-documentdate }</docdate>| &&
          |   <doctype>{ ls_adv_docs-accountingdocumenttype }</doctype>| &&
          |   <unit>{ lv_UNIT }</unit>| &&
          |   <billno>{ ls_itab-billno }</billno>| &&
          |   <Cell7>{ ls_itab-documentdate }</Cell7>| &&
*          |   <Cell7>{ tabu12-PostingDate }</Cell7>| &&
          |   <passedamt>{  ls_adv_docs-AmountInTransactionCurrency }</passedamt>| &&
          |   <tdsamt>{ lv_tds }</tdsamt>| &&
          |   <OtherDeductions>{ lv_deduction }</OtherDeductions>| &&
          |   <netamt>{   ls_adv_docs-amountintransactioncurrency   }</netamt>| &&
         | </Row1>| .
      ENDLOOP.
    ELSE.

      LOOP AT lt_all_docs INTO ls_all_docs.



IF   ls_all_docs-accountingdocumenttype = 'KG'.
  ls_all_docs-invoicegrossamount = ls_all_docs-invoicegrossamount * -1.

ENDIF.


DATA: TDS_DOCU TYPE I_OperationalAcctgDocItem-OriginalReferenceDocument.

CLEAR : TDS_DOCU, lv_tds.
CONCATENATE ls_all_docs-supplierinvoice ls_all_docs-fiscalyear INTO TDS_DOCU.


          SELECT SINGLE withholdingtaxamount FROM I_OperationalAcctgDocItem
WHERE ClearingJournalEntry = @document
AND OriginalReferenceDocument = @TDS_DOCU
AND TransactionTypeDetermination = 'KBS'
INTO  @DATA(lv_clearing_wth111).

    IF lv_clearing_wth111 IS NOT INITIAL.
      lv_tds = lv_clearing_wth111.
    ELSE.
      lv_tds = lv_tdsAMOUNT.
    ENDIF.



        lv_srno += 1.
*        lv_grand_total += ls_item-netamount.
        SELECT SINGLE *
        FROM i_operationalacctgdocitem
        WHERE companycode = @companycode
          AND fiscalyear = @fiscalyear
          AND accountingdocument = @document
          AND financialaccounttype = 'S'
        INTO @wa_tab.


        DATA : inv_amt TYPE i_supplierinvoiceapi01-InvoiceGrossAmount.
        DATA : acdoc_amt TYPE i_operationalacctgdocitem-AmountInTransactionCurrency.
        DATA : netamt TYPE P DECIMALS 2.

     DATA(lv_doc_countall) = 0.

            LOOP AT lt_all_docs INTO DATA(ls_doc) .
             IF ls_doc-supplierinvoice IS NOT INITIAL.
              lv_doc_countall += 1.
             ENDIF.
            ENDLOOP.

        IF lv_doc_countall > 1.
*        netamt = ls_all_docs-invoicegrossamount.

        netamt = ls_all_docs-invoicegrossamount + lv_tds .
        else.
          netamt = wa_tab-AmountInTransactionCurrency.
          endif.



*  IF   ls_all_docs-accountingdocumenttype = 'KG'.
*     netamt = netamt * -1.
*
*   ENDIF.



          DATA :lv_deduct TYPE P DECIMALS 2.

*          lv_deduct = ( ls_all_docs-invoicegrossamount + lv_tds  ) - abs( wa_tab-AmountInTransactionCurrency ).

        IF lv_doc_countall > 1.

          lv_deduct = '0.00'.
*          lv_deduct = ( ls_all_docs-invoicegrossamount + lv_tds  ) - ls_all_docs-invoicegrossamount.
      else .
         lv_deduct = ( ls_all_docs-invoicegrossamount + lv_tds  ) - abs( wa_tab-AmountInTransactionCurrency ).

                 ENDIF.


          lv_xml = lv_xml &&
            | <Row1>| &&
            |   <Srno>{ lv_srno }</Srno>| &&
            |   <docno>{ ls_all_docs-supplierinvoice }</docno>| &&
            |   <docdate>{ ls_all_docs-documentdate }</docdate>| &&
            |   <doctype>{ ls_all_docs-accountingdocumenttype }</doctype>| &&
            |   <unit>{ lv_UNIT }</unit>| &&
            |   <billno>{ ls_all_docs-billno }</billno>| &&
            |   <Cell7>{ ls_all_docs-documentdate }</Cell7>| &&
*            |   <Cell7>{ tabu12-PostingDate }</Cell7>| &&
            |   <passedamt>{  ls_all_docs-invoicegrossamount  }</passedamt>| &&
            |   <tdsamt>{ lv_tds }</tdsamt>| &&
            |   <OtherDeductions>{ lv_deduct }</OtherDeductions>| &&
            |   <netamt>{  netamt  }</netamt>| &&  "abs( netamt )  "wa_tab-AmountInTransactionCurrency
           | </Row1>| .
        ENDLOOP.
      ENDIF.

      lv_xml = lv_xml &&

      |<Amountinwords></Amountinwords>| &&
      |<Remark>{ lv_narration }</Remark>| &&
      | </form1>| .

      CALL METHOD zcl_adobe_print=>adobe(
        EXPORTING
          form_name = 'Payment_Advice_Hodek'
          xml       = lv_xml
        RECEIVING
          result    = result12 ).


    ENDMETHOD.
ENDCLASS.
