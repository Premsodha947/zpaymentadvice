@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PAYMENT ADVICE CDS'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_PAYMENT_ADVICE as select from I_OperationalAcctgDocItem as A
left outer join I_Supplier as B on B.Supplier = A.Supplier
left outer join I_BusinessPartner as c on c.BusinessPartner = A.Supplier
left outer join I_BusinessPartnerBank as d on d.BusinessPartner = A.Supplier
//left outer join I_SupplierBankDetails as C on C.Supplier = A.Supplier 
//left outer join I_Bank as D on  D.Bank = C.Bank 
left outer join I_JournalEntry as L on (L.AccountingDocument = A.AccountingDocument)


{

key A.AccountingDocument,
A.HouseBankAccount,
  A.CompanyCode,
  A.AccountingDocumentType as TYPEOFACCOUNTING,
  
  A.FiscalYear,
  A.Plant,
  A.Supplier as VendorNo,
  A.DocumentItemText as remark,
  
  c.BusinessPartnerFullName as VendorName,
//  B.SupplierName as VendorName,
  concat_with_space(
    concat_with_space(
        concat_with_space(
            concat_with_space( B.StreetName, B.CityName, 1 ),
            B.Region, 1
        ),
        B.Country, 1
    ),
    B.PostalCode, 1
) as VendorAddress,

//   concat(concat(concat(concat(B.StreetName, B.CityName), B.Region), B.Country), B.PostalCode) as  VendorAddress,
  A.PostingDate as Paymentdate,
  
  concat_with_space( coalesce( d.BankName, '' )
                 , coalesce( d.BankAccount, '' )
                 , 1 ) as Bankname,
  

// concat( d.BankName , d.BankAccount ) as Bankname,
 L.DocumentReferenceID as CHQNo
 
 
 
}
where A.FinancialAccountType = 'K'
