CREATE OR REPLACE TYPE Masina AS OBJECT
(
    motorizare VARCHAR2(10),
    producator VARCHAR2(20),
    data_fabricatie DATE,
    nr_kilometrii NUMBER,
    serie VARCHAR2(10),
    NOT FINAL MEMBER PROCEDURE print_valoare,
    NOT FINAL MEMBER PROCEDURE print_identitate_vehicul,
    MEMBER PROCEDURE print_uzura,
    MAP MEMBER FUNCTION data_fabricatie_in_zile RETURN NUMBER,
    CONSTRUCTOR FUNCTION Masina(p_producator VARCHAR2,p_serie VARCHAR2) RETURN SELF AS RESULT
) NOT FINAL;


CREATE OR REPLACE TYPE BODY Masina AS
    MEMBER PROCEDURE print_valoare IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Valoarea curenta a masinii este de:'||(20000-(nr_kilometrii)*0.1)||' Euro');
    END;
    MEMBER PROCEDURE print_identitate_vehicul IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Masina'||'('||serie||')'||' dumneavoastra a fost produsa de: '||producator||' in anul:'|| data_fabricatie || ' cu motorizarea:'||motorizare || ' si are :'||nr_kilometrii||' kilometriii ');
    END;
    MEMBER PROCEDURE print_uzura IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Masina dumneavostra dupa calcule este uzata in proportie de:'||TRUNC(DBMS_RANDOM.VALUE(1,100),2)||'%');
    END;
    MAP MEMBER FUNCTION data_fabricatie_in_zile RETURN NUMBER IS
    BEGIN
        RETURN (SYSDATE-data_fabricatie);
    END;

    CONSTRUCTOR FUNCTION Masina(p_producator VARCHAR2,p_serie VARCHAR2) RETURN SELF AS RESULT
    IS
    BEGIN
        SELF.PRODUCATOR:=p_producator;
        SELF.SERIE:=p_serie;
        SELF.NR_KILOMETRII:=0;
        SELF.data_FABRICATIE:=SYSDATE;
        IF(p_producator='Mercedes')
        THEN
            SELF.MOTORIZARE:='Diesel';
        ELSE
            SELF.MOTORIZARE:='Benzina';
        END IF;
        RETURN;
    END;
END;


CREATE OR REPLACE TYPE Ferrari UNDER Masina
(
    capacitate_cilindrica NUMBER,
    OVERRIDING MEMBER PROCEDURE print_valoare
)NOT FINAL;
CREATE OR REPLACE TYPE BODY Ferrari AS
    OVERRIDING MEMBER PROCEDURE print_valoare IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Valoare vehiculului dumneavoastra este de:'||200000||'$');
    END;
END;


DROP TABLE tabel_masini;
/
CREATE TABLE tabel_masini(masina_col Masina);
/
DECLARE
    masina_de_test Masina:=Masina('Kia','Sportage');
    masina_ferrari_de_test Masina:=Masina('Diesel','Ferrari',TO_DATE('2012/03/14','yyyy/mm/dd'),1221,'Aventador');
BEGIN
    INSERT INTO TABEL_MASINI VALUES (Masina('Diesel','Mercedes',TO_DATE('1994/12/16','yyyy/mm/dd'),120000,'XZ2'));
    INSERT INTO TABEL_MASINI VALUES (Masina('Benzina','Citroen',TO_DATE('2015/03/23','yyyy/mm/dd'),5000,'FAST-C2'));
    INSERT INTO TABEL_MASINI VALUES (Masina('Diesel','Wolkswagen',TO_DATE('2001/01/01','yyyy/mm/dd'),250000,'GOlF IV'));
    INSERT INTO TABEL_MASINI VALUES (Masina('Benzina','Kia',TO_DATE('2002/06/12','yyyy/mm/dd'),25000,'SPORTAGE'));
    INSERT INTO TABEL_MASINI VALUES (Masina('Diesel','Mercedes',TO_DATE('2003/07/12','yyyy/mm/dd'),120000,'eXpensive'));
    masina_de_test.PRINT_IDENTITATE_VEHICUL();
    masina_de_test.PRINT_VALOARE();
    masina_ferrari_de_test.PRINT_IDENTITATE_VEHICUL();
    masina_ferrari_de_test.PRINT_VALOARE();
END;

SELECT * FROM TABEL_MASINI ORDER BY masina_col;



