
DECLARE
    v_nr_prim INT := 7;
    v_div_prop INT :=0;
    v_factorial INT:=4;
    v_prod_factorial INT:=1;
BEGIN
    IF (v_nr_prim = 0)
    THEN
        DBMS_OUTPUT.PUT_LINE('Numarul nu este prim!');
    ELSIF (v_nr_prim = 1)
    THEN
        DBMS_OUTPUT.PUT_LINE('Numarul este prim');
    ELSE
        FOR i IN 2..(v_nr_prim-1) LOOP
            IF MOD(v_nr_prim,i)=0
            THEN
                v_div_prop:=v_div_prop+1;
            END IF;
        END LOOP;
    END IF;
    IF (v_div_prop=0)
    THEN
        DBMS_OUTPUT.PUT_LINE('Numarul: '||v_nr_prim||' este prim');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Numarul '||v_nr_prim||' nu este prim');
    END IF;

   FOR i IN 1..v_factorial LOOP
        DBMS_OUTPUT.PUT_LINE('Valoare:'||i);
        v_prod_factorial:=v_prod_factorial*i;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Factorialul numarul '||v_factorial||' este:'||v_prod_factorial);

    for student_val IN (SELECT NUME_ZODIE,COUNT(*) as numar_zodie FROM STUDENTI s JOIN zodiac z ON TO_DATE(TO_CHAR(s.DATA_NASTERE,'DD-MM'),'DD-MM') BETWEEN TO_DATE(z.data_inceput,'DD-MM') AND TO_DATE(z.data_sfarsit,'DD-MM') GROUP BY id_zodie,nume_zodie)
    LOOP
        DBMS_OUTPUT.PUT_LINE('Zodia:'||student_val.NUME_ZODIE||' numar:'||student_val.numar_zodie);

    END LOOP;
END;