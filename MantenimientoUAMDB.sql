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

-- SALON C-201 (idSalon = 3) — 24 PCs + 1 Proyector
INSERT INTO Mantenimiento.Dispositivo (codigoDispositivo, idTipoDispositivo, idSalon, idEstado)
VALUES
('PC-C201-01', 1, 3, 1),
('PC-C201-02', 1, 3, 1),
('PC-C201-03', 1, 3, 1),
('PC-C201-04', 1, 3, 1),
('PC-C201-05', 1, 3, 1),
('PC-C201-06', 1, 3, 1),
('PC-C201-07', 1, 3, 1),
('PC-C201-08', 1, 3, 1),
('PC-C201-09', 1, 3, 1),
('PC-C201-10', 1, 3, 1),
('PC-C201-11', 1, 3, 1),
('PC-C201-12', 1, 3, 1),
('PC-C201-13', 1, 3, 1),
('PC-C201-14', 1, 3, 1),
('PC-C201-15', 1, 3, 1),
('PC-C201-16', 1, 3, 1),
('PC-C201-17', 1, 3, 1),
('PC-C201-18', 1, 3, 1),
('PC-C201-19', 1, 3, 1),
('PC-C201-20', 1, 3, 1),
('PC-C201-21', 1, 3, 1),
('PC-C201-22', 1, 3, 1),
('PC-C201-23', 1, 3, 1),
('PC-C201-24', 1, 3, 1),
('PROY-C201',  2, 3, 1);

-- SALON C-202 (idSalon = 4) — 24 PCs + 1 Proyector
INSERT INTO Mantenimiento.Dispositivo (codigoDispositivo, idTipoDispositivo, idSalon, idEstado)
VALUES
('PC-C202-01', 1, 4, 1),
('PC-C202-02', 1, 4, 1),
('PC-C202-03', 1, 4, 1),
('PC-C202-04', 1, 4, 1),
('PC-C202-05', 1, 4, 1),
('PC-C202-06', 1, 4, 1),
('PC-C202-07', 1, 4, 1),
('PC-C202-08', 1, 4, 1),
('PC-C202-09', 1, 4, 1),
('PC-C202-10', 1, 4, 1),
('PC-C202-11', 1, 4, 1),
('PC-C202-12', 1, 4, 1),
('PC-C202-13', 1, 4, 1),
('PC-C202-14', 1, 4, 1),
('PC-C202-15', 1, 4, 1),
('PC-C202-16', 1, 4, 1),
('PC-C202-17', 1, 4, 1),
('PC-C202-18', 1, 4, 1),
('PC-C202-19', 1, 4, 1),
('PC-C202-20', 1, 4, 1),
('PC-C202-21', 1, 4, 1),
('PC-C202-22', 1, 4, 1),
('PC-C202-23', 1, 4, 1),
('PC-C202-24', 1, 4, 1),
('PROY-C202',  2, 4, 1);

-- SALON C-203 (idSalon = 5) — 32 PCs + 1 Proyector
INSERT INTO Mantenimiento.Dispositivo (codigoDispositivo, idTipoDispositivo, idSalon, idEstado)
VALUES
('PC-C203-01', 1, 5, 1),
('PC-C203-02', 1, 5, 1),
('PC-C203-03', 1, 5, 1),
('PC-C203-04', 1, 5, 1),
('PC-C203-05', 1, 5, 1),
('PC-C203-06', 1, 5, 1),
('PC-C203-07', 1, 5, 1),
('PC-C203-08', 1, 5, 1),
('PC-C203-09', 1, 5, 1),
('PC-C203-10', 1, 5, 1),
('PC-C203-11', 1, 5, 1),
('PC-C203-12', 1, 5, 1),
('PC-C203-13', 1, 5, 1),
('PC-C203-14', 1, 5, 1),
('PC-C203-15', 1, 5, 1),
('PC-C203-16', 1, 5, 1),
('PC-C203-17', 1, 5, 1),
('PC-C203-18', 1, 5, 1),
('PC-C203-19', 1, 5, 1),
('PC-C203-20', 1, 5, 1),
('PC-C203-21', 1, 5, 1),
('PC-C203-22', 1, 5, 1),
('PC-C203-23', 1, 5, 1),
('PC-C203-24', 1, 5, 1),
('PC-C203-25', 1, 5, 1),
('PC-C203-26', 1, 5, 1),
('PC-C203-27', 1, 5, 1),
('PC-C203-28', 1, 5, 1),
('PC-C203-29', 1, 5, 1),
('PC-C203-30', 1, 5, 1),
('PC-C203-31', 1, 5, 1),
('PC-C203-32', 1, 5, 1),
('PROY-C203',  2, 5, 1);

