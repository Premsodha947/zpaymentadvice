@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Payment Advice Report - Consumption View'
define view entity ZFI_C_PaymentAdv
  as projection on zfi_i_paymentadv 
  

{
      @Consumption.filter: { selectionType: #SINGLE }
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCode', element: 'CompanyCode' } }]
 @UI.selectionField: [{position: 1 }] 
  key CompanyCode,
      @Consumption.filter: { selectionType: #SINGLE }
      @UI.selectionField: [{position: 3 }] 
  key FiscalYear,
      @Consumption.filter: { selectionType: #RANGE }
      @UI.selectionField: [{position: 2 }] 
  key AccountingDocument,
      @Consumption.filter: { selectionType: #RANGE }
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Supplier', element: 'Supplier' } }]
     @UI.selectionField: [{position: 4 }] 
      Supplier,
      SupplierName,
      CompanyCodeName,
      @Consumption.filter: { selectionType: #RANGE }
      PostingDate,
      PaymentAmount,
      Currency,
      
     Invoice_No,
     DocumentCurrency,
     @Semantics.amount.currencyCode: 'DocumentCurrency'
     TDS_Amount ,
     CompanyCodeCurrency,
     @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
     Net_Amount,
     Invoice_Amt,
     Doc_Date,
     Doc_No
 
}
