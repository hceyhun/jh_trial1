@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Projection View Consumtion View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_BOOKING_JH_M
  as projection on ZI_BOOKING_JH_M
{
  key TravelId,
  key BookingId,
      BookingDate,
      @ObjectModel.text.element: [ 'CustomerName' ]
      CustomerId,
      _Customer.LastName as CustomerName,
      @ObjectModel.text.element: [ 'CarrierName' ]
      CarrierId,
      _Carrier.Name      as CarrierName,
      ConnectionId,
      FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
      CurrencyCode       as CurrencyCode,
      @ObjectModel.text.element: [ 'BookingStatusText' ]
      BookingStatus,
      _Status._Text.Text as BookingStatusText : localized,
      LastChangedAt,
      /* Associations */
      _BookingSuppl : redirected to composition child ZC_BOOKSUPPL_JH_M,
      _Carrier,
      _Connection,
      _Customer,
      _Status,
      _Travel       : redirected to parent ZC_TRAVEL_JH_M
}