-- SALON C-204 (idSalon = 6) — 32 PCs + 1 Proyector
INSERT INTO Mantenimiento.Dispositivo (codigoDispositivo, idTipoDispositivo, idSalon, idEstado)
VALUES
('PC-C204-01', 1, 6, 1),
('PC-C204-02', 1, 6, 1),
('PC-C204-03', 1, 6, 1),
('PC-C204-04', 1, 6, 1),
('PC-C204-05', 1, 6, 1),
('PC-C204-06', 1, 6, 1),
('PC-C204-07', 1, 6, 1),
('PC-C204-08', 1, 6, 1),
('PC-C204-09', 1, 6, 1),
('PC-C204-10', 1, 6, 1),
('PC-C204-11', 1, 6, 1),
('PC-C204-12', 1, 6, 1),
('PC-C204-13', 1, 6, 1),
('PC-C204-14', 1, 6, 1),
('PC-C204-15', 1, 6, 1),
('PC-C204-16', 1, 6, 1),
('PC-C204-17', 1, 6, 1),
('PC-C204-18', 1, 6, 1),
('PC-C204-19', 1, 6, 1),
('PC-C204-20', 1, 6, 1),
('PC-C204-21', 1, 6, 1),
('PC-C204-22', 1, 6, 1),
('PC-C204-23', 1, 6, 1),
('PC-C204-24', 1, 6, 1),
('PC-C204-25', 1, 6, 1),
('PC-C204-26', 1, 6, 1),
('PC-C204-27', 1, 6, 1),
('PC-C204-28', 1, 6, 1),
('PC-C204-29', 1, 6, 1),
('PC-C204-30', 1, 6, 1),
('PC-C204-31', 1, 6, 1),
('PC-C204-32', 1, 6, 1),
('PROY-C204',  2, 6, 1);

-- SALON C-205 (idSalon = 7) — 32 PCs + 1 Proyector
INSERT INTO Mantenimiento.Dispositivo (codigoDispositivo, idTipoDispositivo, idSalon, idEstado)
VALUES
('PC-C205-01', 1, 7, 1),
('PC-C205-02', 1, 7, 1),
('PC-C205-03', 1, 7, 1),
('PC-C205-04', 1, 7, 1),
('PC-C205-05', 1, 7, 1),
('PC-C205-06', 1, 7, 1),
('PC-C205-07', 1, 7, 1),
('PC-C205-08', 1, 7, 1),
('PC-C205-09', 1, 7, 1),
('PC-C205-10', 1, 7, 1),
('PC-C205-11', 1, 7, 1),
('PC-C205-12', 1, 7, 1),
('PC-C205-13', 1, 7, 1),
('PC-C205-14', 1, 7, 1),
('PC-C205-15', 1, 7, 1),
('PC-C205-16', 1, 7, 1),
('PC-C205-17', 1, 7, 1),
('PC-C205-18', 1, 7, 1),
('PC-C205-19', 1, 7, 1),
('PC-C205-20', 1, 7, 1),
('PC-C205-21', 1, 7, 1),
('PC-C205-22', 1, 7, 1),
('PC-C205-23', 1, 7, 1),
('PC-C205-24', 1, 7, 1),
('PC-C205-25', 1, 7, 1),
('PC-C205-26', 1, 7, 1),
('PC-C205-27', 1, 7, 1),
('PC-C205-28', 1, 7, 1),
('PC-C205-29', 1, 7, 1),
('PC-C205-30', 1, 7, 1),
('PC-C205-31', 1, 7, 1),
('PC-C205-32', 1, 7, 1),
('PROY-C205',  2, 7, 1);

