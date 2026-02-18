@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Main Cds view for Payment advice'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_Payment_Header as select from ZI_JournalEntry_Header as Header

left outer join I_Supplier as _supplier on Header.Supplier = _supplier.Supplier

left outer join I_JournalEntry as _journal on _journal.AccountingDocument = Header.AccountingDocument

association [1..*] to ZC_Payment_Item as _item on Header.AccountingDocument = _item.AccountingDocument
                                               and Header.CompanyCode = _item.CompanyCode
                                              and Header.FiscalYear = _item.FiscalYear
                                       //       and Header.LedgerGLLineItem = _item.LedgerGLLineItem
{
     @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCode', element: 'CompanyCode' } }]
    key Header.CompanyCode as CompanyCode,
    key Header.FiscalYear as FiscalYear,
//    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_JournalRTGS_VH', element: 'AccountingDocument' } }]
    key Header.AccountingDocument as AccountingDocument,
     @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Supplier', element: 'Supplier' } }]
    key Header.Supplier as Supplier,
//    Header.LedgerGLLineItem,
    case 
    when Header.AccountingDocumentType = 'UE'
     then _journal.DocumentDate
     else Header.DocumentDate 
     end as Documentdate,
//    @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Supplier', element: 'Supplier' } }]
//    _supplier.Supplier as Supplier,
    _supplier.SupplierName as Name,
    _supplier.BPAddrStreetName as Street,
    _supplier.CityName as City,
    _supplier.PostalCode as Postalcode,
    _supplier.Country as Country,
    _supplier.Region as Region,
    concat_with_space(_supplier.BPAddrStreetName , concat_with_space(_supplier.Region , _supplier.Country , 1), 1) as Address,
    
    _journal.DocumentReferenceID as CHQNo,
    
    //Association
    _item
    
    
} where Header.Supplier is not initial
