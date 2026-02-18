class ZCL_FI_PAYMENT_ADVICE_HTTP definition
  public
  create public .

public section.

  interfaces IF_HTTP_SERVICE_EXTENSION .

  class-data :
 pdf_xstring TYPE xSTRING.



protected section.
private section.
ENDCLASS.



CLASS ZCL_FI_PAYMENT_ADVICE_HTTP IMPLEMENTATION.


  method IF_HTTP_SERVICE_EXTENSION~HANDLE_REQUEST.

  TRY.

  DATA(req) = request->get_form_fields(  ).

data :  document TYPE string,
       companycode type I_OperationalAcctgDocItem-CompanyCode,
       fiscalyear type I_OperationalAcctgDocItem-FiscalYear,
       plant   type  string,
       PostingDate type I_OperationalAcctgDocItem-PostingDate,
       printtype type  string,
       documentno TYPE string,
       mailbutton TYPE string.




  document  = value #( req[ name = 'document' ]-value OPTIONAL ) .
  companycode = value #( req[ name = 'companycode' ]-value OPTIONAL ) .
  fiscalyear = value #( req[ name = 'fiscalyear' ]-value OPTIONAL ) .
  plant = value #( req[ name = 'plant' ]-value OPTIONAL ) .
  PostingDate = value #( req[ name = 'PostingDate' ]-value OPTIONAL ) .
  mailbutton = value #( req[ name = 'mailbutton' ]-value OPTIONAL ) .


* printtype = VALUE #( req[ name = 'printtype' ]-value OPTIONAL ) . "Mail Button "

 data docno2 type char10.
   docno2 = |{ document ALPHA = IN }| .



    DATA VAR1 TYPE string.
    DATA VAR2 TYPE string.

*IF variable1 IS NOT INITIAL.
*        VAR1 = variable.
*        VAR1 =   |{ VAR1  ALPHA = IN }| .
*        VAR2 = variable1.
*        VAR2 =   |{ VAR2  ALPHA = IN }| .
*ELSE.

*SPLIT document at ',' INTO TABLE data(it).
SPLIT document at ',' INTO TABLE data(it).
data : DelDoc TYPE RANGE OF I_OperationalAcctgDocItem-AccountingDocument ,
       W_DelDoc LIKE LINE OF DelDoc .
LOOP AT IT INTO DATA(WA).
VAR1 = WA.
W_DelDoc-option = 'EQ'.
W_DelDoc-sign = 'I'.
W_DelDoc-low = |{ VAR1  ALPHA = IN }| .
APPEND W_DelDoc TO DelDoc.
CLEAR : VAR1.
ENDLOOP.

*ENDIF.

IF VAR1 IS NOT INITIAL AND VAR2 IS INITIAL .

VAR2 = VAR1 .

ENDIF.

 SELECT  substring( originalreferencedocument, 1, 10 ) AS originalreferencedocument,
                         AccountingDocumentType
        FROM I_OperationalAcctgDocItem
        WHERE ClearingJournalEntry         = @docno2
          AND CompanyCode                  = @companycode
          AND FiscalYear                   = @fiscalyear
          AND AccountingDocumentType       = 'UE'
*          AND ( TransactionTypeDetermination = 'KBS'
*                 or FinancialAccountType         = 'K' )
        INTO TABLE @DATA(lv_invoicpeno).

        READ TABLE lv_invoicpeno INTO DATA(UI_TAB) INDEX 1.

*IF variable1 IS NOT INITIAL.
select * from I_OperationalAcctgDocItem where AccountingDocument  BETWEEN @VAR1 and @VAR2   into table  @data(ACChead)  .
*ELSE.
select * from I_OperationalAcctgDocItem where AccountingDocument  IN @DelDoc  into table  @ACChead  .
*ENDIF.
SORT ACChead  BY AccountingDocument .

DELETE ADJACENT DUPLICATES FROM ACChead COMPARING  AccountingDocument.

if sy-subrc = 0 .
if lines( ACChead ) le 50 .

DATA(l_merger) = cl_rspo_pdf_merger=>create_instance( ).
loop at ACChead INTO data(invdata)  .
clear : docno2.

docno2  =   invdata-AccountingDocument .




IF mailbutton <> 'X' .
IF UI_TAB-AccountingDocumentType <> 'UE'.
 data(pdf1)   = zpayment_advice_print=>read_post( document = docno2  companycode = companycode
                                                        fiscalyear = fiscalyear plant = plant  )  .



 pdf_xstring = xco_cp=>string( pdf1 )->as_xstring( xco_cp_binary=>text_encoding->base64 )->value.

l_merger->add_document( pdf_xstring ).

ELSEIF
     UI_TAB-AccountingDocumentType = 'UE'.
 pdf1   = znew_ue_payment_adv=>read_post( document = docno2  companycode = companycode
                                                        fiscalyear = fiscalyear plant = plant  )  .


 pdf_xstring = xco_cp=>string( pdf1 )->as_xstring( xco_cp_binary=>text_encoding->base64 )->value.

l_merger->add_document( pdf_xstring ).

ENDIF.

ELSE .
  data(mail)   = ycl_payment_advice_mail=>read_post( document = docno2  companycode = companycode
                                                        fiscalyear = fiscalyear plant = plant   )  .

ENDIF.

clear : docno2.

clear : invdata.

*ENDIF.
ENDLOOP.

TRY .
    DATA(l_poczone_PDF) = l_merger->merge_documents( ).
      CATCH cx_rspo_pdf_merger INTO DATA(l_exception).
        " Add a useful error handling here
    ENDTRY.
        DATA(response_final) = xco_cp=>xstring( l_poczone_PDF
      )->as_string( xco_cp_binary=>text_encoding->base64
      )->value .

else .
  response_final = |Error'Please Select Maximum 50 Document'| .
ENDIF.
ENDIF.
*ELSE .
*  data(mail)   = ycl_payment_advice_mail=>read_post( document = docno2  companycode = companycode
*                                                        fiscalyear = fiscalyear plant = plant   )  .
*
*ENDIF.
 IF mailbutton = 'X' .
  response->set_text( mail ) .
 ELSE.
response->set_text( response_final ) .
ENDIF.

*response->set_text( response_final ) .



 CATCH cx_static_check INTO DATA(lx_static).
    response->set_text( |An error occurred: { lx_static->get_text( ) }| ).

ENDTRY.
  endmethod.
ENDCLASS.
