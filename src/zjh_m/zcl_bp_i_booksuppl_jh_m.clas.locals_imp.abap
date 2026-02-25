CLASS lhc_zi_booksuppl_jh_m DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS determineTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_booksuppl_jh_m~determineTotalPrice.

ENDCLASS.

CLASS lhc_zi_booksuppl_jh_m IMPLEMENTATION.

  METHOD determineTotalPrice.

    DATA : it_travel TYPE STANDARD TABLE OF zi_travel_jh_m
                     WITH UNIQUE HASHED KEY key COMPONENTS TravelId.
    it_travel = CORRESPONDING #( keys DISCARDING DUPLICATES MAPPING TravelId = TravelId ).
    MODIFY ENTITIES OF zi_travel_jh_m IN LOCAL MODE
    ENTITY zi_travel_jh_m
    EXECUTE recalcTotal
    FROM CORRESPONDING #( it_travel ).

  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