-- SALON C-206 (idSalon = 8) — 32 PCs + 1 Proyector
INSERT INTO Mantenimiento.Dispositivo (codigoDispositivo, idTipoDispositivo, idSalon, idEstado)
VALUES
('PC-C206-01', 1, 8, 1),
('PC-C206-02', 1, 8, 1),
('PC-C206-03', 1, 8, 1),
('PC-C206-04', 1, 8, 1),
('PC-C206-05', 1, 8, 1),
('PC-C206-06', 1, 8, 1),
('PC-C206-07', 1, 8, 1),
('PC-C206-08', 1, 8, 1),
('PC-C206-09', 1, 8, 1),
('PC-C206-10', 1, 8, 1),
('PC-C206-11', 1, 8, 1),
('PC-C206-12', 1, 8, 1),
('PC-C206-13', 1, 8, 1),
('PC-C206-14', 1, 8, 1),
('PC-C206-15', 1, 8, 1),
('PC-C206-16', 1, 8, 1),
('PC-C206-17', 1, 8, 1),
('PC-C206-18', 1, 8, 1),
('PC-C206-19', 1, 8, 1),
('PC-C206-20', 1, 8, 1),
('PC-C206-21', 1, 8, 1),
('PC-C206-22', 1, 8, 1),
('PC-C206-23', 1, 8, 1),
('PC-C206-24', 1, 8, 1),
('PC-C206-25', 1, 8, 1),
('PC-C206-26', 1, 8, 1),
('PC-C206-27', 1, 8, 1),
('PC-C206-28', 1, 8, 1),
('PC-C206-29', 1, 8, 1),
('PC-C206-30', 1, 8, 1),
('PC-C206-31', 1, 8, 1),
('PC-C206-32', 1, 8, 1),
('PROY-C206',  2, 8, 1);

-- SALON C-207 (idSalon = 9) — 32 PCs + 1 Proyector
INSERT INTO Mantenimiento.Dispositivo (codigoDispositivo, idTipoDispositivo, idSalon, idEstado)
VALUES
('PC-C207-01', 1, 9, 1),
('PC-C207-02', 1, 9, 1),
('PC-C207-03', 1, 9, 1),
('PC-C207-04', 1, 9, 1),
('PC-C207-05', 1, 9, 1),
('PC-C207-06', 1, 9, 1),
('PC-C207-07', 1, 9, 1),
('PC-C207-08', 1, 9, 1),
('PC-C207-09', 1, 9, 1),
('PC-C207-10', 1, 9, 1),
('PC-C207-11', 1, 9, 1),
('PC-C207-12', 1, 9, 1),
('PC-C207-13', 1, 9, 1),
('PC-C207-14', 1, 9, 1),
('PC-C207-15', 1, 9, 1),
('PC-C207-16', 1, 9, 1),
('PC-C207-17', 1, 9, 1),
('PC-C207-18', 1, 9, 1),
('PC-C207-19', 1, 9, 1),
('PC-C207-20', 1, 9, 1),
('PC-C207-21', 1, 9, 1),
('PC-C207-22', 1, 9, 1),
('PC-C207-23', 1, 9, 1),
('PC-C207-24', 1, 9, 1),
('PC-C207-25', 1, 9, 1),
('PC-C207-26', 1, 9, 1),
('PC-C207-27', 1, 9, 1),
('PC-C207-28', 1, 9, 1),
('PC-C207-29', 1, 9, 1),
('PC-C207-30', 1, 9, 1),
('PC-C207-31', 1, 9, 1),
('PC-C207-32', 1, 9, 1),
('PROY-C207',  2, 9, 1);

-- SALON C-208 (idSalon = 10) — 32 PCs + 1 Proyector
INSERT INTO Mantenimiento.Dispositivo (codigoDispositivo, idTipoDispositivo, idSalon, idEstado)
VALUES
('PC-C208-01', 1, 10, 1),
('PC-C208-02', 1, 10, 1),
('PC-C208-03', 1, 10, 1),
('PC-C208-04', 1, 10, 1),
('PC-C208-05', 1, 10, 1),
('PC-C208-06', 1, 10, 1),
('PC-C208-07', 1, 10, 1),
('PC-C208-08', 1, 10, 1),
('PC-C208-09', 1, 10, 1),
('PC-C208-10', 1, 10, 1),
('PC-C208-11', 1, 10, 1),
('PC-C208-12', 1, 10, 1),
('PC-C208-13', 1, 10, 1),
('PC-C208-14', 1, 10, 1),
('PC-C208-15', 1, 10, 1),
('PC-C208-16', 1, 10, 1),
('PC-C208-17', 1, 10, 1),
('PC-C208-18', 1, 10, 1),
('PC-C208-19', 1, 10, 1),
('PC-C208-20', 1, 10, 1),
('PC-C208-21', 1, 10, 1),
('PC-C208-22', 1, 10, 1),
('PC-C208-23', 1, 10, 1),
('PC-C208-24', 1, 10, 1),
('PC-C208-25', 1, 10, 1),
('PC-C208-26', 1, 10, 1),
('PC-C208-27', 1, 10, 1),
('PC-C208-28', 1, 10, 1),
('PC-C208-29', 1, 10, 1),
('PC-C208-30', 1, 10, 1),
('PC-C208-31', 1, 10, 1),
('PC-C208-32', 1, 10, 1),
('PROY-C208',  2, 10, 1);

