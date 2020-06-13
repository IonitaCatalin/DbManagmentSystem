CREATE OR REPLACE PROCEDURE generateXML
IS
    v_output_file UTL_FILE.FILE_TYPE;
    v_xml_bytes_len INTEGER:=0;
    v_xml_line VARCHAR2(300);
    cursor v_cursor_catalog IS SELECT stud.NR_MATRICOL,stud.NUME,stud.PRENUME,stud.GRUPA,curs.TITLU_CURS,curs.AN,no.VALOARE FROM STUDENTI stud JOIN NOTE no ON stud.ID = no.ID_STUDENT JOIN CURSURI curs ON no.ID_CURS = curs.ID;
BEGIN
    v_output_file:=UTL_FILE.FOPEN('MYDIR','domxml.xml','W');
    UTL_FILE.PUT_LINE(v_output_file,'<catalog><students>');
    UTL_FILE.FFLUSH(v_output_file);
    FOR v_iterator IN v_cursor_catalog LOOP
        v_xml_line:='<student nrmMatricol="'||v_iterator.NR_MATRICOL||'"'||' nume="'||v_iterator.NUME||'"'||' prenume="'||
                    v_iterator.PRENUME||'"'||' grupa="'||v_iterator.GRUPA||'"'||' an="'||v_iterator.AN||'">'||
                    '<nota titluCurs="'||v_iterator.TITLU_CURS||'" anCurs="'||v_iterator.AN||'">'||v_iterator.VALOARE||'</nota></student>';
        v_xml_bytes_len:=v_xml_bytes_len+LENGTHB(v_xml_line);
         if(v_xml_bytes_len<32767)
        THEN
            UTL_FILE.PUT_LINE(v_output_file,v_xml_line);
        ELSE
            --Aplicam fflus pentru a scrie datele in fisierul tinta inainte ca bufferul nostru sa faca overflow
            UTL_FILE.FFLUSH(v_output_file);
            UTL_FILE.PUT_LINE(v_output_file,v_xml_line);
            v_xml_bytes_len:=0;
        END IF;
    END LOOP;
    UTL_FILE.PUT_LINE(v_output_file,'</students></catalog>');
    UTL_FILE.FFLUSH(v_output_file);
END;

BEGIN
    generateXML();
END;




