-- PRIMERO CARGAR CSV DE LA TABLA CARGA --------------------------------------------------------------------

-- PAIS --------------------------------------------------------------------
INSERT INTO pais (nombre)
SELECT DISTINCT pais FROM carga;

-- REGION --------------------------------------------------------------------
INSERT INTO region  (nombre)
SELECT DISTINCT region  FROM carga;

-- DEPARTAMENTO --------------------------------------------------------------------
INSERT INTO departamento  (nombre)
SELECT DISTINCT depto  FROM carga;

-- MUNICIPIO --------------------------------------------------------------------
INSERT INTO municipio  (nombre)
SELECT DISTINCT municipio  FROM carga;

-- PARTIDO --------------------------------------------------------------------
INSERT INTO partido (nombre, siglas)
SELECT nombre_partido, partido
FROM carga
GROUP BY nombre_partido, partido;
INSERT INTO partido (nombre, siglas)
SELECT nombre_partido, partido
FROM carga
GROUP BY nombre_partido, partido;

DELETE p1 FROM partido p1
INNER JOIN (
    SELECT siglas, MIN(id_partido) as min_id
    FROM partido
    GROUP BY siglas
) p2 ON p1.siglas = p2.siglas AND p1.id_partido != p2.min_id;

-- ELECCION --------------------------------------------------------------------
INSERT INTO eleccion  (nombre)
SELECT DISTINCT nombre_eleccion  FROM carga;

-- ANIO --------------------------------------------------------------------
INSERT INTO anio  (anio)
SELECT DISTINCT año_eleccion FROM carga;

-- GENERO --------------------------------------------------------------------
INSERT INTO genero (genero)
SELECT DISTINCT sexo  FROM carga;

-- RAZA --------------------------------------------------------------------
INSERT INTO raza (nombre)
SELECT DISTINCT raza  FROM carga;

-- CARACTERISTICA --------------------------------------------------------------------
INSERT INTO caracteristica (num_analfabetas, num_alfabetas, num_primaria, num_nivel_medio, num_universitarios, raza_id_raza, genero_id_genero)
SELECT c.analfabetos, c.alfabetos, c.primaria, c.nivel_medio, c.universitarios, r.id_raza, g.id_genero
FROM carga c
INNER JOIN raza r ON c.raza = r.nombre
INNER JOIN genero g ON c.sexo = g.genero;

-- ZONA --------------------------------------------------------------------
INSERT INTO zona (pais_id_pais, region_id_region, departamento_id_departamento, municipio_id_municipio)
SELECT p.id_pais, r.id_region, d.id_departamento, m.id_municipio
FROM carga c
INNER JOIN pais p ON c.pais = p.nombre
INNER JOIN region r ON c.region = r.nombre
INNER JOIN departamento d ON c.depto = d.nombre
INNER JOIN municipio m ON c.municipio = m.nombre
GROUP BY p.id_pais, r.id_region, d.id_departamento, m.id_municipio;

-- RESULTADO --------------------------------------------------------------------
INSERT INTO resultado (partido_id_partido, eleccion_id_eleccion, anio_id_anio)
SELECT partido.id_partido, eleccion.id_eleccion, anio.id_anio
FROM carga
INNER JOIN partido ON carga.partido = partido.siglas AND carga.nombre_partido = partido.nombre
INNER JOIN eleccion ON carga.nombre_eleccion = eleccion.nombre
INNER JOIN anio ON carga.año_eleccion = anio.anio;

UPDATE resultado r
LEFT JOIN (
    SELECT 
        z.id_zona,
        c.id AS carga_id,
        ROW_NUMBER() OVER (ORDER BY c.id) AS row_num
    FROM carga c
    LEFT JOIN zona z ON 
        c.pais = (SELECT nombre FROM pais WHERE id_pais = z.pais_id_pais) AND 
        c.region = (SELECT nombre FROM region WHERE id_region = z.region_id_region) AND 
        c.depto = (SELECT nombre FROM departamento WHERE id_departamento = z.departamento_id_departamento) AND 
        c.municipio = (SELECT nombre FROM municipio WHERE id_municipio = z.municipio_id_municipio)
) AS zonas ON r.id_resultado = zonas.carga_id
SET r.zona_id_zona = zonas.id_zona;

UPDATE resultado r
LEFT JOIN (
    SELECT 
        c.id_caracteristica,
        r.id_resultado,
        ROW_NUMBER() OVER (ORDER BY r.id_resultado) AS row_num
    FROM resultado r
    LEFT JOIN caracteristica c ON r.id_resultado = c.id_caracteristica
) AS caracteristicas ON r.id_resultado = caracteristicas.id_resultado
SET r.caracteristica_id_caracteristica = caracteristicas.id_caracteristica;