-- SALON C-209 (idSalon = 11) — 32 PCs + 1 Proyector
INSERT INTO Mantenimiento.Dispositivo (codigoDispositivo, idTipoDispositivo, idSalon, idEstado)
VALUES
('PC-C209-01', 1, 11, 1),
('PC-C209-02', 1, 11, 1),
('PC-C209-03', 1, 11, 1),
('PC-C209-04', 1, 11, 1),
('PC-C209-05', 1, 11, 1),
('PC-C209-06', 1, 11, 1),
('PC-C209-07', 1, 11, 1),
('PC-C209-08', 1, 11, 1),
('PC-C209-09', 1, 11, 1),
('PC-C209-10', 1, 11, 1),
('PC-C209-11', 1, 11, 1),
('PC-C209-12', 1, 11, 1),
('PC-C209-13', 1, 11, 1),
('PC-C209-14', 1, 11, 1),
('PC-C209-15', 1, 11, 1),
('PC-C209-16', 1, 11, 1),
('PC-C209-17', 1, 11, 1),
('PC-C209-18', 1, 11, 1),
('PC-C209-19', 1, 11, 1),
('PC-C209-20', 1, 11, 1),
('PC-C209-21', 1, 11, 1),
('PC-C209-22', 1, 11, 1),
('PC-C209-23', 1, 11, 1),
('PC-C209-24', 1, 11, 1),
('PC-C209-25', 1, 11, 1),
('PC-C209-26', 1, 11, 1),
('PC-C209-27', 1, 11, 1),
('PC-C209-28', 1, 11, 1),
('PC-C209-29', 1, 11, 1),
('PC-C209-30', 1, 11, 1),
('PC-C209-31', 1, 11, 1),
('PC-C209-32', 1, 11, 1),
('PROY-C209',  2, 11, 1);

-- SALON O-201 (idSalon = 12) — 32 PCs + 1 Proyector
INSERT INTO Mantenimiento.Dispositivo (codigoDispositivo, idTipoDispositivo, idSalon, idEstado)
VALUES
('PC-O201-01', 1, 12, 1),
('PC-O201-02', 1, 12, 1),
('PC-O201-03', 1, 12, 1),
('PC-O201-04', 1, 12, 1),
('PC-O201-05', 1, 12, 1),
('PC-O201-06', 1, 12, 1),
('PC-O201-07', 1, 12, 1),
('PC-O201-08', 1, 12, 1),
('PC-O201-09', 1, 12, 1),
('PC-O201-10', 1, 12, 1),
('PC-O201-11', 1, 12, 1),
('PC-O201-12', 1, 12, 1),
('PC-O201-13', 1, 12, 1),
('PC-O201-14', 1, 12, 1),
('PC-O201-15', 1, 12, 1),
('PC-O201-16', 1, 12, 1),
('PC-O201-17', 1, 12, 1),
('PC-O201-18', 1, 12, 1),
('PC-O201-19', 1, 12, 1),
('PC-O201-20', 1, 12, 1),
('PC-O201-21', 1, 12, 1),
('PC-O201-22', 1, 12, 1),
('PC-O201-23', 1, 12, 1),
('PC-O201-24', 1, 12, 1),
('PC-O201-25', 1, 12, 1),
('PC-O201-26', 1, 12, 1),
('PC-O201-27', 1, 12, 1),
('PC-O201-28', 1, 12, 1),
('PC-O201-29', 1, 12, 1),
('PC-O201-30', 1, 12, 1),
('PC-O201-31', 1, 12, 1),
('PC-O201-32', 1, 12, 1),
('PROY-O201',  2, 12, 1);

-- Total: 380 dispositivos insertados
-- C-107: 33 | C-108: 33 | C-201: 25 | C-202: 25
-- C-203: 33 | C-204: 33 | C-205: 33 | C-206: 33
-- C-207: 33 | C-208: 33 | C-209: 33 | O-201: 33
--Estos son todos los dispositivos con los que cuentan las aulas UAM en el primer piso del edificio C

/* Restante, Tabla Creacion de los Dispostivos en Mantenimiento, es decir, tabla Mantenimiento */