DROP DATABASE IF EXISTS austral;
CREATE DATABASE austral;
USE austral;
CREATE TABLE autores (
    id_autor INT AUTO_INCREMENT,
    nombre   VARCHAR(80) NOT NULL,
    pais     VARCHAR(60),
    genero   ENUM('Cómic', 'Ensayo', 'Infantil', 'Novela', 'Poesía') NOT NULL,
    PRIMARY KEY (id_autor)
);

CREATE TABLE colecciones (
    id_coleccion      INT AUTO_INCREMENT,
    titulo            VARCHAR(120) NOT NULL,
    fecha_publicacion DATE NOT NULL,
    PRIMARY KEY (id_coleccion)
);

CREATE TABLE libros (
    id_libro            INT AUTO_INCREMENT,
    id_autor            INT NOT NULL,
    id_coleccion        INT,
    titulo              VARCHAR(120) NOT NULL,
    paginas             INT,
    ejemplares_vendidos INT,
    anio                INT,
    PRIMARY KEY (id_libro),
    FOREIGN KEY (id_autor) REFERENCES autores (id_autor),
    FOREIGN KEY (id_coleccion) REFERENCES colecciones (id_coleccion)
);

CREATE TABLE pagos (
    id_pago    INT AUTO_INCREMENT,
    id_autor   INT NOT NULL,
    fecha_pago DATE NOT NULL,
    monto      DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_pago),
    FOREIGN KEY (id_autor) REFERENCES autores (id_autor)
);


INSERT INTO autores (nombre, pais, genero) VALUES
    ('Elena Pizarro',     'Chile',          'Novela'),
    ('Harold Finch',      'Inglaterra',     'Ensayo'),
    ('Rodrigo Bahamonde', 'Chile',          'Poesía'),
    ('Valentina Correa',  'Argentina',      'Infantil'),
    ('Nora Keller',       'Estados Unidos', 'Novela'),
    ('Kenji Arakawa',     NULL,             'Cómic');

INSERT INTO libros (id_autor, titulo, paginas, ejemplares_vendidos, anio) VALUES
    (1, 'Cielo de Enero',      210, 1500, 2024),
    (1, 'Marea Baja',          185,  800, 2023),
    (1, 'El Norte',            200, 2200, 2024),
    (2, 'Estrellas que Caen',  240, 3000, 2022),
    (2, 'Máquinas',            215,  450, 2024),
    (3, 'Luz Artificial',      300, 1200, 2024),
    (3, 'Ruido Blanco',        260,  600, 2023),
    (4, 'El Barrio de Lila',   190, 5000, 2024),
    (4, 'Antes del Amanecer',  205, 2700, 2024),
    (4, 'La Calle 8',          175,  900, 2023),
    (5, 'Flor de Hierro',      195, 4100, 2024),
    (5, 'Hora Dorada',         220, 1800, 2022);



-- Consulta 1
SELECT nombre, genero
FROM autores
WHERE pais <> 'Chile' OR pais IS NULL
ORDER BY nombre;

-- Consulta 2
SELECT titulo, paginas
FROM libros
WHERE paginas BETWEEN 190 AND 220
ORDER BY paginas ASC;

-- Consulta 3
SELECT COUNT(*)                     AS total_libros,
       SUM(ejemplares_vendidos)     AS total_ejemplares,
       ROUND(AVG(paginas), 2)       AS promedio_paginas,
       MIN(anio)                    AS anio_mas_antiguo,
       MAX(ejemplares_vendidos)     AS max_ejemplares_libro
FROM libros;

-- Consulta 4
SELECT DISTINCT genero
FROM autores
ORDER BY genero;

-- Consulta 5
SELECT a.nombre, COUNT(*) AS libros_2024
FROM autores AS a
JOIN libros AS l ON l.id_autor = a.id_autor
WHERE l.anio = 2024
GROUP BY a.id_autor, a.nombre
HAVING COUNT(*) > 1
ORDER BY a.nombre;

-- Consulta 6
SELECT titulo, ejemplares_vendidos
FROM libros
WHERE anio = 2024 AND ejemplares_vendidos > 2000
ORDER BY ejemplares_vendidos DESC
LIMIT 3;


SET SQL_SAFE_UPDATES = 0;

-- Consulta 7
INSERT INTO libros (id_autor, titulo, paginas, ejemplares_vendidos, anio)
VALUES ((SELECT id_autor FROM autores WHERE nombre = 'Rodrigo Bahamonde'),
        'Papel Mojado', 260, 50, 2024);

-- Consulta 7: SELECT antes del DELETE
SELECT * FROM libros WHERE titulo = 'Papel Mojado';

-- Consulta 7: DELETE
DELETE FROM libros WHERE titulo = 'Papel Mojado';

-- Consulta 7: SELECT después del DELETE
SELECT * FROM libros WHERE titulo = 'Papel Mojado';

-- Consulta 8: SELECT previo
SELECT titulo, ejemplares_vendidos FROM libros WHERE titulo = 'Cielo de Enero';

-- Consulta 8: UPDATE
UPDATE libros
SET ejemplares_vendidos = ejemplares_vendidos + 100
WHERE titulo = 'Cielo de Enero';

-- Consulta 8: SELECT posterior
SELECT titulo, ejemplares_vendidos FROM libros WHERE titulo = 'Cielo de Enero';

-- Consulta 9: carga de colecciones y asignación de los doce libros
INSERT INTO colecciones (titulo, fecha_publicacion) VALUES
    ('Narrativa Austral',          '2023-04-10'),
    ('Pensamiento Contemporáneo',  '2022-09-05'),
    ('Lecturas del Barrio',        '2024-03-18');

UPDATE libros SET id_coleccion = 1 WHERE id_libro IN (1, 2, 3, 11, 12);
UPDATE libros SET id_coleccion = 2 WHERE id_libro IN (4, 5, 6, 7);
UPDATE libros SET id_coleccion = 3 WHERE id_libro IN (8, 9, 10);

-- Consulta 9
SELECT l.titulo AS libro, c.titulo AS coleccion, c.fecha_publicacion
FROM libros AS l
JOIN colecciones AS c ON c.id_coleccion = l.id_coleccion
ORDER BY c.fecha_publicacion, l.titulo;

-- Consulta 10: carga de pagos (dos de ellos al mismo autor)
INSERT INTO pagos (id_autor, fecha_pago, monto) VALUES
    (1, '2024-03-15', 150000.00),
    (1, '2024-09-20', 200000.00),
    (4, '2024-06-10', 320500.50),
    (5, '2024-07-01', 275000.00);

-- Consulta 10 (sentencia 1): pagos con nombre del autor, fecha y monto
SELECT a.nombre, p.fecha_pago, p.monto
FROM pagos AS p
JOIN autores AS a ON a.id_autor = p.id_autor
ORDER BY p.fecha_pago;

-- Consulta 10 (sentencia 2): total pagado a cada autor
SELECT a.nombre, SUM(p.monto) AS total_pagado
FROM autores AS a
JOIN pagos AS p ON p.id_autor = a.id_autor
GROUP BY a.id_autor, a.nombre
ORDER BY a.nombre;
