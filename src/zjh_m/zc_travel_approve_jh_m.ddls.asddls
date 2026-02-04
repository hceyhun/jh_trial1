@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Approve Prjection View'
@Metadata.ignorePropagatedAnnotations: true
@UI.headerInfo: {
    typeName: 'Travel',
    typeNamePlural: 'Travels',
    title: {
        type: #STANDARD,
        value: 'TravelId'
    }
}
@Search.searchable: true
define root view entity ZC_TRAVEL_APPROVE_JH_M
  provider contract transactional_query
  as projection on ZI_TRAVEL_JH_M
{

      @UI.facet: [
      {
          id: 'Travel',
          purpose: #STANDARD,
          position: 10,
          label: 'Travel',
          type: #IDENTIFICATION_REFERENCE
      },
      {
          id: 'Booking',
          purpose: #STANDARD,
          position: 20,
          label: 'Booking',
          type: #LINEITEM_REFERENCE,
          targetElement: '_Booking'
      }
      ]
      @UI: {
      lineItem: [{ position: 10, importance: #HIGH }],
      identification: [{ position: 10 }]
      }
      @Search.defaultSearchElement: true
  key TravelId,
      @UI : {
      lineItem: [{ position: 20 , importance: #HIGH }], selectionField: [{ position: 20 }],
      identification: [{ position: 20 }]
      }
      @Consumption.valueHelpDefinition: [{ entity: {
          name: '/DMO/I_Agency',
          element: 'AgencyID'
      }  }]
      @ObjectModel.text.element: ['AgencyName']
      @Search.defaultSearchElement: true
      AgencyId,
      @UI.hidden: true
      _Agency.Name       as AgencyName,
      @UI : {
      lineItem: [{ position: 30 , importance: #HIGH }],  selectionField: [{ position: 30 }],
      identification: [{ position: 30 }]
      }
      @Consumption.valueHelpDefinition: [{ entity: {
          name: '/DMO/I_Customer',
          element: 'CustomerID'
      } }]
      @ObjectModel.text.element: [ 'Name' ]
      @Search.defaultSearchElement: true
      CustomerId,
      @UI.hidden: true
      _Customer.LastName as Name,
      @UI.lineItem: [{ position: 40 }]
      BeginDate,
      @UI.lineItem: [{ position: 41 }]
      EndDate,
      @UI : {
      lineItem: [{ position: 42 }],
      identification: [{ position: 42 }]
      }
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @UI: { lineItem: [{ position: 43, importance: #MEDIUM }],
      identification: [{ position: 43, label: 'Total Price' }]
      }
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      @Consumption.valueHelpDefinition: [{ entity: {
          name: 'I_Currency',
          element: 'Currency'
      } }]
      CurrencyCode,
      @UI: {
      lineItem: [{ position: 45, importance: #MEDIUM }],
      identification: [{ position: 45 }]
      }
      Description,
      @UI : {
      lineItem: [
      { position: 15, importance: #HIGH },
      { type: #FOR_ACTION , dataAction: 'acceptTravel', label: 'Accept Travel' },
      { type: #FOR_ACTION , dataAction: 'rejectTravel', label: 'Reject Travel' }
      ],
      //      textArrangement: #TEXT_ONLY,
      selectionField: [{ position: 40 }],

      identification: [{ position: 15 },
      { type: #FOR_ACTION , dataAction: 'acceptTravel', label: 'Accept Travel' },
      { type: #FOR_ACTION , dataAction: 'rejectTravel', label: 'Reject Travel' }
      ]
      }
      @UI.textArrangement: #TEXT_ONLY
      @Consumption.valueHelpDefinition: [{ entity: {
          name: '/DMO/I_Overall_Status_VH',
          element: 'OverallStatus'
      } }]
      @ObjectModel.text.element: [ 'StatusText' ]
      OverallStatus,
      @UI.hidden: true
      _Status._Text.Text as StatusText : localized,
      @UI.hidden: true
      CreatedBy,
      @UI.hidden: true
      CreatedAt,
      @UI.hidden: true
      LastChangedBy,
      @UI.hidden: true
      LastChangedAt,
      /* Associations */
      _Agency,
      _Booking : redirected to composition child ZC_BOOKING_APPROVE_JH_M,
      _Currency,
      _Customer,
      _Status
}
