class ZCL_MMPUR_CAT_CLL_ENRCH definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_MMPUR_CAT_CALL_ENRICH .

  constants VERSION type VERSION value 000001 ##NO_TEXT.
protected section.
private section.

  data INSTANCE_BADI_TABLE type SXRT_EXIT_TAB .
  data INSTANCE_FLT_CACHE type SXRT_FLT_CACHE_TAB .
ENDCLASS.



CLASS ZCL_MMPUR_CAT_CLL_ENRCH IMPLEMENTATION.


  method IF_MMPUR_CAT_CALL_ENRICH~CAT_CALL_ENRICH.
     CLASS CL_EXIT_MASTER DEFINITION LOAD.
  DATA: EXIT_OBJ_TAB TYPE SXRT_EXIT_TAB,
        old_imp_class type seoclsname.
  DATA: exitintf TYPE REF TO IF_MMPUR_CAT_CALL_ENRICH,
        wa_flt_cache TYPE sxrt_flt_cache_struct,
        flt_name TYPE FILTNAME.

BREAK-POINT.

  FIELD-SYMBOLS:
    <exit_obj>       TYPE SXRT_EXIT_TAB_STRUCT,
    <flt_cache_line> TYPE sxrt_flt_cache_struct.




  READ TABLE INSTANCE_FLT_CACHE
         WITH KEY flt_name    = flt_name
                  method_name = 'CAT_CALL_ENRICH'
         TRANSPORTING NO FIELDS.
  IF sy-subrc NE 0.
    LOOP AT INSTANCE_BADI_TABLE ASSIGNING <exit_obj>
         WHERE INTER_NAME   = 'IF_MMPUR_CAT_CALL_ENRICH'
           AND METHOD_NAME  = 'CAT_CALL_ENRICH'.
      APPEND <exit_obj> TO EXIT_OBJ_TAB.
    ENDLOOP.
TEST-SEAM instance.
END-TEST-SEAM.
    IF sy-subrc = 4.
      CALL METHOD CL_EXIT_MASTER=>CREATE_OBJ_BY_INTERFACE_FILTER
         EXPORTING
            INTER_NAME   = 'IF_MMPUR_CAT_CALL_ENRICH'
            METHOD_NAME  = 'CAT_CALL_ENRICH'
         IMPORTING
            exit_obj_tab = exit_obj_tab.


      APPEND LINES OF exit_obj_tab TO INSTANCE_BADI_TABLE.
    ENDIF.


    wa_flt_cache-flt_name    = flt_name.
    wa_flt_cache-valid       = sxrt_false.
    wa_flt_cache-method_name = 'CAT_CALL_ENRICH'.


    LOOP at exit_obj_tab ASSIGNING <exit_obj>
        WHERE ACTIVE = SXRT_TRUE
          AND NOT obj IS INITIAL.

      CHECK <exit_obj>-imp_class NE old_imp_class.


        MOVE-CORRESPONDING <exit_obj> TO wa_flt_cache.
        wa_flt_cache-valid = sxrt_true.
        INSERT wa_flt_cache INTO TABLE INSTANCE_FLT_CACHE.
        old_imp_class = <exit_obj>-imp_class.

    ENDLOOP.
    IF wa_flt_cache-valid = sxrt_false.
      INSERT wa_flt_cache INTO TABLE INSTANCE_FLT_CACHE.
    ENDIF.
  ENDIF.
  LOOP AT INSTANCE_FLT_CACHE ASSIGNING <flt_cache_line>
       WHERE flt_name    = flt_name
         AND valid       = sxrt_true
         AND method_name = 'CAT_CALL_ENRICH'.


    CALL FUNCTION 'PF_ASTAT_OPEN'
       EXPORTING
           OPENKEY = 'UFf54R29v4k7iGzRwW0qOG'
           TYP     = 'UE'.

    CASE <flt_cache_line>-imp_switch.
      WHEN 'VSR'.
        DATA: exc        TYPE sfbm_xcptn,                  "#EC NEEDED
              data_ref   TYPE REF TO DATA.

        IF <flt_cache_line>-eo_object is initial.
          CALL METHOD ('CL_FOBU_METHOD_EVALUATION')=>load
               EXPORTING
                  im_class_name     = <flt_cache_line>-imp_class
                  im_interface_name = 'IF_MMPUR_CAT_CALL_ENRICH'
                  im_method_name    = 'CAT_CALL_ENRICH'
               RECEIVING
                  re_fobu_method    = <flt_cache_line>-eo_object
               EXCEPTIONS
                  not_found         = 1
                  OTHERS            = 2.
          IF sy-subrc = 2.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
          CHECK sy-subrc = 0.
        ENDIF.

        CLEAR data_ref.
        GET REFERENCE OF IS_CAT_ENTITY INTO data_ref.
        CALL METHOD <flt_cache_line>-eo_object->set_parameter(
            im_parmname = 'IS_CAT_ENTITY'
            im_value    = data_ref ).

        CLEAR data_ref.
        GET REFERENCE OF CT_POST_VALUES INTO data_ref.
        CALL METHOD <flt_cache_line>-eo_object->set_parameter(
            im_parmname = 'CT_POST_VALUES'
            im_value    = data_ref ).

        CALL METHOD <flt_cache_line>-eo_object->evaluate
             IMPORTING
                ex_exception    = exc
             EXCEPTIONS
                raise_exception = 1
                OTHERS          = 2.
        IF sy-subrc = 2.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

        ENDIF.
      WHEN OTHERS.
        EXITINTF ?= <flt_cache_line>-OBJ.
        CALL METHOD EXITINTF->CAT_CALL_ENRICH
           EXPORTING
             IS_CAT_ENTITY = IS_CAT_ENTITY
           CHANGING
             CT_POST_VALUES = CT_POST_VALUES.


    ENDCASE.


    CALL FUNCTION 'PF_ASTAT_CLOSE'
       EXPORTING
           OPENKEY = 'UFf54R29v4k7iGzRwW0qOG'
           TYP     = 'UE'.
  ENDLOOP.
  endmethod.
ENDCLASS.
