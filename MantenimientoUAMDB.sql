/* Trabajo de Base de Datos, sobre el mantenimiento preventivo y correctivo
de los dispositivos de la uam */

USE master
GO

-- Por si esta base ya existe este comando la borra
-- Busca al igual el nombre y si lo encuentra lo borra
IF DB_ID('MantenimientoUAMDB') IS NOT NULL
BEGIN
    ALTER DATABASE MantenimientoUAMDB 
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    DROP DATABASE MantenimientoUAMDB;
END
GO

-- Creacion de la base de datos y use para acceder a este
CREATE DATABASE MantenimientoUAMDB;
GO

USE MantenimientoUAMDB;
GO

-- Creacion de los 3 esquemas de nuestro proyecto q actuan practicamente
-- Como categorizaciones de las 8 tablas siguientes.
CREATE SCHEMA Seguridad;
GO

CREATE SCHEMA Catalogo;
GO

CREATE SCHEMA Mantenimiento;
GO

-- Tabla Edificio 
CREATE TABLE Catalogo.Edificio (
    idEdificio INT IDENTITY PRIMARY KEY,
    nombreEdificio VARCHAR(50) NOT NULL UNIQUE,
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME NULL,
    deleted_at DATETIME NULL -- Ponemos las 2 columnas de edificio, aparte de la auditoria (osea isactive, created, updated y deleted)
);

-- Tabla TipoDispositivo
CREATE TABLE Catalogo.TipoDispositivo (
    idTipoDispositivo INT IDENTITY PRIMARY KEY,
    nombreTipo VARCHAR(30) NOT NULL UNIQUE,
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME NULL,
    deleted_at DATETIME NULL
);

-- Tabla EstadoDispositivo
CREATE TABLE Catalogo.EstadoDispositivo (
    idEstado INT IDENTITY PRIMARY KEY,
    estado VARCHAR(30) NOT NULL UNIQUE,
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME NULL,
    deleted_at DATETIME NULL
);

-- Tabla TipoMantenimiento
CREATE TABLE Catalogo.TipoMantenimiento (
    idTipoMantenimiento INT IDENTITY PRIMARY KEY,
    nombreTipoMantenimiento VARCHAR(30) NOT NULL UNIQUE,
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME NULL,
    deleted_at DATETIME NULL
);
/* Todas estas tablas entran a el esquema de catalogo, por que
hablamos de tipos de cosas, dispositivos o estados y un listado de los mismos en la uam
nos referimos a conecciones que iran proximamente con lo que sera puesto en mantenimiento
*/

-- Tabla Tecnico
CREATE TABLE Seguridad.Tecnico (
    idTecnico INT IDENTITY PRIMARY KEY,
    nombreTecnico VARCHAR(80) NOT NULL,
    telefono VARCHAR(15) NULL,
    correo VARCHAR(100) NULL,
    departamento VARCHAR(50) NULL,
    fechaNacimiento DATE NULL,
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME NULL,
    deleted_at DATETIME NULL,
    CONSTRAINT chk_correo CHECK (correo LIKE '%@%' OR correo IS NULL) -- El correo se acepta cuando lleva un @ en el.

);
/* Para el tecnico, solo esta seguridad, ya que se nos explica que seguridad es para
quienes acceden o manipulan parte de los datos, como usuarios y demas, en este caso
los tecnicos con los dispositivos */


-- Tabla Salon
CREATE TABLE Mantenimiento.Salon (
    idSalon INT IDENTITY PRIMARY KEY,
    codigoSalon VARCHAR(10) NOT NULL UNIQUE,
    piso TINYINT NOT NULL,
    idEdificio INT NOT NULL,
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME NULL,
    deleted_at DATETIME NULL,
    CONSTRAINT chk_piso CHECK (piso > 0), -- No pueden haber pisos inexistentes.
    FOREIGN KEY (idEdificio) REFERENCES Catalogo.Edificio(idEdificio)
);


-- Tabla Dispositivo
CREATE TABLE Mantenimiento.Dispositivo (
    idDispositivo INT IDENTITY PRIMARY KEY,
    codigoDispositivo VARCHAR(20) NOT NULL UNIQUE,
    idTipoDispositivo INT NOT NULL,
    idSalon INT NOT NULL,
    idEstado INT NOT NULL,
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME NULL,
    deleted_at DATETIME NULL,
    FOREIGN KEY (idTipoDispositivo) REFERENCES Catalogo.TipoDispositivo(idTipoDispositivo),
    FOREIGN KEY (idSalon) REFERENCES Mantenimiento.Salon(idSalon),
    FOREIGN KEY (idEstado) REFERENCES Catalogo.EstadoDispositivo(idEstado)
);


