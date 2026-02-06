CLASS lhc_ZI_TRAVEL_JH_M DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys
                  REQUEST requested_authorizations
                  FOR zi_travel_jh_m
      RESULT    result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations
      FOR zi_travel_jh_m
      RESULT result.

    METHODS accepttravel FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_jh_m~accepttravel RESULT result.

    METHODS rejecttravel FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_jh_m~rejecttravel RESULT result.

    METHODS copytravel FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_jh_m~copytravel.

    METHODS recalctotal FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_jh_m~recalctotal.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_travel_jh_m RESULT result.

    METHODS validatecustomerid FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_travel_jh_m~validatecustomerid.

    METHODS earlynumbering_cba_booking FOR NUMBERING
      IMPORTING entities FOR CREATE zi_travel_jh_m\_booking.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE zi_travel_jh_m.


ENDCLASS.

CLASS lhc_ZI_TRAVEL_JH_M IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA(lt_ent) = entities.
    DELETE lt_ent WHERE TravelId IS NOT INITIAL.
    DATA(lv_lines) = lines( lt_ent ).
    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
*    ignore_buffer     =
            nr_range_nr       = '01'
            object            = '/DMO/TRV_M'
            quantity          = CONV #( lv_lines )
*    subobject         =
*    toyear            =
          IMPORTING
            number            = DATA(lv_lnum)
            returncode        = DATA(lv_code)
            returned_quantity = DATA(lv_qty)
        ).
      CATCH cx_nr_object_not_found.
      CATCH cx_number_ranges INTO DATA(lo_error).
        LOOP AT lt_ent INTO DATA(ls_ent).
          DATA : LS_failed LIKE LINE OF  failed-zi_travel_jh_m.
          DATA : LS_reported LIKE LINE OF  reported-zi_travel_jh_m.
          MOVE-CORRESPONDING ls_ent TO ls_failed.
          MOVE-CORRESPONDING ls_ent TO ls_reported.
          ls_reported-%msg = lo_error.
