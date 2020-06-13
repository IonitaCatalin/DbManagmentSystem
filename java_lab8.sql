create table artists(
    id integer not null,
    name varchar(100) not null,
    country varchar(100),
    primary key (id)
);

create table albums(
    id integer not null,
    name varchar(100) not null,
    artist_id integer not null references artists on delete cascade,
    release_year integer,
    primary key (id)
);

CREATE SEQUENCE artists_sequence
START WITH 1
INCREMENT BY 1;


CREATE SEQUENCE albums_sequence
START WITH 1
INCREMENT BY 1;

CREATE SEQUENCE chart_sequence
START WITH 1
INCREMENT BY 1;


CREATE TABLE charts(
    id integer not null,
    name varchar2(50),
    primary key (id)
);

CREATE TABLE chart_albums(
    chart_id not null references charts on delete cascade,
    ranking integer,
    album_id integer not null references albums(id) on delete cascade
);

DELETE FROM albums where id is not null;
DELETE FROM artists WHERE id is not null;
DELETE FROM charts WHERE id is not null;
DELETE FROM chart_albums WHERE chart_id is not null;
COMMIT;


SELECT arts.name,NVL(SUM(charts.ranking),0) as overall_value
FROM CHART_ALBUMS charts JOIN ALBUMS albs ON albs.id=charts.album_id
RIGHT OUTER JOIN ARTISTS arts ON arts.id=albs.artist_id
GROUP BY arts.id,arts.name ORDER BY overall_value DESC;
