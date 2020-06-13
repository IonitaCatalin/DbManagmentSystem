CREATE OR REPLACE FUNCTION getType(v_rec_tab DBMS_SQL.DESC_TAB, v_nr_col int) RETURN VARCHAR2 AS
  v_tip_coloana VARCHAR2(200);
  v_precizie VARCHAR2(40);
BEGIN
     CASE (v_rec_tab(v_nr_col).col_type)
        WHEN 1 THEN v_tip_coloana := 'VARCHAR2'; v_precizie := '(' || v_rec_tab(v_nr_col).col_max_len || ')';
        WHEN 2 THEN v_tip_coloana := 'NUMBER'; v_precizie := '(' || v_rec_tab(v_nr_col).col_precision || ',' || v_rec_tab(v_nr_col).col_scale || ')';
        WHEN 12 THEN v_tip_coloana := 'DATE'; v_precizie := '';
        WHEN 96 THEN v_tip_coloana := 'CHAR'; v_precizie := '(' || v_rec_tab(v_nr_col).col_max_len || ')';
        WHEN 112 THEN v_tip_coloana := 'CLOB'; v_precizie := '';
        WHEN 113 THEN v_tip_coloana := 'BLOB'; v_precizie := '';
        WHEN 109 THEN v_tip_coloana := 'XMLTYPE'; v_precizie := '';
        WHEN 101 THEN v_tip_coloana := 'BINARY_DOUBLE'; v_precizie := '';
        WHEN 100 THEN v_tip_coloana := 'BINARY_FLOAT'; v_precizie := '';
        WHEN 8 THEN v_tip_coloana := 'LONG'; v_precizie := '';
        WHEN 180 THEN v_tip_coloana := 'TIMESTAMP'; v_precizie :='(' || v_rec_tab(v_nr_col).col_scale || ')';
        WHEN 181 THEN v_tip_coloana := 'TIMESTAMP' || '(' || v_rec_tab(v_nr_col).col_scale || ') ' || 'WITH TIME ZONE'; v_precizie := '';
        WHEN 231 THEN v_tip_coloana := 'TIMESTAMP' || '(' || v_rec_tab(v_nr_col).col_scale || ') ' || 'WITH LOCAL TIME ZONE'; v_precizie := '';
        WHEN 114 THEN v_tip_coloana := 'BFILE'; v_precizie := '';
        WHEN 23 THEN v_tip_coloana := 'RAW'; v_precizie := '(' || v_rec_tab(v_nr_col).col_max_len || ')';
        WHEN 11 THEN v_tip_coloana := 'ROWID'; v_precizie := '';
        WHEN 109 THEN v_tip_coloana := 'URITYPE'; v_precizie := '';
      END CASE;
      RETURN v_tip_coloana||v_precizie;
END;
CREATE OR REPLACE PROCEDURE generareCatalog(p_materie_id IN NUMBER)
IS
    v_titlu_cursor_id NUMBER;
    v_tabel_cursor_id NUMBER;
    v_creare_cursor_id NUMBER;
    v_populare_cursor_id NUMBER;
    v_get_titlu_ok INTEGER;
    v_get_tipuri_ok INTEGER;
    v_get_create_ok INTEGER;
    v_get_populare_ok INTEGER;
    v_titlu_curs VARCHAR2(52);
    v_tip_nume VARCHAR2(240);
    v_tip_prenume VARCHAR2(240);
    v_tip_data_notare VARCHAR2(240);
    v_tip_nota VARCHAR2(240);
    v_tip_nr_matricol VARCHAR2(240);
    v_nr_col NUMBER;
    v_rec_tab DBMS_SQL.DESC_TAB;
    v_total_coloane NUMBER;
    v_valoare_nume STUDENTI.NUME%TYPE;
    v_valoare_prenume STUDENTI.NUME%TYPE;
    v_valoare_nr_matricol STUDENTI.NR_MATRICOL%TYPE;
    v_valoare_nota NOTE.VALOARE%TYPE;
    v_valoare_data NOTE.DATA_NOTARE%TYPE;
    v_exists_curs NUMBER;
    CURSOR v_valori_catalog IS SELECT nume,prenume,nr_matricol,valoare,data_notare FROM STUDENTI stud JOIN NOTE note ON stud.id=note.id_student WHERE ID_CURS=p_materie_id;