*          ls_failed-%cid = ls_ent-%cid.
*          ls_failed-%cid = ls_ent-%key.
          APPEND VALUE #( %cid = ls_ent-%cid
                          %key = ls_ent-%key ) TO failed-zi_travel_jh_m.
          APPEND ls_failed TO failed-zi_travel_jh_m.
          APPEND ls_reported TO reported-zi_travel_jh_m.

        ENDLOOP.
    ENDTRY.
    DATA(lv_current) = lv_lnum - lv_qty.
    LOOP AT lt_ent INTO ls_ent.
      lv_current += 1.
      DATA: ls_mapped LIKE LINE OF mapped-zi_travel_jh_m.
      ls_mapped-%cid = ls_ent-%cid.
      ls_mapped-TravelId = lv_current.
      APPEND ls_mapped TO mapped-zi_travel_jh_m.

    ENDLOOP.


  ENDMETHOD.



  METHOD earlynumbering_cba_Booking.
    DATA : lv_max_booking TYPE /dmo/booking_id.

    READ ENTITIES OF zi_travel_jh_m IN LOCAL MODE
    ENTITY zi_travel_jh_m BY \_Booking
    FROM CORRESPONDING #( entities )
    LINK DATA(lt_link_data).

    LOOP AT entities INTO DATA(ls_group_entity) GROUP BY ls_group_entity-TravelId.
      CLEAR lv_max_booking.
      lv_max_booking = REDUCE #( INIT lv_max = CONV /dmo/booking_id( '0' )
                                FOR ls_link IN lt_link_data USING KEY entity
                                WHERE ( source-TravelId = ls_group_entity-TravelId )
                                NEXT lv_max = COND  /dmo/booking_id( WHEN lv_max < ls_link-target-BookingId
                                                                     THEN ls_link-target-BookingId
                                                                     ELSE lv_max ) ).
      lv_max_booking = REDUCE #( INIT lv_max = lv_max_booking
                                 FOR ls_entity IN entities USING KEY entity
                                 WHERE ( TravelId = ls_group_entity-TravelId )
                                 FOR ls_booking IN ls_entity-%target
                                 NEXT lv_max = COND  /dmo/booking_id( WHEN lv_max < ls_booking-BookingId
                                                                       THEN ls_booking-BookingId
                                                                       ELSE lv_max ) ).

      LOOP AT entities INTO DATA(ls_entities)
                       USING KEY entity
                       WHERE TravelId = ls_group_entity-TravelId.


        LOOP AT ls_entities-%target INTO DATA(ls_booking_child).

          APPEND CORRESPONDING #( ls_booking_child ) TO mapped-zi_booking_jh_m
            ASSIGNING FIELD-SYMBOL(<ls_booking_new>).

          IF ls_booking_child-BookingId IS INITIAL.
            lv_max_booking += 10.
            <ls_booking_new>-BookingId = lv_max_booking.
          ENDIF.
        ENDLOOP.

      ENDLOOP.
    ENDLOOP.


  ENDMETHOD.

  METHOD acceptTravel.

    MODIFY ENTITIES OF zi_travel_jh_m IN LOCAL MODE
    ENTITY zi_travel_jh_m
    UPDATE FIELDS ( OverallStatus )
    WITH VALUE #( FOR ls_key IN keys ( %tky = ls_key-%tky
                                       OverallStatus = 'A' ) ).

    READ ENTITIES OF zi_travel_jh_m IN LOCAL MODE
    ENTITY zi_travel_jh_m
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    result = VALUE #( FOR ls_result IN lt_result ( %tky = ls_result-%tky
                                                   %param = ls_result ) ).
  ENDMETHOD.

  METHOD copyTravel.

    DATA : it_travel_insert   TYPE TABLE FOR CREATE zi_travel_jh_m,
           it_booking_insert  TYPE TABLE FOR CREATE zi_travel_jh_m\_Booking,
           it_booksupp_insert TYPE TABLE FOR CREATE zi_booking_jh_m\_BookingSuppl.

    READ TABLE keys INTO DATA(ls_key_new) WITH KEY %cid = ' '.
    ASSERT ls_key_new IS INITIAL.

    READ ENTITIES OF zi_travel_jh_m IN LOCAL MODE
    ENTITY zi_travel_jh_m
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel_read)
    FAILED DATA(lt_failed_read).

    READ ENTITIES OF zi_travel_jh_m IN LOCAL MODE
    ENTITY zi_travel_jh_m BY \_Booking
    ALL FIELDS WITH CORRESPONDING #( lt_travel_read )
    RESULT DATA(lt_booking_read).

    READ ENTITIES OF zi_travel_jh_m IN LOCAL MODE
    ENTITY zi_booking_jh_m BY \_BookingSuppl
    ALL FIELDS WITH CORRESPONDING #( lt_booking_read )
    RESULT DATA(lt_booksuppl_read).

    LOOP AT lt_travel_read INTO DATA(ls_travel_read).
*      APPEND INITIAL LINE TO it_travel_insert ASSIGNING FIELD-SYMBOL(<ls_travel_insert>).
*      <ls_travel_insert>-%cid = keys[ KEY entity TravelId = ls_travel_read-TravelId  ]-%cid.
*      <ls_travel_insert>-%data = CORRESPONDING #( ls_travel_read EXCEPT TravelId ).

      APPEND VALUE #( %cid = keys[ KEY entity TravelId = ls_travel_read-TravelId ]-%cid
                      %data = CORRESPONDING #( ls_travel_read EXCEPT travelid ) )
                      TO it_travel_insert ASSIGNING FIELD-SYMBOL(<ls_travel_insert>).

