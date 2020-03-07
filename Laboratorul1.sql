set serveroutput on;
--1.Sa se consetruiasca un script la a carui rulare utilizatorul sa fie intrebat un nume de familie 
--Daca in tabela nu exista nicic macar un student cu acel nume se va afisa un mesaj informativ asupra acestui fapt
--In caz ca in tabel student se gaseste un student cu acel nume atunci se vor afisa urmatoarele
--a.Numarul de studenti avand acel nume de familie 
--b.Id si Prenumle studentului care ar fi primul in ordine lexicografica dupa prenume
--c.Nota cea mai mica si nota cea mai mare a studentului extras la punctul anterior
--d.Numarul a la puterea b unde a este nota cea mai mare si b nota cea mai mica a studentului

--Afisati cu cate zile este mai batran cel mai batran student din facultate fata de cel mai tanar
--Mail:alex_mihnea@yahoo.com
DECLARE

    v_nume_cautat studenti.nume%TYPE := 'Popescu';
    v_nr_studs INT;
    v_id_stud studenti.id%TYPE;
    v_prenume_stud studenti.prenume%TYPE;
    v_max_nota INT;
    v_min_nota INT;
    v_varsta_maxima DATE;
    v_varsta_minima DATE;
BEGIN
    SELECT COUNT(*) INTO v_nr_studs FROM STUDENTI WHERE nume=v_nume_cautat;
    
    IF(v_nr_studs=0)
    THEN 
        DBMS_OUTPUT.PUT_LINE('Nu exista in baza de date studenti cu numele specificat: '||v_nume_cautat);
    ELSE 
        DBMS_OUTPUT.PUT_LINE('Numarul de studenti cu numele '|| v_nume_cautat ||' este:'||v_nr_studs);
        SELECT id,prenume INTO v_id_stud,v_prenume_stud FROM (SELECT id,prenume FROM STUDENTI WHERE nume=v_nume_cautat ORDER BY prenume ASC) WHERE ROWNUM=1;
        DBMS_OUTPUT.PUT_LINE(v_id_stud||'/'||v_nume_cautat||' '||v_prenume_stud||'este primul student cu numele '|| v_nume_cautat||' in ordinea lexicografica a penumelui');
        SELECT MAX(valoare),MIN(valoare) INTO v_max_nota,v_min_nota FROM STUDENTI s JOIN NOTE n ON s.id=n.id_student WHERE s.id=v_id_stud;
        DBMS_OUTPUT.PUT_LINE('Studentul ' || v_nume_cautat||' '|| v_prenume_stud || ' are notele '|| v_max_nota || '\'||v_min_nota);
        DBMS_OUTPUT.PUT_LINE('Nota cea mai mica la puterea notei celei mai mari:'||POWER(v_min_nota,v_max_nota));
    END IF;
    
    SELECT MAX(DATA_NASTERE),MIN(DATA_NASTERE) INTO v_varsta_maxima,v_varsta_minima FROM STUDENTI;
    
    DBMS_OUTPUT.PUT_LINE('Diferenta de zile dintre cel mai batran si cel mai tanar student este de:'||TO_NUMBER(v_varsta_maxima-v_varsta_minima));
    
END;