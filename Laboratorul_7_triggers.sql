CREATE OR REPLACE VIEW catalog_studs AS
    SELECT stud.NUME AS STUD_NUME,stud.PRENUME AS STUD_PRENUME,
           stud.id AS STUD_ID,curs.id AS CURS_ID,
           curs.TITLU_CURS AS CURS_TITLU,note.VALOARE as NOTA_VALOARE
    FROM STUDENTI stud
    JOIN NOTE note ON stud.ID=note.ID_STUDENT
    JOIN CURSURI curs ON curs.ID=note.ID_CURS


CREATE OR REPLACE FUNCTION random_str(v_length NUMBER) RETURN VARCHAR2 IS
    v_rand_string varchar2(4000);
BEGIN
    FOR i IN 1..v_length LOOP
        v_rand_string := v_rand_string || dbms_random.string(
            CASE WHEN dbms_random.value(0, 1) < 0.5
                    THEN 'l'
                    ELSE 'x'
                    END, 1);
    END LOOP;
    RETURN UPPER(v_rand_string);
END;


CREATE OR REPLACE TRIGGER delete_student
    INSTEAD OF DELETE ON catalog_studs
    DECLARE
        v_nr_studenti NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_nr_studenti FROM STUDENTI WHERE ID=:OLD.STUD_ID;
        IF(v_nr_studenti>0)
        THEN
            DELETE FROM NOTE WHERE ID_STUDENT=:OLD.STUD_ID;
            DELETE FROM PRIETENI WHERE ID_STUDENT1=:OLD.STUD_ID OR ID_STUDENT2=:OLD.STUD_ID;
            DELETE FROM STUDENTI WHERE ID=:OLD.STUD_ID;
        ELSE
            DBMS_OUTPUT.PUT_LINE('Studentul specificat nu exista in baza de date!');
        END IF;
END delete_student;


CREATE OR REPLACE TRIGGER add_new_student_grade_course
    INSTEAD OF INSERT ON catalog_studs
    DECLARE
        v_exists_stud NUMBER;
        v_exists_curs NUMBER;

        v_stud_matricol STUDENTI.NR_MATRICOL%TYPE;
        v_stud_an STUDENTI.AN%TYPE;
        v_stud_grupa STUDENTI.GRUPA%TYPE;
        v_stud_bursa STUDENTI.BURSA%TYPE;
        v_stud_email STUDENTI.EMAIL%TYPE;
        v_stud_data_nastere DATE;

        v_curs_an CURSURI.AN%TYPE;
        v_curs_semestru CURSURI.SEMESTRU%TYPE;
        v_curs_credite CURSURI.CREDITE%TYPE;

        v_id_stud STUDENTI.ID%TYPE;
        V_id_curs STUDENTI.ID%TYPE;

    BEGIN
        SELECT COUNT(id) INTO v_exists_stud FROM STUDENTI WHERE LOWER(NUME)=LOWER(:NEW.STUD_NUME) AND LOWER(PRENUME)=LOWER(:NEW.STUD_PRENUME);
        SELECT COUNT(id) INTO v_exists_curs FROM CURSURI WHERE LOWER(TITLU_CURS)=LOWER(:NEW.CURS_TITLU);
        IF(v_exists_stud=0)
        THEN
            SELECT MAX(ID)+1 INTO v_id_stud FROM STUDENTI;
            /*Inseram date aleatorii despre studentul care nu exista*/

            v_stud_matricol:=random_str(5);
            v_stud_an:=TRUNC(DBMS_RANDOM.VALUE(1,3));
            v_stud_grupa :=DBMS_RANDOM.STRING('U',1)||TRUNC(DBMS_RANDOM.VALUE(1,6));
            v_stud_email:=:NEW.STUD_NUME||'.'||:NEW.STUD_PRENUME||'@gmail.com';
            v_stud_bursa:=TRUNC(DBMS_RANDOM.VALUE(100,600));
             INSERT INTO STUDENTI VALUES(v_id_stud,v_stud_matricol,:NEW.STUD_NUME,:NEW.STUD_PRENUME,v_stud_an,v_stud_grupa,v_stud_bursa,v_stud_data_nastere,v_stud_email,SYSDATE,SYSDATE);

        ELSE
             SELECT ID INTO v_id_stud FROM STUDENTI WHERE LOWER(NUME)=LOWER(:NEW.STUD_NUME) AND LOWER(PRENUME)=LOWER(:NEW.STUD_PRENUME);
        END IF;

        IF(v_exists_curs=0)
        THEN
            SELECT MAX(ID)+1 INTO v_id_curs FROM CURSURI;
            /*Inseram date aleatorii despre cursul care nu exista*/
            v_curs_an:=TRUNC(DBMS_RANDOM.VALUE(1,3));
            v_curs_semestru:=TRUNC(DBMS_RANDOM.VALUE(1,2));
            v_curs_credite:=TRUNC(DBMS_RANDOM.VALUE(1,6 ));
            INSERT INTO CURSURI VALUES(v_id_curs,:NEW.CURS_TITLU,v_curs_an,v_curs_semestru,v_curs_credite,SYSDATE,SYSDATE);
        ELSE
             SELECT ID INTO v_id_curs FROM CURSURI WHERE LOWER(TITLU_CURS)=LOWER(:NEW.CURS_TITLU);
        END IF;

        INSERT INTO NOTE VALUES ((SELECT MAX(ID)+1 FROM NOTE),v_id_stud,v_id_curs,:NEW.NOTA_VALOARE,SYSDATE,SYSDATE,SYSDATE);
    END;


CREATE OR REPLACE TRIGGER update_existing_grade
    INSTEAD OF UPDATE ON catalog_studs
    DECLARE
        v_exists_stud NUMBER;
        v_exists_curs NUMBER;
    BEGIN
        SELECT COUNT(ID) INTO v_exists_stud FROM STUDENTI;
        SELECT COUNT(ID) INTO v_exists_curs FROM CURSURI WHERE :NEW.CURS_ID=ID;
        IF(v_exists_stud>0)
        THEN
            IF(v_exists_curs>0)
            THEN
                IF(:NEW.NOTA_VALOARE>:OLD.NOTA_VALOARE)
                THEN
                    UPDATE NOTE SET valoare=:NEW.NOTA_VALOARE,UPDATED_AT=SYSDATE WHERE ID_STUDENT=:NEW.STUD_ID AND ID_CURS=:NEW.CURS_ID;
                ELSE
                    DBMS_OUTPUT.PUT_LINE('Nota nu poate fi actualizata intrucat este mai mica decat ultima nota');
                END IF;
            ELSE
                DBMS_OUTPUT.PUT_LINE('Cursul specificat nu exista');
            END IF;
        ELSE
            DBMS_OUTPUT.PUT_LINE('Stundentul specificat nu exista');
        END IF;
    END;
BEGIN
    DELETE FROM catalog_studs WHERE STUD_ID=34;
    INSERT INTO catalog_studs(stud_nume,stud_prenume,curs_titlu,nota_valoare) VALUES('Schrodinger','Ada','Mecanica Cuantica',10);
    INSERT INTO catalog_studs(stud_nume,stud_prenume,curs_titlu,nota_valoare) VALUES('Copperfield','Edward','Matematicã',5);
    UPDATE catalog_studs SET NOTA_VALOARE=10 WHERE stud_id=1033 AND CURS_ID=2;
END;
COMMIT;

SELECT * FROM catalog_studs WHERE STUD_NUME='Copperfield' AND STUD_PRENUME='Edward';




