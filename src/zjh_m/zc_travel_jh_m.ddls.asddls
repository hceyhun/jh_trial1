 @AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Prjection View Consumtion View'
//@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_TRAVEL_JH_M
  provider contract transactional_query
  as projection on ZI_TRAVEL_JH_M
{
  key TravelId,
      @ObjectModel.text.element: [ 'AgencyName' ]
      AgencyId,
      _Agency.Name       as AgencyName,
      @ObjectModel.text.element: [ 'CustomerName' ]
      CustomerId,
      _Customer.LastName as CustomerName,
      BeginDate,
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      CurrencyCode       as CurrencyCode,
      Description,
      @ObjectModel.text.element: [ 'StatusText' ]
      OverallStatus,
      _Status._Text.Text as StatusText : localized,
      //      CreatedBy,
      //      CreatedAt,
      //      LastChangedBy,
      LastChangedAt,
      /* Associations */
      _Booking : redirected to composition child ZC_BOOKING_JH_M,
      _Agency,
      _Currency,
      _Customer,
      _Status
}