-- Tabla Mantenimiento
CREATE TABLE Mantenimiento.Mantenimiento (
    idMantenimiento INT IDENTITY PRIMARY KEY,
    idDispositivo INT NOT NULL,
    idTipoMantenimiento INT NOT NULL,
    fechaMantenimiento DATE NOT NULL,
    idTecnico INT NOT NULL,
    observacion VARCHAR(250) NULL,
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME NULL,
    deleted_at DATETIME NULL,
    CONSTRAINT chk_fecha CHECK (fechaMantenimiento <= GETDATE()), -- Uno no viene del futuro, eso hace que no hayan fechas fuera de lugar.
    FOREIGN KEY (idDispositivo) REFERENCES Mantenimiento.Dispositivo(idDispositivo),
    FOREIGN KEY (idTipoMantenimiento) REFERENCES Catalogo.TipoMantenimiento(idTipoMantenimiento),
    FOREIGN KEY (idTecnico) REFERENCES Seguridad.Tecnico(idTecnico)
);

/* Las tablas mantenimiento van donde se supone sera los datos mas importantes
sobre el mantenimiento, los dispositivos a los que vamos a darles mantenimiento (bueno, el tecnico)
el donde estan y claramente el mantenimiento a darse */

/* Siempre ponemos el is active en 1 por que es 0 y 1, False y True, ya que es True que 
todas nuestras tablas estan activas, asi no las borramos */



/* Inserts segun sus catalogos (schemas) */

/* Schema 1 - Catalogo */

-- Tabla Edificio
INSERT INTO Catalogo.Edificio (nombreEdificio)
VALUES 
('EdificioC'),
('EdificioO');

-- Tabla TipoDispositivo
INSERT INTO Catalogo.TipoDispositivo (nombreTipo)
VALUES 
('Computadora'),
('Proyector');

-- Tabla EstadoDispositivo
INSERT INTO Catalogo.EstadoDispositivo (estado)
VALUES 
('Bueno'),
('En Revisión'),
('En Mantenimiento'),
('Fuera de Servicio');

-- Tabla TipoMantenimiento
INSERT INTO Catalogo.TipoMantenimiento (nombreTipoMantenimiento)
VALUES 
('Preventivo'),
('Correctivo');

/* Schema 2 - Seguridad */

-- Tabla Tecnico (El Schema es "seguridad" pq son quienes interactuan con el sistema)
INSERT INTO Seguridad.Tecnico 
(nombreTecnico, telefono, correo, departamento, fechaNacimiento)
VALUES
('Juan Pérez', '8564-5781', 'jup@uamv.edu.ni', 'Soporte Tecnico', '1990-03-15'),
('Ana Gómez', '5875-4824', 'anago@uamv.edu.ni', 'Soporte Tecnico', '1992-07-21'),
('Carlos Martínez', '6415-7545', 'carmar@uamv.edu.ni', 'Soporte Tecnico', '1988-11-09'),
('María López', '6484-0514', 'marilo@uamv.edu.ni', 'Soporte Tecnico', '1995-01-30'),
('José Ramírez', '5720-6187', 'josram@uamv.edu.ni', 'Soporte Tecnico', '1991-05-18'),
('Lucía Hernández', '2486-7921', 'luchen@uamv.edu.ni', 'Soporte Tecnico', '1994-09-12'),
('Pedro Castillo', '1627-4523', 'pecast@uamv.edu.ni', 'Soporte Tecnico', '1989-02-25'),
('Sofía Torres', '7862-5884', 'sotor@uamv.edu.ni', 'Soporte Tecnico', '1996-12-14'),
('Miguel Sánchez', '7874-9752', 'misan@uamv.edu.ni', 'Soporte Tecnico', '1993-04-08'),
('Daniela Flores', '3875-9765', 'daflo@uamv.edu.ni', 'Soporte Tecnico', '1997-08-19'),
('Andrés Morales', '2597-9865', 'andmor@uamv.edu.ni', 'Soporte Tecnico', '1990-10-27'),
('Valeria Ruiz', '8965-3684', 'varuiz@uamv.edu.ni', 'Soporte Tecnico', '1998-06-03'),
('Fernando Cruz', '5451-9860', 'fercruz@uamv.edu.ni', 'Soporte Tecnico', '1987-01-11'),
('Camila Navarro', '9863-7821', 'canav@uamv.edu.ni', 'Soporte Tecnico', '1999-07-29'),
('Ricardo Mendoza', '3972-6982', 'rimendo@uamv.edu.ni', 'Soporte Tecnico', '1992-03-05'),
('Elena Vargas', '9864-5686', 'elevarg@uamv.edu.ni', 'Soporte Tecnico', '1995-11-22');

