class ZCL_MMPUR_READ_ORG_DATA definition
  public
  final
  create public .

public section.

  types:
    TT_PT1222 type TABLE OF pt1222 .

  class-data MV_USER type SYUNAME .

  class-methods READ_ATTRIBUTE
    importing
      !IV_ATTRIBUTE_NAME type OM_ATTRIB
      !IV_USER type SYUNAME
    exporting
      !EV_VALUE type OM_ATTRVAL .
  class-methods READ_ATTRIBUTE_MULTIPLE
    importing
      !IV_ATTRIBUTE_NAME type OM_ATTRIB
      !IV_USER type SYUNAME
    exporting
      !ET_VALUE type TT_PT1222 .
protected section.
private section.
ENDCLASS.



CLASS ZCL_MMPUR_READ_ORG_DATA IMPLEMENTATION.


  METHOD read_attribute.
    DATA : lo_user     TYPE REF TO /cdlg/cl_user,
           ls_swhactor TYPE swhactor.

    DATA:
          ls_attrib         TYPE pt1222,
          lt_attribute_name TYPE TABLE OF pt1222,
          lt_attrib         TYPE TABLE OF pt1222,
          lv_lines          TYPE i.

    mv_user = iv_user.

* Get the user utility
    CREATE OBJECT lo_user
      EXPORTING
        iv_user = iv_user.
* Get the user position (S)
    CALL METHOD lo_user->get_pos_from_us
      RECEIVING
        rs_swhactor = ls_swhactor.

    CHECK ls_swhactor IS NOT INITIAL.

    TRY.
        CALL FUNCTION 'RH_OM_ATTRIBUTES_READ'
          EXPORTING
            otype            = ls_swhactor-otype
            objid            = ls_swhactor-objid
            scenario         = 'SSP'
          TABLES
            attrib           = lt_attrib
          EXCEPTIONS
            no_active_plvar  = 1
            no_attributes    = 2
            no_values        = 3
            object_not_found = 4
            OTHERS           = 5.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        LOOP AT lt_attrib INTO ls_attrib WHERE attrib = iv_attribute_name.
          APPEND ls_attrib TO lt_attribute_name.
        ENDLOOP.

        CLEAR ls_attrib.

        DESCRIBE TABLE lt_attribute_name LINES lv_lines.

        IF lv_lines = 1. "Single Attribute
          READ TABLE lt_attribute_name INTO ls_attrib INDEX 1.
          IF sy-subrc EQ 0 AND ls_attrib-high IS INITIAL.
            ev_value = ls_attrib-low.
          ENDIF.
        ELSE.
          LOOP AT lt_attribute_name INTO ls_attrib WHERE defaultval = 'X'.
            IF sy-subrc EQ 0.
              ev_value = ls_attrib-low.
            ENDIF.
          ENDLOOP.
        ENDIF.
      CATCH cx_root .
    ENDTRY.

  ENDMETHOD.


  METHOD read_attribute_multiple.
    DATA : lo_user     TYPE REF TO /cdlg/cl_user,
           ls_swhactor TYPE swhactor.

    DATA:
      ls_attrib         TYPE pt1222,
      lt_attribute_name TYPE TABLE OF pt1222,
      lt_attrib         TYPE Standard TABLE OF pt1222 WITH NON-UNIQUE KEY attrib,
      lv_lines          TYPE i.

* get the user utility
    CREATE OBJECT lo_user
      EXPORTING
        iv_user = iv_user.
* Get the user position (S)
    CALL METHOD lo_user->get_pos_from_us
      RECEIVING
        rs_swhactor = ls_swhactor.

    CHECK ls_swhactor IS NOT INITIAL.

    TRY.

        CALL FUNCTION 'RH_OM_ATTRIBUTES_READ'
          EXPORTING
*           PLVAR            =
            otype            = ls_swhactor-otype
            objid            = ls_swhactor-objid
            scenario         = 'SSP'
*           SELDATE          = SY-DATUM
*           WITH_INVISIBLE   = ' '
*           NO_INHERIT       = ' '
*           BUFFER_REFRESH   = ' '
*           CONVERT_OUT      = ' '
*           ONLY_FOR_DISPLAY = ' '
          TABLES
            attrib           = lt_attrib
*           ATTRIB_EXT       =
          EXCEPTIONS
            no_active_plvar  = 1
            no_attributes    = 2
            no_values        = 3
            object_not_found = 4
            OTHERS           = 5.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        loop at lt_attrib into ls_attrib WHERE attrib = iv_attribute_name.
          APPEND ls_attrib TO lt_attribute_name.
        ENDLOOP.

        CLEAR ls_attrib.

*      CATCH cx_root .
    ENDTRY.

*    DESCRIBE TABLE lt_attribute_name LINES lv_lines.

    et_value = lt_attribute_name.

*    IF lv_lines = 1. "Single Attribute
*    ELSE.
*      et_value = lt_attribute_name.
*    ENDIF.

  ENDMETHOD.
ENDCLASS.
