-- CONSULTA 1
SELECT 
    elec.nombre AS nombre_eleccion,
    pa.nombre AS pais,
    part.nombre AS nombre_partido,
    an.anio AS year
FROM (
    SELECT res.eleccion_id_eleccion AS eleccion_id,
           res.zona_id_zona AS zona_id,
           MAX(res.partido_id_partido) AS partido_id,
           MAX(res.anio_id_anio) AS anio_id
    FROM resultado res
    INNER JOIN (
        SELECT ele.id_eleccion AS eleccion_id,
               MAX(res.zona_id_zona) AS zona_id_mas_frecuente
        FROM eleccion ele
        INNER JOIN resultado res ON ele.id_eleccion = res.eleccion_id_eleccion
        GROUP BY ele.id_eleccion
    ) max_zona ON res.eleccion_id_eleccion = max_zona.eleccion_id
    AND res.zona_id_zona = max_zona.zona_id_mas_frecuente
    GROUP BY res.eleccion_id_eleccion, res.zona_id_zona
) AS max_ids
JOIN eleccion elec ON max_ids.eleccion_id = elec.id_eleccion
JOIN zona z ON max_ids.zona_id = z.id_zona
JOIN pais pa ON z.pais_id_pais = pa.id_pais
JOIN anio an ON max_ids.anio_id = an.id_anio
JOIN partido part ON max_ids.partido_id = part.id_partido;


-- CONSULTA 2
SELECT 
    p.nombre AS pais,
    d.nombre AS departamento,
    total_votos_mujeres,
    (total_votos_mujeres / total_votos_pais_mujeres) * 100 AS porcentaje_votos_mujeres
FROM (
    SELECT 
        z.pais_id_pais,
        SUM(CASE WHEN g.genero = 'mujeres' THEN c.num_analfabetas + c.num_alfabetas + c.num_primaria + c.num_nivel_medio + c.num_universitarios ELSE 0 END) AS total_votos_pais_mujeres
    FROM zona z
    JOIN resultado r ON z.id_zona = r.zona_id_zona
    JOIN caracteristica c ON r.caracteristica_id_caracteristica = c.id_caracteristica
    JOIN genero g ON c.genero_id_genero = g.id_genero
    WHERE g.genero = 'mujeres'
    GROUP BY z.pais_id_pais
) AS total_votos_mujeres_por_pais
JOIN (
    SELECT 
        z.pais_id_pais,
        z.departamento_id_departamento,
        SUM(CASE WHEN g.genero = 'mujeres' THEN c.num_analfabetas + c.num_alfabetas + c.num_primaria + c.num_nivel_medio + c.num_universitarios ELSE 0 END) AS total_votos_mujeres
    FROM zona z
    JOIN resultado r ON z.id_zona = r.zona_id_zona
    JOIN caracteristica c ON r.caracteristica_id_caracteristica = c.id_caracteristica
    JOIN genero g ON c.genero_id_genero = g.id_genero
    WHERE g.genero = 'mujeres'
    GROUP BY z.pais_id_pais, z.departamento_id_departamento
) AS total_votos_mujeres_por_departamento ON total_votos_mujeres_por_pais.pais_id_pais = total_votos_mujeres_por_departamento.pais_id_pais
JOIN pais p ON total_votos_mujeres_por_pais.pais_id_pais = p.id_pais
JOIN departamento d ON total_votos_mujeres_por_departamento.departamento_id_departamento = d.id_departamento
ORDER BY pais, departamento;


-- CONSULTA 3
SELECT nombre_pais, nombre_partido, num_alcaldias
FROM (
    SELECT p.nombre AS nombre_pais, partido.nombre AS nombre_partido, COUNT(resultado.anio_id_anio) AS num_alcaldias,
           ROW_NUMBER() OVER (PARTITION BY p.nombre ORDER BY COUNT(resultado.anio_id_anio) DESC) AS partido_rango
    FROM resultado
    -- Uniones
    JOIN zona ON resultado.zona_id_zona = zona.id_zona
    JOIN pais p ON zona.pais_id_pais = p.id_pais
    JOIN partido ON resultado.partido_id_partido = partido.id_partido
    -- Agrupar
    GROUP BY p.nombre, partido.nombre
) AS resultado_rango
WHERE partido_rango = 1;


