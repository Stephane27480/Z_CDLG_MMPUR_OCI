
CLASS lcl_ex_mmpur_req_default_data DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
.
*?﻿<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
*?<asx:values>
*?<TESTCLASS_OPTIONS>
*?<TEST_CLASS>lcl_Ex_Mmpur_Req_Default_Data
*?</TEST_CLASS>
*?<TEST_MEMBER>f_Cut
*?</TEST_MEMBER>
*?<OBJECT_UNDER_TEST>CL_EX_MMPUR_REQ_DEFAULT_DATA
*?</OBJECT_UNDER_TEST>
*?<OBJECT_IS_LOCAL/>
*?<GENERATE_FIXTURE>X
*?</GENERATE_FIXTURE>
*?<GENERATE_CLASS_FIXTURE>X
*?</GENERATE_CLASS_FIXTURE>
*?<GENERATE_INVOCATION>X
*?</GENERATE_INVOCATION>
*?<GENERATE_ASSERT_EQUAL>X
*?</GENERATE_ASSERT_EQUAL>
*?</TESTCLASS_OPTIONS>
*?</asx:values>
*?</asx:abap>
  PRIVATE SECTION.
    DATA:
      f_cut TYPE REF TO cl_ex_mmpur_req_default_data.  "class under test

    CLASS-METHODS: class_setup.
    CLASS-METHODS: class_teardown.
    METHODS: setup.
    METHODS: teardown.
    METHODS: default_data FOR TESTING.
ENDCLASS.       "lcl_Ex_Mmpur_Req_Default_Data


CLASS lcl_ex_mmpur_req_default_data IMPLEMENTATION.

  METHOD class_setup.



  ENDMETHOD.


  METHOD class_teardown.



  ENDMETHOD.


  METHOD setup.


    CREATE OBJECT f_cut.
  ENDMETHOD.


  METHOD teardown.



  ENDMETHOD.


  METHOD default_data.

    DATA ls_item_exp TYPE mmpur_req_s_default_attr.
    DATA ls_item_act TYPE mmpur_req_s_default_attr.
    DATA lt_catalogs_exp TYPE mmpur_req_s_default_cat_t.
    DATA lt_catalogs_act TYPE mmpur_req_s_default_cat_t.
    DATA ls_catalog TYPE mmpur_req_s_default_cat    .

    ls_item_exp-plant = '0001'.

    APPEND ls_catalog TO lt_catalogs_exp.

    TRY.
        f_cut->if_mmpur_req_default_data~default_data(
          CHANGING
            cs_item = ls_item_act
            ct_catalogs = lt_catalogs_act ).
      CATCH cx_ble_runtime_error .
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      act   = ls_item_act
      exp   = ls_item_exp
    ).

    cl_abap_unit_assert=>assert_equals(
      act   = lt_catalogs_exp
      exp   = lt_catalogs_act
    ).

  ENDMETHOD.




ENDCLASS.