*      APPEND INITIAL LINE TO it_booking_insert ASSIGNING FIELD-SYMBOL(<ls_booking_insert>).
*      <ls_booking_insert>-%cid_ref = <ls_travel_insert>-%cid.

      <ls_travel_insert>-BeginDate = cl_abap_context_info=>get_system_date( ).
      <ls_travel_insert>-EndDate = cl_abap_context_info=>get_system_date( ) + 11.
      <ls_travel_insert>-OverallStatus = 'O'.

      APPEND VALUE #( %cid_ref = <ls_travel_insert>-%cid )
      TO it_booking_insert ASSIGNING FIELD-SYMBOL(<ls_booking_insert>).

      LOOP AT lt_booking_read INTO DATA(ls_booking_read)
                       USING KEY entity
                       WHERE TravelId = ls_travel_read-TravelId.

*        APPEND INITIAL LINE TO <ls_booking_insert>-%target ASSIGNING FIELD-SYMBOL(<ls_booking_new>).
*        <ls_booking_new>-%cid = <ls_travel_insert>-%cid && ls_booking_read-BookingId.
*        <ls_booking_new>-%data = CORRESPONDING #( ls_booking_read EXCEPT TravelId ).

        APPEND VALUE #( %cid = <ls_travel_insert>-%cid && ls_booking_read-BookingId
                        %data = CORRESPONDING #( ls_booking_read EXCEPT TravelId ) )
          TO <ls_booking_insert>-%target ASSIGNING FIELD-SYMBOL(<ls_booking_new>).
        <ls_booking_new>-BookingStatus = 'N'.

*        APPEND INITIAL LINE TO it_booksupp_insert ASSIGNING FIELD-SYMBOL(<ls_booksuppl_insert>).
*        <ls_booksuppl_insert>-%cid_ref = <ls_booking_new>-%cid.

        APPEND VALUE #( %cid_ref = <ls_booking_new>-%cid )
        TO it_booksupp_insert ASSIGNING FIELD-SYMBOL(<ls_booksuppl_insert>).

        LOOP AT lt_booksuppl_read INTO DATA(ls_booksuppl_read)
                                USING KEY entity
                                WHERE TravelId  = ls_travel_read-TravelId
                                AND BookingId = ls_booking_read-BookingId.