-- CONSULTA 4
SELECT 
    nombre_pais,
    nombre_region
FROM (
    SELECT 
        p.nombre AS nombre_pais,
        re.nombre AS nombre_region,
        SUM(CASE WHEN r.nombre = 'INDIGENAS' THEN car.num_analfabetas + car.num_alfabetas + car.num_primaria + car.num_nivel_medio + car.num_universitarios ELSE 0 END) AS votos_indigenas,
        SUM(CASE WHEN r.nombre = 'LADINOS' THEN car.num_analfabetas + car.num_alfabetas + car.num_primaria + car.num_nivel_medio + car.num_universitarios ELSE 0 END) AS votos_ladinos,
        SUM(CASE WHEN r.nombre = 'GARIFUNAS' THEN car.num_analfabetas + car.num_alfabetas + car.num_primaria + car.num_nivel_medio + car.num_universitarios ELSE 0 END) AS votos_garifunas
    FROM resultado res
    -- Uniones
    JOIN zona z ON res.zona_id_zona = z.id_zona
    JOIN pais p ON z.pais_id_pais = p.id_pais
    JOIN region re ON z.region_id_region = re.id_region
    JOIN caracteristica car ON res.caracteristica_id_caracteristica = car.id_caracteristica
    JOIN raza r ON car.raza_id_raza = r.id_raza
    -- Agrupar
    GROUP BY p.nombre, re.nombre
) AS region_votos
WHERE votos_indigenas > votos_ladinos AND votos_indigenas > votos_garifunas;


-- CONSULTA 5
SELECT d.nombre AS nombre_departamento,
       (SUM(CASE WHEN g.genero = 'mujeres' THEN c.num_universitarios ELSE 0 END) / COUNT(r.id_resultado)) * 100 AS porcentaje_mujeres_universitarias_votaron,
       (SUM(CASE WHEN g.genero = 'hombres' THEN c.num_universitarios ELSE 0 END) / COUNT(r.id_resultado)) * 100 AS porcentaje_hombres_universitarios_votaron
FROM resultado r
-- Uniones
JOIN caracteristica c ON r.caracteristica_id_caracteristica = c.id_caracteristica
JOIN genero g ON c.genero_id_genero = g.id_genero
JOIN zona z ON r.zona_id_zona = z.id_zona
JOIN departamento d ON z.departamento_id_departamento = d.id_departamento
-- Agrupar
GROUP BY d.nombre
HAVING porcentaje_mujeres_universitarias_votaron > porcentaje_hombres_universitarios_votaron;


-- CONSULTA 6
SELECT p.nombre AS nombre_pais,
       r.nombre AS nombre_region,
       SUM(c.num_analfabetas + c.num_alfabetas + c.num_primaria + c.num_nivel_medio + c.num_universitarios) / COUNT(DISTINCT z.departamento_id_departamento) AS promedio_votos_por_departamento
FROM resultado res
-- Uniones
JOIN caracteristica c ON res.caracteristica_id_caracteristica = c.id_caracteristica
JOIN zona z ON res.zona_id_zona = z.id_zona
JOIN pais p ON z.pais_id_pais = p.id_pais
JOIN region r ON z.region_id_region = r.id_region
-- Agrupar
GROUP BY p.id_pais, r.id_region;


