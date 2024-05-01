CREATE TABLE carga (
    id INT NOT NULL AUTO_INCREMENT,
    nombre_eleccion VARCHAR(100),
    año_eleccion INT,
    pais VARCHAR(100),
    region VARCHAR(100),
    depto VARCHAR(100),
    municipio VARCHAR(100),
    partido VARCHAR(100),
    nombre_partido VARCHAR(100),
    sexo VARCHAR(100),
    raza VARCHAR(100),
    analfabetos INT,
    alfabetos INT,
    primaria INT,
    nivel_medio INT,
    universitarios INT,
    PRIMARY KEY (id)
);

CREATE TABLE anio (
    id_anio INT NOT NULL AUTO_INCREMENT,
    anio INT,
    PRIMARY KEY (id_anio)
);


CREATE TABLE departamento (
    id_departamento INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100),
    PRIMARY KEY (id_departamento)
);

CREATE TABLE eleccion (
    id_eleccion INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100),
    PRIMARY KEY (id_eleccion)
);

CREATE TABLE genero (
    id_genero INT NOT NULL AUTO_INCREMENT,
    genero VARCHAR(100),
    PRIMARY KEY (id_genero)
);

CREATE TABLE municipio (
    id_municipio INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100),
    PRIMARY KEY (id_municipio)
);

CREATE TABLE pais (
    id_pais INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100),
    PRIMARY KEY (id_pais)
);

CREATE TABLE partido (
    id_partido INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100),
    siglas VARCHAR(10),
    PRIMARY KEY (id_partido)
);

CREATE TABLE raza (
    id_raza INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100),
    PRIMARY KEY (id_raza)
);

CREATE TABLE region (
    id_region INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100),
    PRIMARY KEY (id_region)
);

CREATE TABLE caracteristica (
    id_caracteristica INT NOT NULL AUTO_INCREMENT,
    num_analfabetas INT,
    num_alfabetas INT,
    num_primaria INT,
    num_nivel_medio INT,
    num_universitarios INT,
    raza_id_raza INT NOT NULL,
    genero_id_genero INT NOT NULL,
    PRIMARY KEY (id_caracteristica),
    FOREIGN KEY (genero_id_genero) REFERENCES genero (id_genero),
    FOREIGN KEY (raza_id_raza) REFERENCES raza (id_raza)
);

CREATE TABLE zona (
    id_zona INT NOT NULL AUTO_INCREMENT,
    pais_id_pais INT NOT NULL,
    region_id_region INT NOT NULL,
    departamento_id_departamento INT NOT NULL,
    municipio_id_municipio INT NOT NULL,
    PRIMARY KEY (id_zona),
    FOREIGN KEY (departamento_id_departamento) REFERENCES departamento (id_departamento),
    FOREIGN KEY (municipio_id_municipio) REFERENCES municipio (id_municipio),
    FOREIGN KEY (pais_id_pais) REFERENCES pais (id_pais),
    FOREIGN KEY (region_id_region) REFERENCES region (id_region)
);

CREATE TABLE resultado (
    id_resultado INT  AUTO_INCREMENT,
    partido_id_partido INT,
    eleccion_id_eleccion INT,
    anio_id_anio INT, 
    caracteristica_id_caracteristica INT,
    zona_id_zona INT,
    PRIMARY KEY (id_resultado),
    FOREIGN KEY (partido_id_partido) REFERENCES partido (id_partido),
    FOREIGN KEY (eleccion_id_eleccion) REFERENCES eleccion (id_eleccion),
    FOREIGN KEY (anio_id_anio) REFERENCES anio (id_anio),
    FOREIGN KEY (caracteristica_id_caracteristica) REFERENCES caracteristica (id_caracteristica),
    FOREIGN KEY (zona_id_zona) REFERENCES zona (id_zona)
);