*          APPEND INITIAL LINE TO <ls_booksuppl_insert>-%target ASSIGNING FIELD-SYMBOL(<ls_booksuppl_new>).
*          <ls_booksuppl_new>-%cid = <ls_travel_insert>-%cid && ls_booking_read-BookingId && ls_booksuppl_read-BookingSupplementId.
*          <ls_booking_new>-%data = CORRESPONDING #( ls_booksuppl_read EXCEPT TravelId BookingId ).

          APPEND VALUE #( %cid = <ls_travel_insert>-%cid && ls_booking_read-BookingId && ls_booksuppl_read-BookingSupplementId
                          %data = CORRESPONDING #( ls_booksuppl_read EXCEPT TravelId BookingId ) )
                        TO <ls_booksuppl_insert>-%target ASSIGNING FIELD-SYMBOL(<ls_booksuppl_new>).

        ENDLOOP.

      ENDLOOP.

    ENDLOOP.

    MODIFY ENTITIES OF zi_travel_jh_m IN LOCAL MODE
    ENTITY zi_travel_jh_m
    CREATE
    FIELDS ( AgencyId CustomerId BeginDate EndDate BookingFee TotalPrice CurrencyCode Description OverallStatus )
    WITH it_travel_insert
        ENTITY zi_travel_jh_m
        CREATE BY \_Booking
        FIELDS ( BookingId BookingDate CustomerId CarrierId ConnectionId FlightDate FlightPrice CurrencyCode BookingStatus )
        WITH it_booking_insert
            ENTITY zi_booking_jh_m
            CREATE BY \_BookingSuppl
            FIELDS ( BookingSupplementId SupplementId Price CurrencyCode )
            WITH it_booksupp_insert
    MAPPED DATA(it_mapped).

    mapped-zi_travel_jh_m = it_mapped-zi_travel_jh_m.

  ENDMETHOD.

  METHOD recalcTotal.
  ENDMETHOD.

  METHOD rejectTravel.

    MODIFY ENTITIES OF zi_travel_jh_m IN LOCAL MODE
    ENTITY zi_travel_jh_m
    UPDATE FIELDS ( OverallStatus )
    WITH VALUE #( FOR ls_key IN keys ( %tky = ls_key-%tky
                                       OverallStatus = 'X' ) ).

    READ ENTITIES OF zi_travel_jh_m IN LOCAL MODE
    ENTITY zi_travel_jh_m
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    result = VALUE #( FOR ls_result IN lt_result ( %tky = ls_result-%tky
                                                   %param = ls_result ) ).

  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zi_travel_jh_m IN LOCAL MODE
    ENTITY zi_travel_jh_m
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).

    result = VALUE #( FOR ls_travel IN lt_travel
                    ( %tky = ls_travel-%tky
                    %features-%action-acceptTravel = COND #( WHEN ls_travel-OverallStatus = 'A'
                                                             THEN if_abap_behv=>fc-o-disabled
                                                             ELSE if_abap_behv=>fc-o-enabled  )
                    %features-%action-rejectTravel = COND #( WHEN ls_travel-OverallStatus = 'X'
                                                             THEN if_abap_behv=>fc-o-disabled
                                                             ELSE if_abap_behv=>fc-o-enabled  )
                    %features-%assoc-_Booking = COND #( WHEN ls_travel-OverallStatus = 'X'
                                                             THEN if_abap_behv=>fc-o-disabled
                                                             ELSE if_abap_behv=>fc-o-enabled  )
                    )
    ).



  ENDMETHOD.

  METHOD validateCustomerID.
    READ ENTITY IN LOCAL MODE zi_travel_jh_m
    FIELDS ( CustomerId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).

    DATA : lt_cust TYPE SORTED TABLE OF /DMO/I_Customer WITH UNIQUE KEY CustomerID.

    lt_cust = CORRESPONDING #( lt_travel DISCARDING DUPLICATES MAPPING CustomerID = CustomerId ).
    DELETE lt_cust WHERE CustomerID IS INITIAL.

    SELECT FROM /DMO/I_Customer
    FIELDS CustomerID
    FOR ALL ENTRIES IN @lt_cust
    WHERE CustomerID = @lt_cust-CustomerID
    INTO TABLE @DATA(lt_cust_db).

    LOOP AT lt_travel INTO DATA(ls_travel).
      IF ls_travel-CustomerId IS INITIAL OR
         NOT line_exists( lt_cust_db[ CustomerID = ls_travel-CustomerId ] ).
*        failed-zi_travel_jh_m = VALUE #( FOR ls_key IN keys ( %tky = ls_travel-%tky ) ).
        APPEND VALUE #( %tky = ls_travel-%tky ) TO failed-zi_travel_jh_m.
        APPEND VALUE #( %tky = ls_travel-%tky
                        %msg = NEW /dmo/cm_flight_messages(
          textid                = /dmo/cm_flight_messages=>customer_unkown
*          attr1                 =
*          attr2                 =
*          attr3                 =
*          attr4                 =
*          previous              =
*          travel_id             =
*          booking_id            =
*          booking_supplement_id =
*          agency_id             =
          customer_id           = ls_travel-CustomerId
*          carrier_id            =
*          connection_id         =
*          supplement_id         =
*          begin_date            =
*          end_date              =
*          booking_date          =
*          flight_date           =
*          status                =
*          currency_code         =
          severity              = if_abap_behv_message=>severity-error
*          uname                 =
        )
        %element-CustomerId = if_abap_behv=>mk-on
                       ) TO reported-zi_travel_jh_m.
      ENDIF.
    ENDLOOP.



  ENDMETHOD.

ENDCLASS.
