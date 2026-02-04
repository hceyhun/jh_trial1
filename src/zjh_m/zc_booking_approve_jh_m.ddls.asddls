@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Accept Projection View'
@Metadata.ignorePropagatedAnnotations: true
@UI.headerInfo: {
    typeName: 'Booking',
    typeNamePlural: 'Bookings',
    title: {
        type: #STANDARD,
        label: 'Booking',
        value: 'BookingId'
    }
}
define view entity ZC_BOOKING_APPROVE_JH_M
  as projection on ZI_BOOKING_JH_M
{
      @UI.facet: [{
          id: 'Booking',
          purpose: #STANDARD,
          position: 10,
          label: 'Booking',
          type: #IDENTIFICATION_REFERENCE
      }]
      @Search.defaultSearchElement: true
  key TravelId,
      @UI: {
      lineItem: [{ position: 20, importance: #HIGH }],
      identification: [{ position: 20 }]
      }
      @Search.defaultSearchElement: true
  key BookingId,
      @UI: { lineItem: [{ position: 30, importance: #HIGH }],
      identification: [{ position:  30  }]
      }
      BookingDate,
      @UI : { lineItem: [{ position: 40, importance: #HIGH }],
      identification: [{ position: 40  }],
      selectionField: [{ position: 10 }]
      }
      @ObjectModel.text.element: [ '_Customer.LastName' ]
      @Search.defaultSearchElement: true
      CustomerId,
      @UI: { lineItem: [{ position: 50, importance: #HIGH }],
      identification: [{ position: 50 }]}
      @ObjectModel.text.element: [ '_Carrier.Name' ]
      CarrierId,
      @UI: { lineItem: [{ position: 60 , importance: #HIGH }],
      identification: [{ position: 60 }]}
      ConnectionId,
      @UI: { lineItem: [{ position: 70 , importance: #HIGH }],
      identification: [{ position: 70 }]}
      FlightDate,
      @UI: { lineItem: [{ position: 80 , importance: #HIGH }],
      identification: [{ position: 80 }],
      textArrangement: #TEXT_LAST }
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
      CurrencyCode,
      @UI: { lineItem: [{ position: 90, importance: #HIGH, label: 'Status' }],
      identification: [{ position: 90  }],
      textArrangement: #TEXT_ONLY
      }
      @Consumption.valueHelpDefinition: [{ entity: {
          name: '/DMO/I_Booking_Status_VH',
          element: 'BookingStatus'
      } }]
      @ObjectModel.text.element: [ 'Text' ]
      BookingStatus,
      @UI.hidden: true
      _Status._Text.Text as Text : localized,
      @UI.hidden: true
      LastChangedAt,
      /* Associations */
      _BookingSuppl,
      _Carrier,
      _Connection,
      _Customer,
      _Status,
      _Travel : redirected to parent ZC_TRAVEL_APPROVE_JH_M
}
