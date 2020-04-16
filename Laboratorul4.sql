create or replace package exm_package
is
    function f_exista_student(IN_id in studenti.id%type) return boolean;
    function get_scadenta (IN_data_scadenta IN date) return varchar2;

end exm_package;
/
create or replace package body exm_package
is

    function f_exista_student(IN_id in studenti.id%type)
    return boolean
    is
         e_std boolean;
         p_number number;--0 daca studentul nu exista, 1 daca exista
    begin
          select count(*) into p_number from studenti where id=IN_id;
          if p_number=0 then dbms_output.put_line('Studentul cu id-ul '||IN_id||' nu exista in baza de date !');
            e_std:=false;--return false;
          else e_std:=true;--return true;
          end if;
          return e_std;
    end f_exista_student;

function get_scadenta (IN_data_scadenta IN date)
return varchar2
is
  p_detail varchar2(100);
begin
  if IN_data_scadenta = sysdate then
    p_detail := 'Data scadenta este azi';
  elsif IN_data_scadenta > sysdate then
    p_detail := 'Plata poate sa mai astepte';
  else
    p_detail := 'Sunteti in intarziere cu plata !';
  end if;
  return p_detail;
end;


end exm_package;
DECLARE
    v_exista boolean;
    v_scadent varchar2(100);
BEGIN
    v_exista:=exm_package.f_exista_student(12);
    v_scadent:=exm_package.get_scadenta(TO_DATE('15-12-2019','DD-MM-YYYY'));
end;


create or replace procedure add_new_friendship(p_id1 studenti.id%type,p_id2 studenti.id%type)
IS
    v_exists1 number;
    v_exists2 number;
    v_exists_friendship number;
BEGIN

    SELECT COUNT(*) INTO v_exists1 FROM STUDENTI WHERE id=p_id1;
    SELECT COUNT(*) INTO v_exists2 FROM STUDENTI WHERE id=p_id2;

    IF (v_exists1=0 OR v_exists2=0)
    THEN
        DBMS_OUTPUT.PUT_LINE('Unul dintre studentii dati nu exista!');
    ELSE
        SELECT COUNT(*) INTO v_exists_friendship FROM PRIETENI WHERE ID_STUDENT1=p_id1 AND ID_STUDENT2=p_id2;
        IF(v_exists_friendship>1)
        THEN
            DBMS_OUTPUT.PUT_LINE('Relatia de prietenie pe care incercati sa o adaugati exista deja!');
        ELSE
            INSERT INTO PRIETENI VALUES ((SELECT MAX(id)+1 FROM PRIETENI),p_id1,p_id2,SYSDATE,SYSDATE);
        END IF;
    END IF;
END;

BEGIN
    add_new_friendship(240,156);
end;

create or replace type curs_object IS OBJECT
{
    id_curs cursuri.id%type,
    titlu_curs cursuri.titlu_curs %type,
    nr_note number;
}

create or replace function function_courses
return curs_object
IS
    v_main_obj curs_object;
    v_min_id cursuri.id%type;

BEGIN

    FOR i IN (select id AS id_c,titlu_curs FROM CURSURI) LOOP
        FOR j in (SELECT id FROM CURSURI c JOIN NOTE n ON n.id=c.id WHERE n.valoare=10  AND i.id_c=c.id GROUP BY id HAVING COUNT(valoare)=
                    (SELECT MIN(COUNT(valoare)) FROM CURSURI c join NOTE n on n.id=c.id WHERE valoare=10)) LOOP

            end loop;
        end loop;
END;
