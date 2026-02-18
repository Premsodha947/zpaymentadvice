CLASS zcl_number_to_words DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS:
      convert_amount_to_words
        IMPORTING
          iv_amount   TYPE string
          iv_currency TYPE string
        RETURNING
          VALUE(rv_words) TYPE string.
  PRIVATE SECTION.
    CLASS-METHODS:
      num_to_words
        IMPORTING iv_num TYPE i
        RETURNING VALUE(rv_word) TYPE string.
ENDCLASS.



CLASS ZCL_NUMBER_TO_WORDS IMPLEMENTATION.


  METHOD convert_amount_to_words.
    DATA lv_int_part TYPE i.
    DATA lv_dec_part TYPE i.
    DATA lv_result   TYPE string.

    lv_int_part = floor( iv_amount ).
    lv_dec_part = ( iv_amount - lv_int_part ) * 100.

    lv_result = |{ zcl_number_to_words=>num_to_words( lv_int_part ) } { iv_currency }|.

    IF lv_dec_part > 0.
      lv_result = lv_result && | and { zcl_number_to_words=>num_to_words( lv_dec_part ) } Paise|.
    ENDIF.

    lv_result = lv_result && | Only|.
    rv_words = to_mixed( lv_result ). " Capitalise first letter of each word
  ENDMETHOD.


  METHOD num_to_words.
  DATA: lt_ones TYPE STANDARD TABLE OF string WITH DEFAULT KEY,
        lt_tens TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

  " Fill ones
  APPEND 'Zero'     TO lt_ones.
  APPEND 'One'      TO lt_ones.
  APPEND 'Two'      TO lt_ones.
  APPEND 'Three'    TO lt_ones.
  APPEND 'Four'     TO lt_ones.
  APPEND 'Five'     TO lt_ones.
  APPEND 'Six'      TO lt_ones.
  APPEND 'Seven'    TO lt_ones.
  APPEND 'Eight'    TO lt_ones.
  APPEND 'Nine'     TO lt_ones.
  APPEND 'Ten'      TO lt_ones.
  APPEND 'Eleven'   TO lt_ones.
  APPEND 'Twelve'   TO lt_ones.
  APPEND 'Thirteen' TO lt_ones.
  APPEND 'Fourteen' TO lt_ones.
  APPEND 'Fifteen'  TO lt_ones.
  APPEND 'Sixteen'  TO lt_ones.
  APPEND 'Seventeen' TO lt_ones.
  APPEND 'Eighteen' TO lt_ones.
  APPEND 'Nineteen' TO lt_ones.

  " Fill tens
  APPEND ''        TO lt_tens.
  APPEND ''        TO lt_tens.
  APPEND 'Twenty'  TO lt_tens.
  APPEND 'Thirty'  TO lt_tens.
  APPEND 'Forty'   TO lt_tens.
  APPEND 'Fifty'   TO lt_tens.
  APPEND 'Sixty'   TO lt_tens.
  APPEND 'Seventy' TO lt_tens.
  APPEND 'Eighty'  TO lt_tens.
  APPEND 'Ninety'  TO lt_tens.

  DATA lv_word TYPE string.

  " Indian numbering system
  IF iv_num >= 10000000.
    rv_word = num_to_words( iv_num / 10000000 ) && ' Crore'.
    IF iv_num MOD 10000000 > 0.
      rv_word = rv_word && ' ' && num_to_words( iv_num MOD 10000000 ).
    ENDIF.
  ELSEIF iv_num >= 100000.
    rv_word = num_to_words( iv_num / 100000 ) && ' Lakh'.
    IF iv_num MOD 100000 > 0.
      rv_word = rv_word && ' ' && num_to_words( iv_num MOD 100000 ).
    ENDIF.
  ELSEIF iv_num >= 1000.
    rv_word = num_to_words( iv_num / 1000 ) && ' Thousand'.
    IF iv_num MOD 1000 > 0.
      rv_word = rv_word && ' ' && num_to_words( iv_num MOD 1000 ).
    ENDIF.
  ELSEIF iv_num >= 100.
    rv_word = num_to_words( iv_num / 100 ) && ' Hundred'.
    IF iv_num MOD 100 > 0.
      rv_word = rv_word && ' And ' && num_to_words( iv_num MOD 100 ).
    ENDIF.
  ELSEIF iv_num >= 20.
    READ TABLE lt_tens INDEX ( iv_num / 10 ) + 1 INTO rv_word.
    IF iv_num MOD 10 > 0.
      READ TABLE lt_ones INDEX ( iv_num MOD 10 ) + 1 INTO lv_word.
      rv_word = rv_word && ' ' && lv_word.
    ENDIF.
  ELSE.
    READ TABLE lt_ones INDEX iv_num + 1 INTO rv_word.
  ENDIF.
ENDMETHOD.
ENDCLASS.
