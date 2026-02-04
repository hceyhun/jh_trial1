@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Flight Information'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
define view entity ZI_Flight_JH_R
  as select from /dmo/flight
  association [1] to ZI_Carrier_JH_R as _Airline on $projection.CarrierId = _Airline.CarrierId

{
      @UI.facet: [{ position: 10,
                    type: #IDENTIFICATION_REFERENCE,
                    label: 'Flight Details',
                    purpose: #STANDARD }]
      @UI.lineItem: [{ position: 10 }]
      @UI.identification: [{ position: 10 }]
      @ObjectModel.text.association: '_Airline'
  key carrier_id     as CarrierId,
      @UI.lineItem: [{ position: 20 }]
  key connection_id  as ConnectionId,
      @UI.lineItem: [{ position: 30 }]
  key flight_date    as FlightDate,
      @UI.lineItem: [{ position: 40 }]
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price          as Price,
      currency_code  as CurrencyCode,
      @UI.lineItem: [{ position: 50 }]
      @Search.defaultSearchElement: true
      //      @Search.ranking: #HIGH
      @Search.fuzzinessThreshold: 0.8
      plane_type_id  as PlaneTypeId,
      @UI.lineItem: [{ position: 60 }]
      seats_max      as SeatsMax,
      @UI.lineItem: [{ position: 70 }]
      seats_occupied as SeatsOccupied,
      _Airline
}
