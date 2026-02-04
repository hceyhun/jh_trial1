CLASS lhc_ZI_BOOKING_JH_M DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS earlynumbering_cba_Bookingsupp FOR NUMBERING
      IMPORTING entities FOR CREATE zi_booking_jh_m\_Bookingsuppl.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ZI_BOOKING_JH_M RESULT result.

ENDCLASS.

CLASS lhc_ZI_BOOKING_JH_M IMPLEMENTATION.

  METHOD earlynumbering_cba_Bookingsupp.
    DATA: lv_max_bookingsuppl TYPE /dmo/booking_supplement_id.
    READ ENTITIES OF zi_travel_jh_m IN LOCAL MODE
    ENTITY zi_booking_jh_m BY \_BookingSuppl
    FROM CORRESPONDING #( entities )
    LINK DATA(lt_Link_booking).

    LOOP AT entities INTO DATA(ls_booking_entity) GROUP BY ls_booking_entity-%tky.
      lv_max_bookingsuppl = REDUCE #( INIT lv_max = CONV /dmo/booking_supplement_id( '0' )
                                      FOR ls_link_booking IN lt_link_booking USING KEY entity
                                      WHERE (     source-TravelId  = ls_booking_entity-TravelId
                                              AND source-BookingId = ls_booking_entity-BookingId )
                                      NEXT lv_max = COND /dmo/booking_supplement_id( WHEN lv_max < ls_link_booking-target-BookingSupplementId
                                      THEN ls_link_booking-target-BookingSupplementId
                                      ELSE lv_max )
                                     ).
      lv_max_bookingsuppl = REDUCE #( INIT lv_max = lv_max_bookingsuppl
                          FOR ls_booking_root IN entities USING KEY entity
                          WHERE (     TravelId  = ls_booking_entity-TravelId
                                  AND BookingId = ls_booking_entity-BookingId )
                          FOR ls_bookingsuppl IN ls_booking_root-%target
                          NEXT lv_max = COND /dmo/booking_supplement_id( WHEN lv_max < ls_bookingsuppl-BookingSupplementId
                                       THEN ls_bookingsuppl-BookingSupplementId
                                       ELSE lv_max )
                                        ).
      LOOP AT entities INTO DATA(ls_booking) USING KEY entity
                  WHERE TravelId = ls_booking_entity-TravelId
                  AND BookingId = ls_booking_entity-BookingId.
        LOOP AT ls_booking-%target INTO DATA(ls_bookingsupp).
          APPEND CORRESPONDING #( ls_bookingsupp ) TO mapped-zi_booksuppl_jh_m ASSIGNING FIELD-SYMBOL(<mapped_bookingsupl>).
          IF  ls_bookingsupp-BookingSupplementId IS INITIAL.
            lv_max_bookingsuppl += 1.
            <mapped_bookingsupl>-BookingSupplementId = lv_max_bookingsuppl.
          ENDIF.
        ENDLOOP.
      ENDLOOP.


    ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.