/* Schema 3 - Mantenimiento */

-- Tabla Salon
-- ============================================================
-- INSERT Mantenimiento.Dispositivo
-- 380 dispositivos: 368 computadoras + 12 proyectores
-- Columnas: codigoDispositivo, idTipoDispositivo, idSalon, idEstado
-- idTipoDispositivo: 1 = Computadora | 2 = Proyector
-- idEstado: 1 = Bueno | 2 = En Revisión | 3 = En Mantenimiento | 4 = Fuera de Servicio
-- ============================================================

-- SALON C-107 (idSalon = 1) — 32 PCs + 1 Proyector
INSERT INTO Mantenimiento.Dispositivo (codigoDispositivo, idTipoDispositivo, idSalon, idEstado)
VALUES
('PC-C107-01', 1, 1, 2),
('PC-C107-02', 1, 1, 1),
('PC-C107-03', 1, 1, 3),
('PC-C107-04', 1, 1, 2),
('PC-C107-05', 1, 1, 1),
('PC-C107-06', 1, 1, 1),
('PC-C107-07', 1, 1, 1),
('PC-C107-08', 1, 1, 1),
('PC-C107-09', 1, 1, 1),
('PC-C107-10', 1, 1, 1),
('PC-C107-11', 1, 1, 1),
('PC-C107-12', 1, 1, 1),
('PC-C107-13', 1, 1, 1),
('PC-C107-14', 1, 1, 1),
('PC-C107-15', 1, 1, 1),
('PC-C107-16', 1, 1, 1),
('PC-C107-17', 1, 1, 1),
('PC-C107-18', 1, 1, 1),
('PC-C107-19', 1, 1, 1),
('PC-C107-20', 1, 1, 1),
('PC-C107-21', 1, 1, 1),
('PC-C107-22', 1, 1, 1),
('PC-C107-23', 1, 1, 1),
('PC-C107-24', 1, 1, 1),
('PC-C107-25', 1, 1, 1),
('PC-C107-26', 1, 1, 1),
('PC-C107-27', 1, 1, 1),
('PC-C107-28', 1, 1, 1),
('PC-C107-29', 1, 1, 1),
('PC-C107-30', 1, 1, 1),
('PC-C107-31', 1, 1, 1),
('PC-C107-32', 1, 1, 1),
('PROY-C107',  2, 1, 1);

-- SALON C-108 (idSalon = 2) — 32 PCs + 1 Proyector
INSERT INTO Mantenimiento.Dispositivo (codigoDispositivo, idTipoDispositivo, idSalon, idEstado)
VALUES
('PC-C108-01', 1, 2, 1),
('PC-C108-02', 1, 2, 1),
('PC-C108-03', 1, 2, 1),
('PC-C108-04', 1, 2, 1),
('PC-C108-05', 1, 2, 1),
('PC-C108-06', 1, 2, 1),
('PC-C108-07', 1, 2, 1),
('PC-C108-08', 1, 2, 1),
('PC-C108-09', 1, 2, 1),
('PC-C108-10', 1, 2, 1),
('PC-C108-11', 1, 2, 1),
('PC-C108-12', 1, 2, 1),
('PC-C108-13', 1, 2, 1),
('PC-C108-14', 1, 2, 1),
('PC-C108-15', 1, 2, 1),
('PC-C108-16', 1, 2, 1),
('PC-C108-17', 1, 2, 1),
('PC-C108-18', 1, 2, 1),
('PC-C108-19', 1, 2, 1),
('PC-C108-20', 1, 2, 1),
('PC-C108-21', 1, 2, 1),
('PC-C108-22', 1, 2, 1),
('PC-C108-23', 1, 2, 1),
('PC-C108-24', 1, 2, 1),
('PC-C108-25', 1, 2, 1),
('PC-C108-26', 1, 2, 1),
('PC-C108-27', 1, 2, 1),
('PC-C108-28', 1, 2, 1),
('PC-C108-29', 1, 2, 1),
('PC-C108-30', 1, 2, 1),
('PC-C108-31', 1, 2, 1),
('PC-C108-32', 1, 2, 1),
('PROY-C108',  2, 2, 1);

