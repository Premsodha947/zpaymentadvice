@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS OF PAYMENT_ADVICE_ITEM_1'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_PAYMENT_ADVICE_ITEM_1 as select distinct from  I_OperationalAcctgDocItem as A



{ 

key A.AccountingDocument,
A.HouseBankAccount,
  A.TransactionCurrency,
 @Aggregation.default: #SUM
@Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
   A.AmountInTransactionCurrency as NetAmount

}
where  A.HouseBankAccount = 'SRC1' or A.HouseBankAccount = 'HSB1' or   A.HouseBankAccount = 'HSB2' or A.HouseBankAccount = 'IDI1'
      or A.HouseBankAccount = 'KKB1'  or A.HouseBankAccount = 'SBI1'  or A.HouseBankAccount = 'SBI2'  or A.HouseBankAccount = 'SBI3'
        or A.HouseBankAccount = 'SRC2'

