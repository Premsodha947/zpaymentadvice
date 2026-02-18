@EndUserText.label: 'Payment Doc (Supplier Payments)'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Analytics.dataCategory: #CUBE
define view entity zfi_i_paymentadv
  as select from I_OperationalAcctgDocItem
  association [0..1] to I_Supplier    as _Supplier    on $projection.Supplier = _Supplier.Supplier
  association [0..1] to I_CompanyCode as _CompanyCode on $projection.CompanyCode = _CompanyCode.CompanyCode
  
  association [0..1] to ZC_Payment_Item as _item on $projection.AccountingDocument = _item.AccountingDocument
{

      @Consumption.filter: { selectionType: #SINGLE, mandatory: false }
      @ObjectModel.text.element: ['CompanyCodeName']
      @UI.selectionField: [{position: 1 }] 
  key CompanyCode                  as CompanyCode,

      @Consumption.filter: { selectionType: #SINGLE, mandatory: false }
      @UI.selectionField: [{position: 2 }] 
  key FiscalYear                   as FiscalYear,

      @Consumption.filter: { selectionType: #RANGE, mandatory: false }
      @UI.selectionField: [{position: 3 }] 
  key AccountingDocument           as AccountingDocument,

      _CompanyCode.CompanyCodeName as CompanyCodeName,

      @Consumption.filter: { selectionType: #SINGLE, mandatory: false }
      @ObjectModel.text.element: ['SupplierName']
      @UI.selectionField: [{position: 4 }] 
      Supplier                     as Supplier,

      _Supplier.SupplierName       as SupplierName,

      @Consumption.filter: { selectionType: #RANGE, mandatory: false }
      PostingDate,

      @Semantics.amount.currencyCode: 'Currency'
      sum(
        case DebitCreditCode
          when 'S' then cast( AmountInCompanyCodeCurrency as abap.dec(23,2) )
          when 'H' then -cast( AmountInCompanyCodeCurrency as abap.dec(23,2) )
          else 0
        end
      )                            as PaymentAmount,

      CompanyCodeCurrency          as Currency,
      
      
      
     _item.Yourdoc              as Invoice_No,
    _item.DocumentCurrency,
    @Semantics.amount.currencyCode: 'DocumentCurrency'
    _item.OtherDeductions       as  TDS_Amount ,
    _item.CompanyCodeCurrency,
    @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
    _item.amtpaid               as Net_Amount,
    _item.Miroamt               as Invoice_Amt,
    _item.Postingdate           as Doc_Date,
    _item.Supplierinvoice       as Doc_No
    

    
      
      
}
where
  (
       AccountingDocumentType = 'ZP'
    or AccountingDocumentType = 'KZ'
   
  )
  and  Supplier               is not initial
group by
  CompanyCode,
  FiscalYear,
  AccountingDocument,
  Supplier,
  PostingDate,
  CompanyCodeCurrency,
  _Supplier.SupplierName,
  _CompanyCode.CompanyCodeName,
  
  _item.Yourdoc   ,         
 _item.OtherDeductions ,   
  _item.amtpaid  ,           
  _item.Miroamt  ,           
  _item.Postingdate ,      
  _item.Supplierinvoice ,
  _item.DocumentCurrency , 
  _item.CompanyCodeCurrency  
  

                            
                            
  
