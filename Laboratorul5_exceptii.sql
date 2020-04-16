ALTER TABLE NOTE ADD CONSTRAINT uniq_id_stud_curs UNIQUE(id_student,id_curs);
/

 --Metoda in care inseram prinzand exceptia de violare a termenilor constragerii


DECLARE
    v_rand_stud_id STUDENTI.ID%TYPE;
    v_rand_stud_nume STUDENTI.NUME%TYPE;
    v_rand_stud_prenume STUDENTI.PRENUME%TYPE;
BEGIN
    FOR v_iterator IN 1..POWER(10,6)
    LOOP
        BEGIN
            SELECT ID INTO v_rand_stud_id FROM (SELECT ID FROM STUDENTI ORDER BY DBMS_RANDOM.VALUE()) WHERE ROWNUM=1;
            SELECT NUME,PRENUME INTO v_rand_stud_nume,v_rand_stud_prenume FROM STUDENTI WHERE ID=v_rand_stud_id;
            INSERT INTO NOTE VALUES ((SELECT MAX(ID) FROM NOTE),v_rand_stud_id,1,DBMS_RANDOM.VALUE(1,10),SYSDATE,SYSDATE,SYSDATE);
            EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                DBMS_OUTPUT.PUT_LINE('Stundetul cu id-ul:'|| v_rand_stud_id ||' are deja o nota la materia logica!');
                 CONTINUE;
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Executia scriptul a fost intrerupta!.. ' || SQLCODE || SQLERRM);
        END;
    END LOOP;
END;


 --Metoda cu validarea notei inainte de inserare


DECLARE
    v_rand_stud_id STUDENTI.ID%TYPE;
    v_rand_stud_nume STUDENTI.NUME%TYPE;
    v_rand_stud_prenume STUDENTI.PRENUME%TYPE;
    v_count_note NUMBER;
BEGIN
    FOR v_iterator IN 1..POWER(10,6)
    LOOP
        DBMS_OUTPUT.PUT_LINE('Progres:'||v_iterator);
        SELECT ID INTO v_rand_stud_id FROM (SELECT ID FROM STUDENTI ORDER BY DBMS_RANDOM.VALUE()) WHERE ROWNUM=1;
        SELECT COUNT(ID) INTO v_count_note FROM NOTE WHERE ID_STUDENT=v_rand_stud_id AND ID_CURS=1;
        IF v_count_note=0
        THEN
            SELECT NUME,PRENUME INTO v_rand_stud_nume,v_rand_stud_prenume FROM STUDENTI WHERE ID=v_rand_stud_id;
            INSERT INTO NOTE VALUES ((SELECT MAX(ID) FROM NOTE),v_rand_stud_id,1,DBMS_RANDOM.VALUE(1,10),SYSDATE,SYSDATE,SYSDATE);
        ELSE
           DBMS_OUTPUT.PUT_LINE('Stundetul cu id-ul:'|| v_rand_stud_id ||' are deja o nota la materia logica!');
            CONTINUE;
        END IF;
    END LOOP;
END;

    --Din testele pe 1000000 ale metodelor de mai sus se poate observa ca abordare folosind exceptii desi mai stabila
    --si ofera mai multa flexibilitate este mai inceata decat abordarea clasica.


--Functie pe care o vom folosii pentru a afla media unui student dupa nume si prenume(in caz ca sunt mai multi studenti cu acelasi nume si prenume,il vom lua pe primul)
CREATE OR REPLACE FUNCTION get_student_grade_avg(p_nume_stud IN STUDENTI.NUME%TYPE,p_prenume_stud IN STUDENTI.PRENUME%TYPE)
RETURN NUMBER
IS
    v_id_stud STUDENTI.ID%TYPE;
    v_count_stud NUMBER;
    v_count_grades NUMBER;
    v_stud_media NUMBER:=0;
    NO_STUDENT_FOUND EXCEPTION;
    PRAGMA EXCEPTION_INIT(NO_STUDENT_FOUND,-20001);
    NO_GRADES EXCEPTION;
    PRAGMA EXCEPTION_INIT(NO_GRADES,-20002);
BEGIN
    SELECT COUNT(ID) INTO v_count_stud FROM STUDENTI WHERE LOWER(nume)=LOWER(p_nume_stud) AND LOWER(prenume)=LOWER(p_prenume_stud);
    IF v_count_stud<>0
    THEN
        SELECT ID INTO v_id_stud FROM (SELECT ID FROM STUDENTI WHERE LOWER(nume)=LOWER(p_nume_stud) AND LOWER(prenume)=LOWER(p_prenume_stud)) WHERE ROWNUM=1;
        SELECT COUNT(id) INTO v_count_grades FROM NOTE WHERE ID_STUDENT=v_id_stud;
        IF v_count_grades<>0
        THEN
            SELECT AVG(valoare) INTO v_stud_media FROM NOTE WHERE ID_STUDENT=v_id_stud;
            RETURN v_stud_media;
        ELSE
            raise NO_GRADES;
        END IF;
    ELSE
        raise NO_STUDENT_FOUND;
    END IF;
    END;
    CREATE OR REPLACE TYPE test_studs AS OBJECT
    (
        nume   VARCHAR2(15),
        prenume VARCHAR(30)
    );

DECLARE
    TYPE studs_collection IS VARRAY(6) OF test_studs;
    c_studs studs_collection:=studs_collection();
    v_rand_nume STUDENTI.NUME%TYPE;
    v_rand_prenume STUDENTI.PRENUME%TYPE;
    NO_STUDENT_FOUND EXCEPTION;
    PRAGMA EXCEPTION_INIT(NO_STUDENT_FOUND,-20001);
    NO_GRADES EXCEPTION;
    PRAGMA EXCEPTION_INIT(NO_GRADES,-20002);
BEGIN
    c_studs.extend(6);
    FOR v_iterator in 1..3
    LOOP
        SELECT nume,prenume INTO v_rand_nume,v_rand_prenume FROM (SELECT nume,prenume FROM STUDENTI ORDER BY DBMS_RANDOM.VALUE()) WHERE ROWNUM=1;
        c_studs(v_iterator):=test_studs(v_rand_nume,v_rand_prenume);
    END LOOP;
       c_studs(4):=test_studs('Kovacs','Takashi');
       c_studs(5):=test_studs('Kawahara','Reileen');
       c_studs(6):=test_studs('Makita','Nadia');
   FOR v_iterator IN 1..6
    LOOP
       BEGIN
            DBMS_OUTPUT.PUT_LINE('Media studentului '|| c_studs(v_iterator).NUME || ' '|| c_studs(v_iterator).PRENUME||' este '||get_student_grade_avg(c_studs(v_iterator).NUME,c_studs(v_iterator).PRENUME));
        EXCEPTION
           WHEN NO_STUDENT_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Studentul speficat '||c_studs(v_iterator).NUME ||' '||c_studs(v_iterator).PRENUME||' nu exista in baza de date!');
          WHEN NO_GRADES THEN
               DBMS_OUTPUT.PUT_LINE('Studentul speficat '||c_studs(v_iterator).NUME ||' '||c_studs(v_iterator).PRENUME||' nu are note!');
        END;
    END LOOP;
END;





