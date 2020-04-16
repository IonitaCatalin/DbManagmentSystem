CREATE TYPE detaliu_medie AS OBJECT(
    an number,
    semestru varchar(3),
    media NUMBER
);

CREATE OR REPLACE TYPE medii AS TABLE OF detaliu_medie;
/
ALTER TABLE STUDENTI ADD media_semestrial medii NESTED TABLE media_semestrial STORE AS lista_medii;
/

CREATE OR REPLACE FUNCTION numar_medii(p_id IN STUDENTI.id%TYPE) return NUMBER
IS
    v_aparitii NUMBER;
    v_medii_student medii;
BEGIN
    SELECT COUNT(*) INTO v_aparitii FROM STUDENTI WHERE id=p_id;
    IF(v_aparitii=0)
    THEN
        DBMS_OUTPUT.PUT_LINE('Studentul cu id-ul('||p_id||') nu exista');
        RETURN 0;
    ELSE
        v_medii_student:=medii();
        SELECT MEDIA_SEMESTRIAL INTO v_medii_student FROM STUDENTI WHERE id=p_id;
        RETURN v_medii_student.COUNT;
    END IF;
END;

DECLARE
    CURSOR c_studenti IS (SELECT * FROM STUDENTI) FOR UPDATE OF MEDIA_SEMESTRIAL;
    v_valoare_medie NUMBER;
    v_inreg medii;
BEGIN
    FOR v_student in c_studenti
        LOOP
            IF (v_student.AN=2)
            THEN
                v_student.MEDIA_SEMESTRIAL:=medii();
                v_student.MEDIA_SEMESTRIAL.extend(2);
                    FOR stud_sem in 1..2
                    LOOP
                        SELECT AVG(valoare) INTO v_valoare_medie FROM STUDENTI s
                             JOIN NOTE n on n.ID_STUDENT=s.id JOIN CURSURI c
                             ON c.AN=s.AN AND n.ID_CURS=c.ID AND c.SEMESTRU=stud_sem
                             WHERE s.id=v_student.ID;
                        v_inreg:=medii(1,stud_sem,v_valoare_medie);
                    END LOOP;
                UPDATE STUDENTI SET STUDENTI.media_semestrial=v_inreg
                WHERE id=v_student.ID;
            ELSIF (v_student.AN=3)
            THEN
                v_student.MEDIA_SEMESTRIAL:=medii();
                v_student.MEDIA_SEMESTRIAL.extend(4);
                 FOR stud_an in 1..2
                LOOP
                    FOR stud_sem in 1..2
                    LOOP
                        SELECT AVG(valoare) INTO v_valoare_medie FROM STUDENTI s
                             JOIN NOTE n on n.ID_STUDENT=s.id JOIN CURSURI c
                             ON c.AN=s.AN AND n.ID_CURS=c.ID AND c.SEMESTRU=stud_sem
                             WHERE s.id=v_student.ID;
                       v_inreg:=medii(stud_an,stud_sem,v_valoare_medie);
                    END LOOP;
                    UPDATE STUDENTI SET STUDENTI.media_semestrial=v_inreg
                        WHERE id=v_student.ID;
                END LOOP;
            ELSE
                UPDATE STUDENTI SET STUDENTI.media_semestrial=medii()
                WHERE id=v_student.ID;
            END IF;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('Studentul cu ID-ul 167 are nr_medii:'||numar_medii(2));
        DBMS_OUTPUT.PUT_LINE('Studentul cu ID-ul 1673 are nr_medii:'||numar_medii(1673));
END;






