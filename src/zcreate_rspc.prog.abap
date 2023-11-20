*&---------------------------------------------------------------------*
*& Report zcreate_rspc
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zcreate_rspc.


DATA: lr_chain   TYPE REF TO cl_rspc_chain,
      lv_guid    TYPE sysuuid_25,
      lv_variant TYPE  rspc_variant.

PARAMETERS: pa_chain TYPE string DEFAULT 'ZTEST_RSPC',
            pa_descr TYPE string LOWER CASE DEFAULT 'Test RSCP'.

  lr_chain = NEW #( i_chain   = CONV #( pa_chain )
                       i_new  = abap_true
               i_with_dialog  = abap_false ).

  lr_chain->rename( i_txtlg = CONV #( pa_descr )  ).


  CALL FUNCTION 'RSSM_UNIQUE_ID'
    IMPORTING
      e_uni_idc25 = lv_guid.

  lv_variant = |ILV_{ lv_guid }|.

  SELECT SINGLE @abap_true FROM rspcchain
  WHERE type = 'TRIGGER' AND variante = @lv_variant
  AND   chain_id <> @pa_chain
  INTO @DATA(lv_exists).

  CHECK lv_exists = abap_false.

  CALL FUNCTION 'RSPC_TRIGGER_GENERATE'
    EXPORTING
      i_variant      = lv_variant
      i_meta         = abap_true
      i_modify       = 'X'
    EXCEPTIONS
      exists         = 1
      failed         = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
    RAISE failed.
  ENDIF.

  CALL METHOD lr_chain->add_process
    EXPORTING
      i_type          = 'TRIGGER'
      i_variant       = lv_variant
      i_with_dialog   = abap_false
*      i_inline        = 'X'
    EXCEPTIONS
      aborted_by_user = 1
      OTHERS          = 2.

  lr_chain->save(
    EXCEPTIONS
      failed       = 1
      OTHERS       = 2
  ).

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  lr_chain->activate(
    EXPORTING
      i_noplan           = abap_true
    EXCEPTIONS
      errors             = 1
      warnings           = 2
      others             = 3
  ).
  IF SY-SUBRC <> 0.
   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