-- CONSULTA 7
SELECT 
    p.nombre AS nombre_pais,
    SUM(CASE WHEN r.nombre = 'INDIGENAS' THEN car.num_analfabetas + car.num_alfabetas + car.num_primaria + car.num_nivel_medio + car.num_universitarios ELSE 0 END) / SUM(car.num_analfabetas + car.num_alfabetas + car.num_primaria + car.num_nivel_medio + car.num_universitarios) * 100 AS porcentaje_votos_indigenas,
    SUM(CASE WHEN r.nombre = 'LADINOS' THEN car.num_analfabetas + car.num_alfabetas + car.num_primaria + car.num_nivel_medio + car.num_universitarios ELSE 0 END) / SUM(car.num_analfabetas + car.num_alfabetas + car.num_primaria + car.num_nivel_medio + car.num_universitarios) * 100 AS porcentaje_votos_ladinos,
    SUM(CASE WHEN r.nombre = 'GARIFUNAS' THEN car.num_analfabetas + car.num_alfabetas + car.num_primaria + car.num_nivel_medio + car.num_universitarios ELSE 0 END) / SUM(car.num_analfabetas + car.num_alfabetas + car.num_primaria + car.num_nivel_medio + car.num_universitarios) * 100 AS porcentaje_votos_garifunas
FROM resultado res
-- Uniones
JOIN zona z ON res.zona_id_zona = z.id_zona
JOIN pais p ON z.pais_id_pais = p.id_pais
JOIN caracteristica car ON res.caracteristica_id_caracteristica = car.id_caracteristica
JOIN raza r ON car.raza_id_raza = r.id_raza
-- Agrupar
GROUP BY p.nombre;


-- CONSULTA 8
SELECT p.nombre
FROM pais p
JOIN zona z ON p.id_pais = z.pais_id_pais
WHERE z.id_zona = (
    SELECT zona_id_zona
    FROM (
        SELECT zona_id_zona, COUNT(DISTINCT partido_id_partido) AS count_partidos
        FROM resultado
        GROUP BY zona_id_zona
        ORDER BY count_partidos DESC
        LIMIT 1
    ) AS max_zona
);


-- CONSULTA 9
SELECT p.nombre AS nombre_pais,
       MAX((c.num_analfabetas / (c.num_analfabetas + c.num_alfabetas + c.num_primaria + c.num_nivel_medio + c.num_universitarios)) * 100) AS mayor_porcentaje_analfabetas
FROM resultado r
-- Uniones
JOIN caracteristica c ON r.caracteristica_id_caracteristica = c.id_caracteristica
JOIN zona z ON r.zona_id_zona = z.id_zona
JOIN pais p ON z.pais_id_pais = p.id_pais
-- Agrupar
GROUP BY p.id_pais
ORDER BY mayor_porcentaje_analfabetas DESC
LIMIT 1;


-- CONSULTA 10
SELECT d.nombre AS departamento, 
       SUM(c.num_analfabetas + c.num_alfabetas + c.num_primaria + c.num_nivel_medio + c.num_universitarios) AS votos_obtenidos
FROM departamento d
-- Uniones
INNER JOIN zona z ON d.id_departamento = z.departamento_id_departamento
INNER JOIN resultado r ON z.id_zona = r.zona_id_zona
INNER JOIN caracteristica c ON r.caracteristica_id_caracteristica = c.id_caracteristica
INNER JOIN pais p ON z.pais_id_pais = p.id_pais
WHERE p.nombre = 'GUATEMALA'
-- Agrupar
GROUP BY d.nombre
HAVING votos_obtenidos > (
    SELECT SUM(c2.num_analfabetas + c2.num_alfabetas + c2.num_primaria + c2.num_nivel_medio + c2.num_universitarios)
    FROM resultado r2
    -- Uniones
    INNER JOIN zona z2 ON r2.zona_id_zona = z2.id_zona
    INNER JOIN departamento d2 ON z2.departamento_id_departamento = d2.id_departamento
    INNER JOIN caracteristica c2 ON r2.caracteristica_id_caracteristica = c2.id_caracteristica
    WHERE d2.nombre = 'Guatemala'
)
ORDER BY votos_obtenidos DESC;