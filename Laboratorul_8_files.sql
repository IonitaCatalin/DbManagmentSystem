--Executate ca si SYSDBA
GRANT EXECUTE ON UTL_FILE TO STUDENT;
GRANT READ,WRITE ON DIRECTORY MYDIR TO STUDENT;
CREATE OR REPLACE DIRECTORY MYDIR as 'D:\STUDENT';

CREATE OR REPLACE PROCEDURE tableToCsv
IS
    v_export_file UTL_FILE.FILE_TYPE;
    v_byte_size NUMBER:=0;
    v_csv_row VARCHAR2(150);
    CURSOR v_note_cursor IS SELECT * FROM NOTE;
BEGIN
    v_export_file:=UTL_FILE.FOPEN('MYDIR','export.csv','W');
    FOR v_iterator IN v_note_cursor
    LOOP
        v_csv_row:=v_iterator.ID||','||v_iterator.ID_STUDENT||','||v_iterator.ID_CURS||','||v_iterator.VALOARE||','||v_iterator.DATA_NOTARE||','||v_iterator.CREATED_AT||','||v_iterator.UPDATED_AT;
        v_byte_size:=v_byte_size+LENGTHB(v_csv_row);
        --Bufferul asociat functie UTL_FILE.PUT are o marime prestabilita de 32767 bytes
        if(v_byte_size<32767)
        THEN
            UTL_FILE.PUT_LINE(v_export_file,v_csv_row);
        ELSE
            --Aplicam fflus pentru a scrie datele in fisierul tinta inainte ca bufferul nostru sa faca overflow
            UTL_FILE.FFLUSH(v_export_file);
            UTL_FILE.PUT_LINE(v_export_file,v_csv_row);
            v_byte_size:=0;
        END IF;
    END LOOP;
END;

CREATE OR REPLACE FUNCTION string_split_elemnt(p_string VARCHAR2,p_element INTEGER,p_separator VARCHAR2)
RETURN VARCHAR2
AS
    v_string VARCHAR2(32767);
BEGIN
    v_string := p_string || p_separator;
     FOR i IN 1 .. p_element - 1
     LOOP
   	    v_string := SUBSTR(v_string,INSTR(v_string,p_separator)+1);
     END LOOP;
     RETURN SUBSTR(v_string,1,INSTR(v_string,p_separator)-1);
END;

CREATE OR REPLACE PROCEDURE csvToTable
IS
    v_import_file UTL_FILE.FILE_TYPE;
    v_csv_row VARCHAR2(150);
    v_id NOTE.ID%TYPE;
    v_id_student NOTE.ID_STUDENT%TYPE;
    v_id_curs NOTE.ID_CURS%TYPE;
    v_valoare NOTE.ID%TYPE;
    v_data_notare NOTE.DATA_NOTARE%TYPE;
    v_create NOTE.CREATED_AT%TYPE;
    v_update NOTE.UPDATED_AT%TYPE;
BEGIN
    v_import_file:=UTL_FILE.FOPEN('MYDIR','export.csv','R');
     LOOP
        BEGIN
            UTL_FILE.GET_LINE(v_import_file,v_csv_row);
            v_id:=TO_NUMBER(string_split_elemnt(v_csv_row,1,','));
            v_id_student:=TO_NUMBER(string_split_elemnt(v_csv_row,2,','));
            v_id_curs:=TO_NUMBER(string_split_elemnt(v_csv_row,3,','));
            v_valoare:=TO_NUMBER(string_split_elemnt(v_csv_row,4,','),'99');
            v_data_notare:=string_split_elemnt(v_csv_row,5,',');
            v_create:=string_split_elemnt(v_csv_row,6,',');
            v_update:=string_split_elemnt(v_csv_row,7,',');
            INSERT INTO NOTE VALUES(v_id,v_id_student,v_id_curs,v_valoare,v_data_notare,v_create,v_update);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            EXIT;
        END;
    END LOOP;
END;

BEGIN
    tableToCsv();
    DELETE FROM NOTE WHERE ID IS NOT NULL;
    csvToTable();
END;
COMMIT;