BEGIN
    SELECT COUNT(id) INTO v_exists_curs FROM CURSURI WHERE id=p_materie_id;
    IF(v_exists_curs>0)
    THEN
        --Obinem dinamic numele tabelului
        v_titlu_cursor_id:=DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(v_titlu_cursor_id,'SELECT titlu_curs FROM CURSURI WHERE ID='||p_materie_id,DBMS_SQL.NATIVE);
        DBMS_SQL.DEFINE_COLUMN(v_titlu_cursor_id,1,v_titlu_curs,52);
        v_get_titlu_ok:=DBMS_SQL.EXECUTE(v_titlu_cursor_id);

        LOOP
            IF DBMS_SQL.FETCH_ROWS(v_titlu_cursor_id)>0 THEN
                DBMS_SQL.COLUMN_VALUE(v_titlu_cursor_id,1,v_titlu_curs);
            ELSE
                EXIT;
            END IF;
        END LOOP;

        v_titlu_curs:=replace(v_titlu_curs,' ','');
        v_titlu_curs:=replace(v_titlu_curs,'-','');
        DBMS_SQL.CLOSE_CURSOR(v_titlu_cursor_id);

        --Obtinem tipurile de date ale coloanelor asociate

        v_tabel_cursor_id:=DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(v_tabel_cursor_id,'SELECT nume,prenume,nr_matricol,valoare,data_notare FROM STUDENTI stud JOIN NOTE note ON stud.id=note.id_student',DBMS_SQL.NATIVE);
        DBMS_SQL.DESCRIBE_COLUMNS(v_tabel_cursor_id, v_total_coloane, v_rec_tab);
        v_get_tipuri_ok:=DBMS_SQL.EXECUTE(v_tabel_cursor_id);

        v_nr_col:=v_rec_tab.first;
        IF(v_nr_col IS NOT NULL) THEN
           v_tip_nume:=getType(v_rec_tab,v_nr_col);
           v_nr_col:=v_rec_tab.next(v_nr_col);
           v_tip_prenume:=getType(v_rec_tab,v_nr_col);
           v_nr_col:=v_rec_tab.next(v_nr_col);
           v_tip_nr_matricol:=getType(v_rec_tab,v_nr_col);
           v_nr_col:=v_rec_tab.next(v_nr_col);
           v_tip_nota:=getType(v_rec_tab,v_nr_col);
           v_nr_col:=v_rec_tab.next(v_nr_col);
           v_tip_data_notare:=getType(v_rec_tab,v_nr_col);
           v_nr_col:=v_rec_tab.next(v_nr_col);
        END IF;
        DBMS_SQL.CLOSE_CURSOR(v_tabel_cursor_id);

        --Cream noul tabel al cursului folosind tipurile de date obtinute la punctul anterior
        v_creare_cursor_id:=DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(v_creare_cursor_id,'CREATE TABLE '||v_titlu_curs
                                                         ||'('||'nume '||v_tip_nume||','
                                                         ||'prenume '||v_tip_prenume||','
                                                         ||'numar_matricol '||v_tip_nr_matricol||','
                                                         ||'nota ' || v_tip_nota||','
                                                         ||'data_notarii '||v_tip_data_notare||')'
                                                        ,DBMS_SQL.NATIVE);

        v_get_create_ok:=DBMS_SQL.EXECUTE(v_creare_cursor_id);
        DBMS_SQL.CLOSE_CURSOR(v_creare_cursor_id);

        --Populam tablelului cu inregistrari

        v_populare_cursor_id:=DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(v_populare_cursor_id,'INSERT INTO '||v_titlu_curs ||' VALUES('|| ':nume,:prenume,:numar_matricol,:nota,:data_notarii)',DBMS_SQL.NATIVE);
        FOR v_iterator IN v_valori_catalog
        LOOP
            DBMS_SQL.BIND_VARIABLE(v_populare_cursor_id, ':nume', v_iterator.NUME);
            DBMS_SQL.BIND_VARIABLE(v_populare_cursor_id, ':prenume', v_iterator.PRENUME);
            DBMS_SQL.BIND_VARIABLE(v_populare_cursor_id, ':numar_matricol', v_iterator.NR_MATRICOL);
            DBMS_SQL.BIND_VARIABLE(v_populare_cursor_id, ':nota', v_iterator.VALOARE);
            DBMS_SQL.BIND_VARIABLE(v_populare_cursor_id, ':data_notarii', v_iterator.DATA_NOTARE);
            v_get_populare_ok:=DBMS_SQL.EXECUTE(v_populare_cursor_id);--executarea instructiunii SQL
        END LOOP;
        DBMS_SQL.CLOSE_CURSOR(v_populare_cursor_id);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Cursul specificat nu exista');
    END IF;
END;

BEGIN
    generareCatalog(20);
END;