

CREATE OR REPLACE PROCEDURE printStatistics
IS
    v_no_tables INTEGER;
    v_no_procedures INTEGER;
    v_no_indexes INTEGER;
    v_no_views INTEGER;
    v_no_packages INTEGER;
    v_no_types INTEGER;
    v_has_constraints VARCHAR2(20);
    v_indexes VARCHAR2(200);
    v_constraints VARCHAR2(1500);
    v_is_nested VARCHAR2(20);
    v_procedure_lines INTEGER;
    v_function_lines INTEGER;

    CURSOR v_cursor_table IS SELECT * FROM USER_TABLES;
    CURSOR v_cursor_index IS SELECT * FROM USER_INDEXES;
    CURSOR v_cursor_constraint IS SELECT * FROM USER_CONSTRAINTS;
    CURSOR v_cursor_procedures IS SELECT * FROM USER_PROCEDURES WHERE OBJECT_TYPE='PROCEDURE';
    CURSOR v_cursor_functions IS SELECT * FROM USER_PROCEDURES WHERE OBJECT_TYPE='FUNCTION';
    CURSOR v_cursor_types IS SELECT * FROM USER_TYPES;
    CURSOR v_cursor_indexes IS SELECT * FROM USER_INDEXES;
    CURSOR v_cursor_views IS SELECT * FROM USER_VIEWS;
    CURSOR v_cursor_packages IS SELECT * FROM USER_PROCEDURES WHERE OBJECT_TYPE='PACKAGE';
BEGIN
    SELECT COUNT(*) INTO v_no_tables FROM USER_TABLES;
    SELECT COUNT(*) INTO v_no_procedures FROM USER_PROCEDURES;
    SELECT COUNT(*) INTO v_no_indexes FROM USER_INDEXES;
    SELECT COUNT(*) INTO v_no_views FROM USER_VIEWS;
    SELECT COUNT(*) INTO v_no_packages FROM USER_OBJECTS WHERE OBJECT_TYPE='PACKAGE';
    SELECT COUNT(*) INTO v_no_types FROM USER_OBJECTS WHERE OBJECT_TYPE='TYPE';

    DBMS_OUTPUT.PUT_LINE('USER CREATED ABOUT:');
    DBMS_OUTPUT.PUT_LINE('<TABLES:'||v_no_tables||'>');
    DBMS_OUTPUT.PUT_LINE('<PROCEDURES:'||v_no_procedures||'>');
    DBMS_OUTPUT.PUT_LINE('<INDEXES:'||v_no_indexes||'>');
    DBMS_OUTPUT.PUT_LINE('<VIEWS:'||v_no_views||'>');

    DBMS_OUTPUT.PUT_LINE('______________TABLES______________');
    FOR v_iterator IN v_cursor_table LOOP
        SELECT DECODE(COUNT(*),0,'NO','YES') INTO v_has_constraints FROM USER_CONSTRAINTS WHERE TABLE_NAME=v_iterator.TABLE_NAME;
        SELECT DECODE(COUNT(*),0,'REGULAR','NESTEd') INTO v_is_nested FROM USER_NESTED_TABLES WHERE TABLE_NAME=v_iterator.TABLE_NAME;
        v_indexes:='';
        FOR v_indexes_iterator IN v_cursor_index LOOP
            IF v_indexes_iterator.TABLE_NAME=v_iterator.TABLE_NAME
            THEN
                v_indexes:=v_indexes_iterator.INDEX_NAME||','||v_indexes;
            END IF;
        END LOOP;
        v_constraints:='';
        FOR v_constraints_iterator IN v_cursor_constraint LOOP
            IF v_constraints_iterator.TABLE_NAME=v_iterator.TABLE_NAME
            THEN
                v_constraints:=v_constraints_iterator.CONSTRAINT_NAME||'('||v_constraints_iterator.CONSTRAINT_TYPE||')'||'['||v_constraints_iterator.SEARCH_CONDITION||']'||','||v_constraints;
            END IF;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('Name:'||v_iterator.TABLE_NAME ||'  '||'ROWS:'||v_iterator.NUM_ROWS||'  '||'CONSTRAINTS:'||v_has_constraints||'-'||v_constraints||'  '||'INDEXES:'||v_indexes||'  '||'TYPE:'||v_is_nested);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('______________Procedures______________');
    FOR v_iterator IN v_cursor_procedures LOOP
        SELECT COUNT(*) INTO v_procedure_lines FROM USER_SOURCE WHERE NAME=v_iterator.OBJECT_NAME;
        DBMS_OUTPUT.PUT_LINE('Name:'||v_iterator.OBJECT_NAME||'  '||'Lines of code:'||v_procedure_lines||'  '||'Deterministics:'||v_iterator.DETERMINISTIC);
    END LOOP;

     DBMS_OUTPUT.PUT_LINE('______________Functions______________');
    FOR v_iterator IN v_cursor_functions LOOP
        SELECT COUNT(*) INTO v_Function_lines FROM USER_SOURCE WHERE NAME=v_iterator.OBJECT_NAME;
        DBMS_OUTPUT.PUT_LINE('Name:'||v_iterator.OBJECT_NAME||'  '||'Lines of code:'||v_function_lines||'  '||'Deterministics:'||v_iterator.DETERMINISTIC);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('______________Types______________');
    FOR v_iterator IN v_cursor_types LOOP
        DBMS_OUTPUT.PUT_LINE('Name:'||v_iterator.TYPE_NAME||'  '||'Typecode:'||v_iterator.TYPECODE||'  '||'Instanciable:'||v_iterator.INSTANTIABLE||'  '||'Type_OID:'||v_iterator.TYPE_OID);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('______________Indexes______________');
    FOR v_iterator IN v_cursor_indexes LOOP
        DBMS_OUTPUT.PUT_LINE('Name:'||v_iterator.INDEX_NAME||'  '||'Type:'||v_iterator.INDEX_TYPE||'  '||'Table_owner:'||v_iterator.TABLE_OWNER||'  '||'Tables_space_name:'||v_iterator.TABLESPACE_NAME||'  '||'Compression:'||v_iterator.COMPRESSION);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('______________Views______________');
    FOR v_iterator IN v_cursor_views LOOP
        DBMS_OUTPUT.PUT_LINE('Name:'||v_iterator.VIEW_NAME||'  '||'Text:'||v_iterator.TEXT||'  '||'Read_only'||v_iterator.READ_ONLY);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('______________Packages______________');
    FOR v_iterator IN v_cursor_packages LOOP
        DBMS_OUTPUT.PUT_LINE('Name:'||v_iterator.OBJECT_NAME||'  '||'Procedure_name:'||v_iterator.PROCEDURE_NAME||'  '||'Object_id'||v_iterator.OBJECT_ID||'  '||'Pipelined:'||v_iterator.PIPELINED);
    END LOOP;
END;

BEGIN
    printStatistics();
END;