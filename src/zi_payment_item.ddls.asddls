@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Item cds view for Payment'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_Payment_Item
  as select from    ZI_Journalentryitem_ledger as _item
  
  inner join I_JournalEntryItem as _Jitem on  _item.AccountingDocument = _Jitem.AccountingDocument
                                                           and _item.LedgerGLLineItem   = _Jitem.LedgerGLLineItem
                                                           and _item.Ledger             = _Jitem.Ledger
                                                           and _item.FiscalYear         = _Jitem.FiscalYear
                                                           and _item.CompanyCode        = _Jitem.CompanyCode
                                                           and _Jitem.Ledger = '0L'
                                                           and ( _Jitem.AccountingDocumentType = 'KZ' or _Jitem.AccountingDocumentType = 'UE'  or _Jitem.AccountingDocumentType = 'ZP' )
                                                           
   left outer join ZI_Payment_InvoiceRef as _inRef on _inRef.AccountingDocument = _item.AccountingDocument
                                                  and _item.Ledger             = _inRef.Ledger
                                                  and _item.FiscalYear         = _inRef.FiscalYear
                                                  and _item.CompanyCode        = _inRef.CompanyCode
                                                  and _Jitem.InvoiceReference   = _inRef.InvoiceReference
                                                  
 //SSR       
// left outer join I_JournalEntryItem as SR on   SR.LedgerGLLineItem = _Jitem.LedgerGLLineItem
//                                            and SR.Ledger = _Jitem.Ledger
//                                            and SR.FiscalYear = _Jitem.FiscalYear
//                                            and SR.AccountingDocument = _Jitem.InvoiceReference and SR.TransactionTypeDetermination = 'KBS'
//  
//                                         
//   left outer join ZI_Payment_InvoiceRef as _inV1 on _item.LedgerGLLineItem             = _inV1.LedgerGLLineItem
//                                                  and    _item.Ledger             = _inV1.Ledger
//                                                  and _item.FiscalYear         = _inV1.FiscalYear
//                                                  and _item.CompanyCode        = _inV1.CompanyCode
//                                                  and _Jitem.InvoiceReference   = _inV1.AccountingDocument and _inV1.TransactionTypeDetermination = 'KBS'
                                                   
   left outer join ZI_insupplier_Doc as _sup on _sup.AccountingDocument = _Jitem.InvoiceReference
                                            and  _item.FiscalYear         = _sup.FiscalYear
                                            and  _item.CompanyCode        = _sup.CompanyCode
  

    left outer join ZI_ClearingJournalEntry        as _entry   on  _item.AccountingDocument = _entry.ClearingJournalEntry
  //                                                         and _item.LedgerGLLineItem   = _entry.LedgerGLLineItem
                                                           and _item.Ledger             = _entry.Ledger
                                                           and _item.FiscalYear         = _entry.FiscalYear
                                                           and _item.CompanyCode        = _entry.CompanyCode
                                                           and _item.SpecialGLCode is initial
                                                           and _entry.AccountingDocument is not initial
                                                           and _item.PartialDocument = 'CL'

    left outer join I_SupplierInvoiceAPI01     as _invoice on  _entry.Supplier          = _invoice.InvoicingParty
                                                           and _entry.FiscalYear        = _invoice.FiscalYear
                                                           and _entry.CompanyCode       = _invoice.CompanyCode
                                                           and _entry.ReferenceDocument = _invoice.SupplierInvoice

    left outer join I_OperationalAcctgDocItem  as _amt     on  _entry.AccountingDocument     = _amt.AccountingDocument
                                                           and _entry.CompanyCode            = _amt.CompanyCode
                                                           and _entry.FiscalYear             = _amt.FiscalYear
                                                           and _entry.AccountingDocumentItem = _amt.AccountingDocumentItem

    left outer join I_JournalEntry             as _journal on  _journal.AccountingDocument = _item.AccountingDocument
                                                           and _journal.CompanyCode        = _item.CompanyCode
                                                           and _journal.FiscalYear         = _item.FiscalYear

    left outer join I_JournalEntry             as _UE      on  _UE.AccountingDocument = _entry.ReferenceDocument
                                                           and _UE.CompanyCode        = _item.CompanyCode
                                                           and _UE.FiscalYear         = _item.FiscalYear

    left outer join I_JournalEntryItem         as _UE1     on  _UE1.AccountingDocument = _entry.ReferenceDocument
                                                           and _UE1.AccountingDocumentType = 'UE'
                                                           and _UE1.DebitCreditCode = 'S'
                                                           and _UE1.CompanyCode        = _item.CompanyCode
                                                           and _UE1.FiscalYear         = _item.FiscalYear
                                                           and _UE1.Ledger             = _item.Ledger

