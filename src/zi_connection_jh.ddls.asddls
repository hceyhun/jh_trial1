@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Connection View CDS Data Model'
@Metadata.ignorePropagatedAnnotations: true

@UI.headerInfo: {
    typeName: 'Connection Screen',
    typeNamePlural: 'Connections'}
@Search.searchable: true
define view entity ZI_Connection_JH
  as select from /dmo/connection as Connection
  association [1..*] to ZI_Flight_JH_R  as _Flight  on  $projection.CarrierId    = _Flight.CarrierId
                                                    and $projection.ConnectionId = _Flight.ConnectionId
  association [1]    to ZI_Carrier_JH_R as _Airline on  $projection.CarrierId = _Airline.CarrierId
{
      @UI.facet: [{
      id: '10',
          purpose: #STANDARD,
          position: 10,
          label: 'Connection Detail',
          type: #IDENTIFICATION_REFERENCE
      },
      {
      id: '20',
          purpose: #STANDARD,
          position: 20,
          label: 'Flight Table',
          type: #LINEITEM_REFERENCE,
          targetElement: '_Flight'
                }
      ]
      @UI.lineItem: [{ position: 10,
                       label: 'Airline' } ]
      @UI.selectionField: [{ position: 10 }]

      @UI.identification: [{ position: 10 , label: 'Airline'}]
      @ObjectModel.text.association: '_Airline'
      @Search.defaultSearchElement: true
  key carrier_id      as CarrierId,
      @UI.lineItem: [{ position: 20}]
      @UI.identification: [{ position: 20 , label: 'Flight No'}]
      @Search.defaultSearchElement: true
  key connection_id   as ConnectionId,
      @UI.lineItem: [{ position: 30}]
      @UI.selectionField: [{ position: 20 }]
      @UI.identification: [{ position: 30 }]
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{
          entity: {
              name: 'ZI_Airport_JH_VH',
              element: 'AirportId'

      }}]
      @EndUserText.label: 'From Airoprt ID'
      airport_from_id as AirportFromId,
      @UI.lineItem: [{ position: 40}]
      @UI.selectionField: [{ position: 30 }]
      @UI.identification: [{ position: 40 }]
      @Search.defaultSearchElement: true
      @EndUserText.label: 'To Airport ID'
      airport_to_id   as AirportToId,
      @UI.lineItem: [{ position: 50}]
      @UI.identification: [{ position: 50 }]
      departure_time  as DepartureTime,
      @UI.lineItem: [{ position: 60}]
      @UI.identification: [{ position: 60 }]
      arrival_time    as ArrivalTime,
      @UI.lineItem: [{ position: 70 }]
      @Semantics.quantity.unitOfMeasure: 'DistanceUnit'
      @UI.identification: [{ position: 70 }]
      distance        as Distance,
      distance_unit   as DistanceUnit,
      //      Assosiations
      @Search.defaultSearchElement: true
      _Flight,
      @Search.defaultSearchElement: true
      _Airline
}
