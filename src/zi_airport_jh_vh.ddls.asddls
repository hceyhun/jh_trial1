@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help for AIrport'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
define view entity ZI_Airport_JH_VH
  as select from /dmo/airport
{
      @Search.defaultSearchElement: true
  key airport_id as AirportId,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      name       as Name,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      city       as City,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      country    as Country
}