{
  key  _item.CompanyCode,
  key  _item.FiscalYear,
  key  _item.AccountingDocument,
  key  _item.LedgerGLLineItem,
       _item.SpecialGLCode,
       case
       when _item.PartialDocument = 'PA'
       then 'PARTIAL PAYMENT'
       when _Jitem.InvoiceReference is not initial
       then _sup.SupplierInvoiceIDByInvcgParty
       else
       _invoice.SupplierInvoiceIDByInvcgParty     end                                                as Yourdoc,
       //       _entry.AccountingDocument                                                                  as Yourdoc,
       _entry.ClearingJournalEntry,
       
       case
       when _item.PartialDocument = 'PA'
       then _item.AccountingDocument
       when _item.SpecialGLCode is not initial
       then _item.AccountingDocument
       when _Jitem.InvoiceReference is not initial
       then _Jitem.InvoiceReference
       else _entry.ReferenceDocument
       end  
                                                                                               as Supplierinvoice,
       //     _invoice.SupplierInvoice    as Supplierinvoice,
       //   ' '
       case
       when _item.SpecialGLCode is not initial
       then 'H'
       else
       _entry.DebitCreditCode
       end as DebitCreditCode,
       _entry.AccountingDocumentType as AccoutDocType,
       _UE.AccountingDocumentType,
       
       case
       when _UE.AccountingDocumentType = 'UE'
       then _UE.DocumentDate
       when _item.SpecialGLCode is not initial
       then _item.DocumentDate
        when _Jitem.InvoiceReference is not initial
       then _inRef.DocumentDate
       when _item.PartialDocument = 'PA'
       then _Jitem.DocumentDate
       else 
       case
           when (_entry.AccountingDocumentType = 'KZ') or (_entry.AccountingDocumentType = 'ZP' ) 
             then _entry.DocumentDate
             else _invoice.PostingDate end
       end                                                                                                                     as Postingdate,
       
       _invoice.DocumentCurrency,
       @Semantics.amount.currencyCode: 'DocumentCurrency'
      
      
       case when _UE.AccountingDocumentType = 'UE'then _UE1.AmountInTransactionCurrency 
       when _item.PartialDocument = 'PA'
       then _Jitem.AmountInTransactionCurrency
       
       when _Jitem.InvoiceReference is not initial
            then _inRef.AmountInTransactionCurrency
       else 
           case
           when (_entry.AccountingDocumentType = 'KZ') or (_entry.AccountingDocumentType = 'ZP' )
             then _entry.AmountInTransactionCurrency  
            else _invoice.InvoiceGrossAmount   end
        end as Miroamt,

//    SR.AmountInTransactionCurrency as Miroamt,
//    SR.AccountingDocument as DOC_NUM,
//    SR.AccountingDocumentType as DOC_TYPE,
//    SR.DocumentDate as DOC_DATE,


       
       _amt.CompanyCodeCurrency,
       @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
       //       _amt.WithholdingTaxAmount                                                                  as Deductionamt,
     case when _UE.AccountingDocumentType = 'UE'then cast(0 as abap.curr(23,2))
     else  cast( abs(coalesce(cast(_amt.WithholdingTaxAmount as abap.dec(23,2)), 0) )
      as abap.curr(23,2) )       end                                                                as Deductionamt,
       
       @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
       _amt.CashDiscountAmount,
       @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
       // (journal.AmountInCompanyCodeCurrency - _opact.WithholdingTaxAmount)
       
      case 
      when _item.SpecialGLCode is not initial
      then abs(_Jitem.AmountInTransactionCurrency)
      
      when _item.PartialDocument = 'PA'
      then _Jitem.AmountInTransactionCurrency
      
      when _Jitem.InvoiceReference is not initial
      then _inRef.AmountInTransactionCurrency
      
      when _UE.AccountingDocumentType = 'UE' 
      then abs(_UE1.AmountInTransactionCurrency) + _amt.CashDiscountAmount
      
      else 
       case 
           when (_entry.AccountingDocumentType = 'KZ') or (_entry.AccountingDocumentType = 'ZP' )
             then abs(_entry.AmountInTransactionCurrency) 
           else cast (coalesce(cast(_invoice.InvoiceGrossAmount as abap.dec(23,2)), 0) -
           abs(coalesce(cast(_amt.WithholdingTaxAmount as abap.dec(23,2)), 0)) as abap.curr(23,2) ) +  _amt.CashDiscountAmount  end 
           end                      as amtpaid,


 case
  when right( _Jitem.ProfitCenter , 4 ) = '1001' then 'H1'
   when right( _Jitem.ProfitCenter , 4 ) = '1002' then 'H2'  
   when right( _Jitem.ProfitCenter , 4 ) = '1003' then 'H3' else null end as Unit

}
where
     ( _entry.AccountingDocument != _item.AccountingDocument ) or _item.SpecialGLCode is not initial or _Jitem.InvoiceReference is not initial or _item.PartialDocument = 'PA'
