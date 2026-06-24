/* Trabajo de Base de Datos, sobre el mantenimiento preventivo y correctivo
de los dispositivos de la uam */

USE master
GO

-- Por si esta base ya existe este comando la borra
-- Busca al igual el nombre y si lo encuentra lo borra
IF DB_ID('MantenimientosUAMDB') IS NOT NULL
BEGIN
    ALTER DATABASE MantenimientosUAMDB 
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    DROP DATABASE MantenimientosUAMDB;
END
GO

-- Creacion de la base de datos y use para acceder a este
CREATE DATABASE MantenimientosUAMDB;
GO

USE MantenimientosUAMDB;
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

-- Tabla Salon
INSERT INTO Mantenimiento.Salon (codigoSalon, piso, idEdificio)
VALUES
('C-107', 1, 1),
('C-108', 1, 1),
('C-201', 2, 1),
('C-202', 2, 1),
('C-203', 2, 1),
('C-204', 2, 1),
('C-205', 2, 1),
('C-206', 2, 1),
('C-207', 2, 1),
('C-208', 2, 1),
('C-209', 2, 1),
('O-201', 2, 2);
GO

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

/* ============================================================
   INSERT FALTANTE DE MANTENIMIENTO
   ============================================================ */

-- Tabla Mantenimiento: un registro para cada dispositivo ya registrado
-- Columnas según tu script: idDispositivo, idTipoMantenimiento, fechaMantenimiento, idTecnico, observacion
INSERT INTO Mantenimiento.Mantenimiento (idDispositivo, idTipoMantenimiento, fechaMantenimiento, idTecnico, observacion)
VALUES
(1, 1, '2026-04-23', 5, 'Mantenimiento preventivo según registro del PDF: equipo en revisión.'),
(3, 2, '2026-04-20', 3, 'Mantenimiento correctivo según registro del PDF: equipo en mantenimiento.'),
(4, 1, '2026-04-19', 12, 'Mantenimiento preventivo según registro del PDF: equipo en revisión.'),
(2, 1, '2026-04-07', 4, 'Mantenimiento preventivo realizado al equipo PC-C107-02: limpieza, revisión de conexiones y prueba general.'),
(5, 1, '2026-04-08', 7, 'Mantenimiento preventivo realizado al equipo PC-C107-05: limpieza, revisión de conexiones y prueba general.'),
(6, 1, '2026-04-09', 8, 'Mantenimiento preventivo realizado al equipo PC-C107-06: limpieza, revisión de conexiones y prueba general.'),
(7, 1, '2026-04-10', 9, 'Mantenimiento preventivo realizado al equipo PC-C107-07: limpieza, revisión de conexiones y prueba general.'),
(8, 1, '2026-04-11', 10, 'Mantenimiento preventivo realizado al equipo PC-C107-08: limpieza, revisión de conexiones y prueba general.'),
(9, 1, '2026-04-12', 11, 'Mantenimiento preventivo realizado al equipo PC-C107-09: limpieza, revisión de conexiones y prueba general.'),
(10, 1, '2026-04-13', 12, 'Mantenimiento preventivo realizado al equipo PC-C107-10: limpieza, revisión de conexiones y prueba general.'),
(11, 1, '2026-04-14', 13, 'Mantenimiento preventivo realizado al equipo PC-C107-11: limpieza, revisión de conexiones y prueba general.'),
(12, 1, '2026-04-15', 14, 'Mantenimiento preventivo realizado al equipo PC-C107-12: limpieza, revisión de conexiones y prueba general.'),
(13, 1, '2026-04-16', 15, 'Mantenimiento preventivo realizado al equipo PC-C107-13: limpieza, revisión de conexiones y prueba general.'),
(14, 1, '2026-04-17', 16, 'Mantenimiento preventivo realizado al equipo PC-C107-14: limpieza, revisión de conexiones y prueba general.'),
(15, 1, '2026-04-18', 1, 'Mantenimiento preventivo realizado al equipo PC-C107-15: limpieza, revisión de conexiones y prueba general.'),
(16, 1, '2026-04-19', 2, 'Mantenimiento preventivo realizado al equipo PC-C107-16: limpieza, revisión de conexiones y prueba general.'),
(17, 1, '2026-04-20', 3, 'Mantenimiento preventivo realizado al equipo PC-C107-17: limpieza, revisión de conexiones y prueba general.'),
(18, 1, '2026-04-21', 4, 'Mantenimiento preventivo realizado al equipo PC-C107-18: limpieza, revisión de conexiones y prueba general.'),
(19, 1, '2026-04-22', 5, 'Mantenimiento preventivo realizado al equipo PC-C107-19: limpieza, revisión de conexiones y prueba general.'),
(20, 1, '2026-04-23', 6, 'Mantenimiento preventivo realizado al equipo PC-C107-20: limpieza, revisión de conexiones y prueba general.'),
(21, 1, '2026-04-24', 7, 'Mantenimiento preventivo realizado al equipo PC-C107-21: limpieza, revisión de conexiones y prueba general.'),
(22, 1, '2026-04-25', 8, 'Mantenimiento preventivo realizado al equipo PC-C107-22: limpieza, revisión de conexiones y prueba general.'),
(23, 1, '2026-04-26', 9, 'Mantenimiento preventivo realizado al equipo PC-C107-23: limpieza, revisión de conexiones y prueba general.'),
(24, 1, '2026-04-27', 10, 'Mantenimiento preventivo realizado al equipo PC-C107-24: limpieza, revisión de conexiones y prueba general.'),
(25, 1, '2026-04-28', 11, 'Mantenimiento preventivo realizado al equipo PC-C107-25: limpieza, revisión de conexiones y prueba general.'),
(26, 1, '2026-04-29', 12, 'Mantenimiento preventivo realizado al equipo PC-C107-26: limpieza, revisión de conexiones y prueba general.'),
(27, 1, '2026-04-30', 13, 'Mantenimiento preventivo realizado al equipo PC-C107-27: limpieza, revisión de conexiones y prueba general.'),
(28, 1, '2026-05-01', 14, 'Mantenimiento preventivo realizado al equipo PC-C107-28: limpieza, revisión de conexiones y prueba general.'),
(29, 1, '2026-05-02', 15, 'Mantenimiento preventivo realizado al equipo PC-C107-29: limpieza, revisión de conexiones y prueba general.'),
(30, 1, '2026-05-03', 16, 'Mantenimiento preventivo realizado al equipo PC-C107-30: limpieza, revisión de conexiones y prueba general.'),
(31, 1, '2026-05-04', 1, 'Mantenimiento preventivo realizado al equipo PC-C107-31: limpieza, revisión de conexiones y prueba general.'),
(32, 1, '2026-05-05', 2, 'Mantenimiento preventivo realizado al equipo PC-C107-32: limpieza, revisión de conexiones y prueba general.'),
(33, 1, '2026-05-06', 3, 'Mantenimiento preventivo realizado al equipo PROY-C107: limpieza, revisión de conexiones y prueba general.'),
(34, 1, '2026-05-09', 5, 'Mantenimiento preventivo realizado al equipo PC-C108-01: limpieza, revisión de conexiones y prueba general.'),
(35, 1, '2026-05-10', 6, 'Mantenimiento preventivo realizado al equipo PC-C108-02: limpieza, revisión de conexiones y prueba general.'),
(36, 1, '2026-05-11', 7, 'Mantenimiento preventivo realizado al equipo PC-C108-03: limpieza, revisión de conexiones y prueba general.'),
(37, 2, '2026-05-12', 8, 'Mantenimiento correctivo realizado al equipo PC-C108-04: revisión y corrección de falla reportada.'),
(38, 1, '2026-05-13', 9, 'Mantenimiento preventivo realizado al equipo PC-C108-05: limpieza, revisión de conexiones y prueba general.'),
(39, 1, '2026-05-14', 10, 'Mantenimiento preventivo realizado al equipo PC-C108-06: limpieza, revisión de conexiones y prueba general.'),
(40, 1, '2026-05-15', 11, 'Mantenimiento preventivo realizado al equipo PC-C108-07: limpieza, revisión de conexiones y prueba general.'),
(41, 1, '2026-05-16', 12, 'Mantenimiento preventivo realizado al equipo PC-C108-08: limpieza, revisión de conexiones y prueba general.'),
(42, 1, '2026-05-17', 13, 'Mantenimiento preventivo realizado al equipo PC-C108-09: limpieza, revisión de conexiones y prueba general.'),
(43, 1, '2026-05-18', 14, 'Mantenimiento preventivo realizado al equipo PC-C108-10: limpieza, revisión de conexiones y prueba general.'),
(44, 1, '2026-05-19', 15, 'Mantenimiento preventivo realizado al equipo PC-C108-11: limpieza, revisión de conexiones y prueba general.'),
(45, 1, '2026-05-20', 16, 'Mantenimiento preventivo realizado al equipo PC-C108-12: limpieza, revisión de conexiones y prueba general.'),
(46, 1, '2026-05-21', 1, 'Mantenimiento preventivo realizado al equipo PC-C108-13: limpieza, revisión de conexiones y prueba general.'),
(47, 1, '2026-05-22', 2, 'Mantenimiento preventivo realizado al equipo PC-C108-14: limpieza, revisión de conexiones y prueba general.'),
(48, 1, '2026-05-23', 3, 'Mantenimiento preventivo realizado al equipo PC-C108-15: limpieza, revisión de conexiones y prueba general.'),
(49, 1, '2026-05-24', 4, 'Mantenimiento preventivo realizado al equipo PC-C108-16: limpieza, revisión de conexiones y prueba general.'),
(50, 1, '2026-05-25', 5, 'Mantenimiento preventivo realizado al equipo PC-C108-17: limpieza, revisión de conexiones y prueba general.'),
(51, 1, '2026-05-26', 6, 'Mantenimiento preventivo realizado al equipo PC-C108-18: limpieza, revisión de conexiones y prueba general.'),
(52, 1, '2026-05-27', 7, 'Mantenimiento preventivo realizado al equipo PC-C108-19: limpieza, revisión de conexiones y prueba general.'),
(53, 1, '2026-05-28', 8, 'Mantenimiento preventivo realizado al equipo PC-C108-20: limpieza, revisión de conexiones y prueba general.'),
(54, 1, '2026-05-29', 9, 'Mantenimiento preventivo realizado al equipo PC-C108-21: limpieza, revisión de conexiones y prueba general.'),
(55, 1, '2026-05-30', 10, 'Mantenimiento preventivo realizado al equipo PC-C108-22: limpieza, revisión de conexiones y prueba general.'),
(56, 1, '2026-05-31', 11, 'Mantenimiento preventivo realizado al equipo PC-C108-23: limpieza, revisión de conexiones y prueba general.'),
(57, 1, '2026-04-01', 12, 'Mantenimiento preventivo realizado al equipo PC-C108-24: limpieza, revisión de conexiones y prueba general.'),
(58, 1, '2026-04-02', 13, 'Mantenimiento preventivo realizado al equipo PC-C108-25: limpieza, revisión de conexiones y prueba general.'),
(59, 1, '2026-04-03', 14, 'Mantenimiento preventivo realizado al equipo PC-C108-26: limpieza, revisión de conexiones y prueba general.'),
(60, 1, '2026-04-04', 15, 'Mantenimiento preventivo realizado al equipo PC-C108-27: limpieza, revisión de conexiones y prueba general.'),
(61, 1, '2026-04-05', 16, 'Mantenimiento preventivo realizado al equipo PC-C108-28: limpieza, revisión de conexiones y prueba general.'),
(62, 1, '2026-04-06', 1, 'Mantenimiento preventivo realizado al equipo PC-C108-29: limpieza, revisión de conexiones y prueba general.'),
(63, 1, '2026-04-07', 2, 'Mantenimiento preventivo realizado al equipo PC-C108-30: limpieza, revisión de conexiones y prueba general.'),
(64, 1, '2026-04-08', 3, 'Mantenimiento preventivo realizado al equipo PC-C108-31: limpieza, revisión de conexiones y prueba general.'),
(65, 1, '2026-04-09', 4, 'Mantenimiento preventivo realizado al equipo PC-C108-32: limpieza, revisión de conexiones y prueba general.'),
(66, 1, '2026-04-10', 5, 'Mantenimiento preventivo realizado al equipo PROY-C108: limpieza, revisión de conexiones y prueba general.'),
(67, 1, '2026-04-13', 7, 'Mantenimiento preventivo realizado al equipo PC-C201-01: limpieza, revisión de conexiones y prueba general.'),
(68, 1, '2026-04-14', 8, 'Mantenimiento preventivo realizado al equipo PC-C201-02: limpieza, revisión de conexiones y prueba general.'),
(69, 1, '2026-04-15', 9, 'Mantenimiento preventivo realizado al equipo PC-C201-03: limpieza, revisión de conexiones y prueba general.'),
(70, 1, '2026-04-16', 10, 'Mantenimiento preventivo realizado al equipo PC-C201-04: limpieza, revisión de conexiones y prueba general.'),
(71, 1, '2026-04-17', 11, 'Mantenimiento preventivo realizado al equipo PC-C201-05: limpieza, revisión de conexiones y prueba general.'),
(72, 1, '2026-04-18', 12, 'Mantenimiento preventivo realizado al equipo PC-C201-06: limpieza, revisión de conexiones y prueba general.'),
(73, 1, '2026-04-19', 13, 'Mantenimiento preventivo realizado al equipo PC-C201-07: limpieza, revisión de conexiones y prueba general.'),
(74, 2, '2026-04-20', 14, 'Mantenimiento correctivo realizado al equipo PC-C201-08: revisión y corrección de falla reportada.'),
(75, 1, '2026-04-21', 15, 'Mantenimiento preventivo realizado al equipo PC-C201-09: limpieza, revisión de conexiones y prueba general.'),
(76, 1, '2026-04-22', 16, 'Mantenimiento preventivo realizado al equipo PC-C201-10: limpieza, revisión de conexiones y prueba general.'),
(77, 1, '2026-04-23', 1, 'Mantenimiento preventivo realizado al equipo PC-C201-11: limpieza, revisión de conexiones y prueba general.'),
(78, 1, '2026-04-24', 2, 'Mantenimiento preventivo realizado al equipo PC-C201-12: limpieza, revisión de conexiones y prueba general.'),
(79, 1, '2026-04-25', 3, 'Mantenimiento preventivo realizado al equipo PC-C201-13: limpieza, revisión de conexiones y prueba general.'),
(80, 1, '2026-04-26', 4, 'Mantenimiento preventivo realizado al equipo PC-C201-14: limpieza, revisión de conexiones y prueba general.'),
(81, 1, '2026-04-27', 5, 'Mantenimiento preventivo realizado al equipo PC-C201-15: limpieza, revisión de conexiones y prueba general.'),
(82, 1, '2026-04-28', 6, 'Mantenimiento preventivo realizado al equipo PC-C201-16: limpieza, revisión de conexiones y prueba general.'),
(83, 1, '2026-04-29', 7, 'Mantenimiento preventivo realizado al equipo PC-C201-17: limpieza, revisión de conexiones y prueba general.'),
(84, 1, '2026-04-30', 8, 'Mantenimiento preventivo realizado al equipo PC-C201-18: limpieza, revisión de conexiones y prueba general.'),
(85, 1, '2026-05-01', 9, 'Mantenimiento preventivo realizado al equipo PC-C201-19: limpieza, revisión de conexiones y prueba general.'),
(86, 1, '2026-05-02', 10, 'Mantenimiento preventivo realizado al equipo PC-C201-20: limpieza, revisión de conexiones y prueba general.'),
(87, 1, '2026-05-03', 11, 'Mantenimiento preventivo realizado al equipo PC-C201-21: limpieza, revisión de conexiones y prueba general.'),
(88, 1, '2026-05-04', 12, 'Mantenimiento preventivo realizado al equipo PC-C201-22: limpieza, revisión de conexiones y prueba general.'),
(89, 1, '2026-05-05', 13, 'Mantenimiento preventivo realizado al equipo PC-C201-23: limpieza, revisión de conexiones y prueba general.'),
(90, 1, '2026-05-06', 14, 'Mantenimiento preventivo realizado al equipo PC-C201-24: limpieza, revisión de conexiones y prueba general.'),
(91, 1, '2026-05-07', 15, 'Mantenimiento preventivo realizado al equipo PROY-C201: limpieza, revisión de conexiones y prueba general.'),
(92, 1, '2026-05-10', 1, 'Mantenimiento preventivo realizado al equipo PC-C202-01: limpieza, revisión de conexiones y prueba general.'),
(93, 1, '2026-05-11', 2, 'Mantenimiento preventivo realizado al equipo PC-C202-02: limpieza, revisión de conexiones y prueba general.'),
(94, 1, '2026-05-12', 3, 'Mantenimiento preventivo realizado al equipo PC-C202-03: limpieza, revisión de conexiones y prueba general.'),
(95, 1, '2026-05-13', 4, 'Mantenimiento preventivo realizado al equipo PC-C202-04: limpieza, revisión de conexiones y prueba general.'),
(96, 1, '2026-05-14', 5, 'Mantenimiento preventivo realizado al equipo PC-C202-05: limpieza, revisión de conexiones y prueba general.'),
(97, 1, '2026-05-15', 6, 'Mantenimiento preventivo realizado al equipo PC-C202-06: limpieza, revisión de conexiones y prueba general.'),
(98, 1, '2026-05-16', 7, 'Mantenimiento preventivo realizado al equipo PC-C202-07: limpieza, revisión de conexiones y prueba general.'),
(99, 1, '2026-05-17', 8, 'Mantenimiento preventivo realizado al equipo PC-C202-08: limpieza, revisión de conexiones y prueba general.'),
(100, 1, '2026-05-18', 9, 'Mantenimiento preventivo realizado al equipo PC-C202-09: limpieza, revisión de conexiones y prueba general.'),
(101, 1, '2026-05-19', 10, 'Mantenimiento preventivo realizado al equipo PC-C202-10: limpieza, revisión de conexiones y prueba general.'),
(102, 1, '2026-05-20', 11, 'Mantenimiento preventivo realizado al equipo PC-C202-11: limpieza, revisión de conexiones y prueba general.'),
(103, 1, '2026-05-21', 12, 'Mantenimiento preventivo realizado al equipo PC-C202-12: limpieza, revisión de conexiones y prueba general.'),
(104, 1, '2026-05-22', 13, 'Mantenimiento preventivo realizado al equipo PC-C202-13: limpieza, revisión de conexiones y prueba general.'),
(105, 1, '2026-05-23', 14, 'Mantenimiento preventivo realizado al equipo PC-C202-14: limpieza, revisión de conexiones y prueba general.'),
(106, 1, '2026-05-24', 15, 'Mantenimiento preventivo realizado al equipo PC-C202-15: limpieza, revisión de conexiones y prueba general.'),
(107, 1, '2026-05-25', 16, 'Mantenimiento preventivo realizado al equipo PC-C202-16: limpieza, revisión de conexiones y prueba general.'),
(108, 1, '2026-05-26', 1, 'Mantenimiento preventivo realizado al equipo PC-C202-17: limpieza, revisión de conexiones y prueba general.'),
(109, 1, '2026-05-27', 2, 'Mantenimiento preventivo realizado al equipo PC-C202-18: limpieza, revisión de conexiones y prueba general.'),
(110, 1, '2026-05-28', 3, 'Mantenimiento preventivo realizado al equipo PC-C202-19: limpieza, revisión de conexiones y prueba general.'),
(111, 2, '2026-05-29', 4, 'Mantenimiento correctivo realizado al equipo PC-C202-20: revisión y corrección de falla reportada.'),
(112, 1, '2026-05-30', 5, 'Mantenimiento preventivo realizado al equipo PC-C202-21: limpieza, revisión de conexiones y prueba general.'),
(113, 1, '2026-05-31', 6, 'Mantenimiento preventivo realizado al equipo PC-C202-22: limpieza, revisión de conexiones y prueba general.'),
(114, 1, '2026-04-01', 7, 'Mantenimiento preventivo realizado al equipo PC-C202-23: limpieza, revisión de conexiones y prueba general.'),
(115, 1, '2026-04-02', 8, 'Mantenimiento preventivo realizado al equipo PC-C202-24: limpieza, revisión de conexiones y prueba general.'),
(116, 1, '2026-04-03', 9, 'Mantenimiento preventivo realizado al equipo PROY-C202: limpieza, revisión de conexiones y prueba general.'),
(117, 1, '2026-04-06', 11, 'Mantenimiento preventivo realizado al equipo PC-C203-01: limpieza, revisión de conexiones y prueba general.'),
(118, 1, '2026-04-07', 12, 'Mantenimiento preventivo realizado al equipo PC-C203-02: limpieza, revisión de conexiones y prueba general.'),
(119, 1, '2026-04-08', 13, 'Mantenimiento preventivo realizado al equipo PC-C203-03: limpieza, revisión de conexiones y prueba general.'),
(120, 1, '2026-04-09', 14, 'Mantenimiento preventivo realizado al equipo PC-C203-04: limpieza, revisión de conexiones y prueba general.'),
(121, 1, '2026-04-10', 15, 'Mantenimiento preventivo realizado al equipo PC-C203-05: limpieza, revisión de conexiones y prueba general.'),
(122, 1, '2026-04-11', 16, 'Mantenimiento preventivo realizado al equipo PC-C203-06: limpieza, revisión de conexiones y prueba general.'),
(123, 1, '2026-04-12', 1, 'Mantenimiento preventivo realizado al equipo PC-C203-07: limpieza, revisión de conexiones y prueba general.'),
(124, 1, '2026-04-13', 2, 'Mantenimiento preventivo realizado al equipo PC-C203-08: limpieza, revisión de conexiones y prueba general.'),
(125, 1, '2026-04-14', 3, 'Mantenimiento preventivo realizado al equipo PC-C203-09: limpieza, revisión de conexiones y prueba general.'),
(126, 1, '2026-04-15', 4, 'Mantenimiento preventivo realizado al equipo PC-C203-10: limpieza, revisión de conexiones y prueba general.'),
(127, 1, '2026-04-16', 5, 'Mantenimiento preventivo realizado al equipo PC-C203-11: limpieza, revisión de conexiones y prueba general.'),
(128, 1, '2026-04-17', 6, 'Mantenimiento preventivo realizado al equipo PC-C203-12: limpieza, revisión de conexiones y prueba general.'),
(129, 1, '2026-04-18', 7, 'Mantenimiento preventivo realizado al equipo PC-C203-13: limpieza, revisión de conexiones y prueba general.'),
(130, 1, '2026-04-19', 8, 'Mantenimiento preventivo realizado al equipo PC-C203-14: limpieza, revisión de conexiones y prueba general.'),
(131, 1, '2026-04-20', 9, 'Mantenimiento preventivo realizado al equipo PC-C203-15: limpieza, revisión de conexiones y prueba general.'),
(132, 1, '2026-04-21', 10, 'Mantenimiento preventivo realizado al equipo PC-C203-16: limpieza, revisión de conexiones y prueba general.'),
(133, 1, '2026-04-22', 11, 'Mantenimiento preventivo realizado al equipo PC-C203-17: limpieza, revisión de conexiones y prueba general.'),
(134, 1, '2026-04-23', 12, 'Mantenimiento preventivo realizado al equipo PC-C203-18: limpieza, revisión de conexiones y prueba general.'),
(135, 1, '2026-04-24', 13, 'Mantenimiento preventivo realizado al equipo PC-C203-19: limpieza, revisión de conexiones y prueba general.'),
(136, 1, '2026-04-25', 14, 'Mantenimiento preventivo realizado al equipo PC-C203-20: limpieza, revisión de conexiones y prueba general.'),
(137, 1, '2026-04-26', 15, 'Mantenimiento preventivo realizado al equipo PC-C203-21: limpieza, revisión de conexiones y prueba general.'),
(138, 1, '2026-04-27', 16, 'Mantenimiento preventivo realizado al equipo PC-C203-22: limpieza, revisión de conexiones y prueba general.'),
(139, 1, '2026-04-28', 1, 'Mantenimiento preventivo realizado al equipo PC-C203-23: limpieza, revisión de conexiones y prueba general.'),
(140, 1, '2026-04-29', 2, 'Mantenimiento preventivo realizado al equipo PC-C203-24: limpieza, revisión de conexiones y prueba general.'),
(141, 1, '2026-04-30', 3, 'Mantenimiento preventivo realizado al equipo PC-C203-25: limpieza, revisión de conexiones y prueba general.'),
(142, 1, '2026-05-01', 4, 'Mantenimiento preventivo realizado al equipo PC-C203-26: limpieza, revisión de conexiones y prueba general.'),
(143, 1, '2026-05-02', 5, 'Mantenimiento preventivo realizado al equipo PC-C203-27: limpieza, revisión de conexiones y prueba general.'),
(144, 1, '2026-05-03', 6, 'Mantenimiento preventivo realizado al equipo PC-C203-28: limpieza, revisión de conexiones y prueba general.'),
(145, 1, '2026-05-04', 7, 'Mantenimiento preventivo realizado al equipo PC-C203-29: limpieza, revisión de conexiones y prueba general.'),
(146, 1, '2026-05-05', 8, 'Mantenimiento preventivo realizado al equipo PC-C203-30: limpieza, revisión de conexiones y prueba general.'),
(147, 1, '2026-05-06', 9, 'Mantenimiento preventivo realizado al equipo PC-C203-31: limpieza, revisión de conexiones y prueba general.'),
(148, 2, '2026-05-07', 10, 'Mantenimiento correctivo realizado al equipo PC-C203-32: revisión y corrección de falla reportada.'),
(149, 1, '2026-05-08', 11, 'Mantenimiento preventivo realizado al equipo PROY-C203: limpieza, revisión de conexiones y prueba general.'),
(150, 1, '2026-05-11', 13, 'Mantenimiento preventivo realizado al equipo PC-C204-01: limpieza, revisión de conexiones y prueba general.'),
(151, 1, '2026-05-12', 14, 'Mantenimiento preventivo realizado al equipo PC-C204-02: limpieza, revisión de conexiones y prueba general.'),
(152, 1, '2026-05-13', 15, 'Mantenimiento preventivo realizado al equipo PC-C204-03: limpieza, revisión de conexiones y prueba general.'),
(153, 1, '2026-05-14', 16, 'Mantenimiento preventivo realizado al equipo PC-C204-04: limpieza, revisión de conexiones y prueba general.'),
(154, 1, '2026-05-15', 1, 'Mantenimiento preventivo realizado al equipo PC-C204-05: limpieza, revisión de conexiones y prueba general.'),
(155, 1, '2026-05-16', 2, 'Mantenimiento preventivo realizado al equipo PC-C204-06: limpieza, revisión de conexiones y prueba general.'),
(156, 1, '2026-05-17', 3, 'Mantenimiento preventivo realizado al equipo PC-C204-07: limpieza, revisión de conexiones y prueba general.'),
(157, 1, '2026-05-18', 4, 'Mantenimiento preventivo realizado al equipo PC-C204-08: limpieza, revisión de conexiones y prueba general.'),
(158, 1, '2026-05-19', 5, 'Mantenimiento preventivo realizado al equipo PC-C204-09: limpieza, revisión de conexiones y prueba general.'),
(159, 1, '2026-05-20', 6, 'Mantenimiento preventivo realizado al equipo PC-C204-10: limpieza, revisión de conexiones y prueba general.'),
(160, 1, '2026-05-21', 7, 'Mantenimiento preventivo realizado al equipo PC-C204-11: limpieza, revisión de conexiones y prueba general.'),
(161, 1, '2026-05-22', 8, 'Mantenimiento preventivo realizado al equipo PC-C204-12: limpieza, revisión de conexiones y prueba general.'),
(162, 1, '2026-05-23', 9, 'Mantenimiento preventivo realizado al equipo PC-C204-13: limpieza, revisión de conexiones y prueba general.'),
(163, 1, '2026-05-24', 10, 'Mantenimiento preventivo realizado al equipo PC-C204-14: limpieza, revisión de conexiones y prueba general.'),
(164, 1, '2026-05-25', 11, 'Mantenimiento preventivo realizado al equipo PC-C204-15: limpieza, revisión de conexiones y prueba general.'),
(165, 1, '2026-05-26', 12, 'Mantenimiento preventivo realizado al equipo PC-C204-16: limpieza, revisión de conexiones y prueba general.'),
(166, 1, '2026-05-27', 13, 'Mantenimiento preventivo realizado al equipo PC-C204-17: limpieza, revisión de conexiones y prueba general.'),
(167, 1, '2026-05-28', 14, 'Mantenimiento preventivo realizado al equipo PC-C204-18: limpieza, revisión de conexiones y prueba general.'),
(168, 1, '2026-05-29', 15, 'Mantenimiento preventivo realizado al equipo PC-C204-19: limpieza, revisión de conexiones y prueba general.'),
(169, 1, '2026-05-30', 16, 'Mantenimiento preventivo realizado al equipo PC-C204-20: limpieza, revisión de conexiones y prueba general.'),
(170, 1, '2026-05-31', 1, 'Mantenimiento preventivo realizado al equipo PC-C204-21: limpieza, revisión de conexiones y prueba general.'),
(171, 1, '2026-04-01', 2, 'Mantenimiento preventivo realizado al equipo PC-C204-22: limpieza, revisión de conexiones y prueba general.'),
(172, 1, '2026-04-02', 3, 'Mantenimiento preventivo realizado al equipo PC-C204-23: limpieza, revisión de conexiones y prueba general.'),
(173, 1, '2026-04-03', 4, 'Mantenimiento preventivo realizado al equipo PC-C204-24: limpieza, revisión de conexiones y prueba general.'),
(174, 1, '2026-04-04', 5, 'Mantenimiento preventivo realizado al equipo PC-C204-25: limpieza, revisión de conexiones y prueba general.'),
(175, 1, '2026-04-05', 6, 'Mantenimiento preventivo realizado al equipo PC-C204-26: limpieza, revisión de conexiones y prueba general.'),
(176, 1, '2026-04-06', 7, 'Mantenimiento preventivo realizado al equipo PC-C204-27: limpieza, revisión de conexiones y prueba general.'),
(177, 1, '2026-04-07', 8, 'Mantenimiento preventivo realizado al equipo PC-C204-28: limpieza, revisión de conexiones y prueba general.'),
(178, 1, '2026-04-08', 9, 'Mantenimiento preventivo realizado al equipo PC-C204-29: limpieza, revisión de conexiones y prueba general.'),
(179, 1, '2026-04-09', 10, 'Mantenimiento preventivo realizado al equipo PC-C204-30: limpieza, revisión de conexiones y prueba general.'),
(180, 1, '2026-04-10', 11, 'Mantenimiento preventivo realizado al equipo PC-C204-31: limpieza, revisión de conexiones y prueba general.'),
(181, 1, '2026-04-11', 12, 'Mantenimiento preventivo realizado al equipo PC-C204-32: limpieza, revisión de conexiones y prueba general.'),
(182, 1, '2026-04-12', 13, 'Mantenimiento preventivo realizado al equipo PROY-C204: limpieza, revisión de conexiones y prueba general.'),
(183, 1, '2026-04-15', 15, 'Mantenimiento preventivo realizado al equipo PC-C205-01: limpieza, revisión de conexiones y prueba general.'),
(184, 1, '2026-04-16', 16, 'Mantenimiento preventivo realizado al equipo PC-C205-02: limpieza, revisión de conexiones y prueba general.'),
(185, 2, '2026-04-17', 1, 'Mantenimiento correctivo realizado al equipo PC-C205-03: revisión y corrección de falla reportada.'),
(186, 1, '2026-04-18', 2, 'Mantenimiento preventivo realizado al equipo PC-C205-04: limpieza, revisión de conexiones y prueba general.'),
(187, 1, '2026-04-19', 3, 'Mantenimiento preventivo realizado al equipo PC-C205-05: limpieza, revisión de conexiones y prueba general.'),
(188, 1, '2026-04-20', 4, 'Mantenimiento preventivo realizado al equipo PC-C205-06: limpieza, revisión de conexiones y prueba general.'),
(189, 1, '2026-04-21', 5, 'Mantenimiento preventivo realizado al equipo PC-C205-07: limpieza, revisión de conexiones y prueba general.'),
(190, 1, '2026-04-22', 6, 'Mantenimiento preventivo realizado al equipo PC-C205-08: limpieza, revisión de conexiones y prueba general.'),
(191, 1, '2026-04-23', 7, 'Mantenimiento preventivo realizado al equipo PC-C205-09: limpieza, revisión de conexiones y prueba general.'),
(192, 1, '2026-04-24', 8, 'Mantenimiento preventivo realizado al equipo PC-C205-10: limpieza, revisión de conexiones y prueba general.'),
(193, 1, '2026-04-25', 9, 'Mantenimiento preventivo realizado al equipo PC-C205-11: limpieza, revisión de conexiones y prueba general.'),
(194, 1, '2026-04-26', 10, 'Mantenimiento preventivo realizado al equipo PC-C205-12: limpieza, revisión de conexiones y prueba general.'),
(195, 1, '2026-04-27', 11, 'Mantenimiento preventivo realizado al equipo PC-C205-13: limpieza, revisión de conexiones y prueba general.'),
(196, 1, '2026-04-28', 12, 'Mantenimiento preventivo realizado al equipo PC-C205-14: limpieza, revisión de conexiones y prueba general.'),
(197, 1, '2026-04-29', 13, 'Mantenimiento preventivo realizado al equipo PC-C205-15: limpieza, revisión de conexiones y prueba general.'),
(198, 1, '2026-04-30', 14, 'Mantenimiento preventivo realizado al equipo PC-C205-16: limpieza, revisión de conexiones y prueba general.'),
(199, 1, '2026-05-01', 15, 'Mantenimiento preventivo realizado al equipo PC-C205-17: limpieza, revisión de conexiones y prueba general.'),
(200, 1, '2026-05-02', 16, 'Mantenimiento preventivo realizado al equipo PC-C205-18: limpieza, revisión de conexiones y prueba general.'),
(201, 1, '2026-05-03', 1, 'Mantenimiento preventivo realizado al equipo PC-C205-19: limpieza, revisión de conexiones y prueba general.'),
(202, 1, '2026-05-04', 2, 'Mantenimiento preventivo realizado al equipo PC-C205-20: limpieza, revisión de conexiones y prueba general.'),
(203, 1, '2026-05-05', 3, 'Mantenimiento preventivo realizado al equipo PC-C205-21: limpieza, revisión de conexiones y prueba general.'),
(204, 1, '2026-05-06', 4, 'Mantenimiento preventivo realizado al equipo PC-C205-22: limpieza, revisión de conexiones y prueba general.'),
(205, 1, '2026-05-07', 5, 'Mantenimiento preventivo realizado al equipo PC-C205-23: limpieza, revisión de conexiones y prueba general.'),
(206, 1, '2026-05-08', 6, 'Mantenimiento preventivo realizado al equipo PC-C205-24: limpieza, revisión de conexiones y prueba general.'),
(207, 1, '2026-05-09', 7, 'Mantenimiento preventivo realizado al equipo PC-C205-25: limpieza, revisión de conexiones y prueba general.'),
(208, 1, '2026-05-10', 8, 'Mantenimiento preventivo realizado al equipo PC-C205-26: limpieza, revisión de conexiones y prueba general.'),
(209, 1, '2026-05-11', 9, 'Mantenimiento preventivo realizado al equipo PC-C205-27: limpieza, revisión de conexiones y prueba general.'),
(210, 1, '2026-05-12', 10, 'Mantenimiento preventivo realizado al equipo PC-C205-28: limpieza, revisión de conexiones y prueba general.'),
(211, 1, '2026-05-13', 11, 'Mantenimiento preventivo realizado al equipo PC-C205-29: limpieza, revisión de conexiones y prueba general.'),
(212, 1, '2026-05-14', 12, 'Mantenimiento preventivo realizado al equipo PC-C205-30: limpieza, revisión de conexiones y prueba general.'),
(213, 1, '2026-05-15', 13, 'Mantenimiento preventivo realizado al equipo PC-C205-31: limpieza, revisión de conexiones y prueba general.'),
(214, 1, '2026-05-16', 14, 'Mantenimiento preventivo realizado al equipo PC-C205-32: limpieza, revisión de conexiones y prueba general.'),
(215, 1, '2026-05-17', 15, 'Mantenimiento preventivo realizado al equipo PROY-C205: limpieza, revisión de conexiones y prueba general.'),
(216, 1, '2026-05-20', 1, 'Mantenimiento preventivo realizado al equipo PC-C206-01: limpieza, revisión de conexiones y prueba general.'),
(217, 1, '2026-05-21', 2, 'Mantenimiento preventivo realizado al equipo PC-C206-02: limpieza, revisión de conexiones y prueba general.'),
(218, 1, '2026-05-22', 3, 'Mantenimiento preventivo realizado al equipo PC-C206-03: limpieza, revisión de conexiones y prueba general.'),
(219, 1, '2026-05-23', 4, 'Mantenimiento preventivo realizado al equipo PC-C206-04: limpieza, revisión de conexiones y prueba general.'),
(220, 1, '2026-05-24', 5, 'Mantenimiento preventivo realizado al equipo PC-C206-05: limpieza, revisión de conexiones y prueba general.'),
(221, 1, '2026-05-25', 6, 'Mantenimiento preventivo realizado al equipo PC-C206-06: limpieza, revisión de conexiones y prueba general.'),
(222, 2, '2026-05-26', 7, 'Mantenimiento correctivo realizado al equipo PC-C206-07: revisión y corrección de falla reportada.'),
(223, 1, '2026-05-27', 8, 'Mantenimiento preventivo realizado al equipo PC-C206-08: limpieza, revisión de conexiones y prueba general.'),
(224, 1, '2026-05-28', 9, 'Mantenimiento preventivo realizado al equipo PC-C206-09: limpieza, revisión de conexiones y prueba general.'),
(225, 1, '2026-05-29', 10, 'Mantenimiento preventivo realizado al equipo PC-C206-10: limpieza, revisión de conexiones y prueba general.'),
(226, 1, '2026-05-30', 11, 'Mantenimiento preventivo realizado al equipo PC-C206-11: limpieza, revisión de conexiones y prueba general.'),
(227, 1, '2026-05-31', 12, 'Mantenimiento preventivo realizado al equipo PC-C206-12: limpieza, revisión de conexiones y prueba general.'),
(228, 1, '2026-04-01', 13, 'Mantenimiento preventivo realizado al equipo PC-C206-13: limpieza, revisión de conexiones y prueba general.'),
(229, 1, '2026-04-02', 14, 'Mantenimiento preventivo realizado al equipo PC-C206-14: limpieza, revisión de conexiones y prueba general.'),
(230, 1, '2026-04-03', 15, 'Mantenimiento preventivo realizado al equipo PC-C206-15: limpieza, revisión de conexiones y prueba general.'),
(231, 1, '2026-04-04', 16, 'Mantenimiento preventivo realizado al equipo PC-C206-16: limpieza, revisión de conexiones y prueba general.'),
(232, 1, '2026-04-05', 1, 'Mantenimiento preventivo realizado al equipo PC-C206-17: limpieza, revisión de conexiones y prueba general.'),
(233, 1, '2026-04-06', 2, 'Mantenimiento preventivo realizado al equipo PC-C206-18: limpieza, revisión de conexiones y prueba general.'),
(234, 1, '2026-04-07', 3, 'Mantenimiento preventivo realizado al equipo PC-C206-19: limpieza, revisión de conexiones y prueba general.'),
(235, 1, '2026-04-08', 4, 'Mantenimiento preventivo realizado al equipo PC-C206-20: limpieza, revisión de conexiones y prueba general.'),
(236, 1, '2026-04-09', 5, 'Mantenimiento preventivo realizado al equipo PC-C206-21: limpieza, revisión de conexiones y prueba general.'),
(237, 1, '2026-04-10', 6, 'Mantenimiento preventivo realizado al equipo PC-C206-22: limpieza, revisión de conexiones y prueba general.'),
(238, 1, '2026-04-11', 7, 'Mantenimiento preventivo realizado al equipo PC-C206-23: limpieza, revisión de conexiones y prueba general.'),
(239, 1, '2026-04-12', 8, 'Mantenimiento preventivo realizado al equipo PC-C206-24: limpieza, revisión de conexiones y prueba general.'),
(240, 1, '2026-04-13', 9, 'Mantenimiento preventivo realizado al equipo PC-C206-25: limpieza, revisión de conexiones y prueba general.'),
(241, 1, '2026-04-14', 10, 'Mantenimiento preventivo realizado al equipo PC-C206-26: limpieza, revisión de conexiones y prueba general.'),
(242, 1, '2026-04-15', 11, 'Mantenimiento preventivo realizado al equipo PC-C206-27: limpieza, revisión de conexiones y prueba general.'),
(243, 1, '2026-04-16', 12, 'Mantenimiento preventivo realizado al equipo PC-C206-28: limpieza, revisión de conexiones y prueba general.'),
(244, 1, '2026-04-17', 13, 'Mantenimiento preventivo realizado al equipo PC-C206-29: limpieza, revisión de conexiones y prueba general.'),
(245, 1, '2026-04-18', 14, 'Mantenimiento preventivo realizado al equipo PC-C206-30: limpieza, revisión de conexiones y prueba general.'),
(246, 1, '2026-04-19', 15, 'Mantenimiento preventivo realizado al equipo PC-C206-31: limpieza, revisión de conexiones y prueba general.'),
(247, 1, '2026-04-20', 16, 'Mantenimiento preventivo realizado al equipo PC-C206-32: limpieza, revisión de conexiones y prueba general.'),
(248, 1, '2026-04-21', 1, 'Mantenimiento preventivo realizado al equipo PROY-C206: limpieza, revisión de conexiones y prueba general.'),
(249, 1, '2026-04-24', 3, 'Mantenimiento preventivo realizado al equipo PC-C207-01: limpieza, revisión de conexiones y prueba general.'),
(250, 1, '2026-04-25', 4, 'Mantenimiento preventivo realizado al equipo PC-C207-02: limpieza, revisión de conexiones y prueba general.'),
(251, 1, '2026-04-26', 5, 'Mantenimiento preventivo realizado al equipo PC-C207-03: limpieza, revisión de conexiones y prueba general.'),
(252, 1, '2026-04-27', 6, 'Mantenimiento preventivo realizado al equipo PC-C207-04: limpieza, revisión de conexiones y prueba general.'),
(253, 1, '2026-04-28', 7, 'Mantenimiento preventivo realizado al equipo PC-C207-05: limpieza, revisión de conexiones y prueba general.'),
(254, 1, '2026-04-29', 8, 'Mantenimiento preventivo realizado al equipo PC-C207-06: limpieza, revisión de conexiones y prueba general.'),
(255, 1, '2026-04-30', 9, 'Mantenimiento preventivo realizado al equipo PC-C207-07: limpieza, revisión de conexiones y prueba general.'),
(256, 1, '2026-05-01', 10, 'Mantenimiento preventivo realizado al equipo PC-C207-08: limpieza, revisión de conexiones y prueba general.'),
(257, 1, '2026-05-02', 11, 'Mantenimiento preventivo realizado al equipo PC-C207-09: limpieza, revisión de conexiones y prueba general.'),
(258, 1, '2026-05-03', 12, 'Mantenimiento preventivo realizado al equipo PC-C207-10: limpieza, revisión de conexiones y prueba general.'),
(259, 2, '2026-05-04', 13, 'Mantenimiento correctivo realizado al equipo PC-C207-11: revisión y corrección de falla reportada.'),
(260, 1, '2026-05-05', 14, 'Mantenimiento preventivo realizado al equipo PC-C207-12: limpieza, revisión de conexiones y prueba general.'),
(261, 1, '2026-05-06', 15, 'Mantenimiento preventivo realizado al equipo PC-C207-13: limpieza, revisión de conexiones y prueba general.'),
(262, 1, '2026-05-07', 16, 'Mantenimiento preventivo realizado al equipo PC-C207-14: limpieza, revisión de conexiones y prueba general.'),
(263, 1, '2026-05-08', 1, 'Mantenimiento preventivo realizado al equipo PC-C207-15: limpieza, revisión de conexiones y prueba general.'),
(264, 1, '2026-05-09', 2, 'Mantenimiento preventivo realizado al equipo PC-C207-16: limpieza, revisión de conexiones y prueba general.'),
(265, 1, '2026-05-10', 3, 'Mantenimiento preventivo realizado al equipo PC-C207-17: limpieza, revisión de conexiones y prueba general.'),
(266, 1, '2026-05-11', 4, 'Mantenimiento preventivo realizado al equipo PC-C207-18: limpieza, revisión de conexiones y prueba general.'),
(267, 1, '2026-05-12', 5, 'Mantenimiento preventivo realizado al equipo PC-C207-19: limpieza, revisión de conexiones y prueba general.'),
(268, 1, '2026-05-13', 6, 'Mantenimiento preventivo realizado al equipo PC-C207-20: limpieza, revisión de conexiones y prueba general.'),
(269, 1, '2026-05-14', 7, 'Mantenimiento preventivo realizado al equipo PC-C207-21: limpieza, revisión de conexiones y prueba general.'),
(270, 1, '2026-05-15', 8, 'Mantenimiento preventivo realizado al equipo PC-C207-22: limpieza, revisión de conexiones y prueba general.'),
(271, 1, '2026-05-16', 9, 'Mantenimiento preventivo realizado al equipo PC-C207-23: limpieza, revisión de conexiones y prueba general.'),
(272, 1, '2026-05-17', 10, 'Mantenimiento preventivo realizado al equipo PC-C207-24: limpieza, revisión de conexiones y prueba general.'),
(273, 1, '2026-05-18', 11, 'Mantenimiento preventivo realizado al equipo PC-C207-25: limpieza, revisión de conexiones y prueba general.'),
(274, 1, '2026-05-19', 12, 'Mantenimiento preventivo realizado al equipo PC-C207-26: limpieza, revisión de conexiones y prueba general.'),
(275, 1, '2026-05-20', 13, 'Mantenimiento preventivo realizado al equipo PC-C207-27: limpieza, revisión de conexiones y prueba general.'),
(276, 1, '2026-05-21', 14, 'Mantenimiento preventivo realizado al equipo PC-C207-28: limpieza, revisión de conexiones y prueba general.'),
(277, 1, '2026-05-22', 15, 'Mantenimiento preventivo realizado al equipo PC-C207-29: limpieza, revisión de conexiones y prueba general.'),
(278, 1, '2026-05-23', 16, 'Mantenimiento preventivo realizado al equipo PC-C207-30: limpieza, revisión de conexiones y prueba general.'),
(279, 1, '2026-05-24', 1, 'Mantenimiento preventivo realizado al equipo PC-C207-31: limpieza, revisión de conexiones y prueba general.'),
(280, 1, '2026-05-25', 2, 'Mantenimiento preventivo realizado al equipo PC-C207-32: limpieza, revisión de conexiones y prueba general.'),
(281, 1, '2026-05-26', 3, 'Mantenimiento preventivo realizado al equipo PROY-C207: limpieza, revisión de conexiones y prueba general.'),
(282, 1, '2026-05-29', 5, 'Mantenimiento preventivo realizado al equipo PC-C208-01: limpieza, revisión de conexiones y prueba general.'),
(283, 1, '2026-05-30', 6, 'Mantenimiento preventivo realizado al equipo PC-C208-02: limpieza, revisión de conexiones y prueba general.'),
(284, 1, '2026-05-31', 7, 'Mantenimiento preventivo realizado al equipo PC-C208-03: limpieza, revisión de conexiones y prueba general.'),
(285, 1, '2026-04-01', 8, 'Mantenimiento preventivo realizado al equipo PC-C208-04: limpieza, revisión de conexiones y prueba general.'),
(286, 1, '2026-04-02', 9, 'Mantenimiento preventivo realizado al equipo PC-C208-05: limpieza, revisión de conexiones y prueba general.'),
(287, 1, '2026-04-03', 10, 'Mantenimiento preventivo realizado al equipo PC-C208-06: limpieza, revisión de conexiones y prueba general.'),
(288, 1, '2026-04-04', 11, 'Mantenimiento preventivo realizado al equipo PC-C208-07: limpieza, revisión de conexiones y prueba general.'),
(289, 1, '2026-04-05', 12, 'Mantenimiento preventivo realizado al equipo PC-C208-08: limpieza, revisión de conexiones y prueba general.'),
(290, 1, '2026-04-06', 13, 'Mantenimiento preventivo realizado al equipo PC-C208-09: limpieza, revisión de conexiones y prueba general.'),
(291, 1, '2026-04-07', 14, 'Mantenimiento preventivo realizado al equipo PC-C208-10: limpieza, revisión de conexiones y prueba general.'),
(292, 1, '2026-04-08', 15, 'Mantenimiento preventivo realizado al equipo PC-C208-11: limpieza, revisión de conexiones y prueba general.'),
(293, 1, '2026-04-09', 16, 'Mantenimiento preventivo realizado al equipo PC-C208-12: limpieza, revisión de conexiones y prueba general.'),
(294, 1, '2026-04-10', 1, 'Mantenimiento preventivo realizado al equipo PC-C208-13: limpieza, revisión de conexiones y prueba general.'),
(295, 1, '2026-04-11', 2, 'Mantenimiento preventivo realizado al equipo PC-C208-14: limpieza, revisión de conexiones y prueba general.'),
(296, 2, '2026-04-12', 3, 'Mantenimiento correctivo realizado al equipo PC-C208-15: revisión y corrección de falla reportada.'),
(297, 1, '2026-04-13', 4, 'Mantenimiento preventivo realizado al equipo PC-C208-16: limpieza, revisión de conexiones y prueba general.'),
(298, 1, '2026-04-14', 5, 'Mantenimiento preventivo realizado al equipo PC-C208-17: limpieza, revisión de conexiones y prueba general.'),
(299, 1, '2026-04-15', 6, 'Mantenimiento preventivo realizado al equipo PC-C208-18: limpieza, revisión de conexiones y prueba general.'),
(300, 1, '2026-04-16', 7, 'Mantenimiento preventivo realizado al equipo PC-C208-19: limpieza, revisión de conexiones y prueba general.'),
(301, 1, '2026-04-17', 8, 'Mantenimiento preventivo realizado al equipo PC-C208-20: limpieza, revisión de conexiones y prueba general.'),
(302, 1, '2026-04-18', 9, 'Mantenimiento preventivo realizado al equipo PC-C208-21: limpieza, revisión de conexiones y prueba general.'),
(303, 1, '2026-04-19', 10, 'Mantenimiento preventivo realizado al equipo PC-C208-22: limpieza, revisión de conexiones y prueba general.'),
(304, 1, '2026-04-20', 11, 'Mantenimiento preventivo realizado al equipo PC-C208-23: limpieza, revisión de conexiones y prueba general.'),
(305, 1, '2026-04-21', 12, 'Mantenimiento preventivo realizado al equipo PC-C208-24: limpieza, revisión de conexiones y prueba general.'),
(306, 1, '2026-04-22', 13, 'Mantenimiento preventivo realizado al equipo PC-C208-25: limpieza, revisión de conexiones y prueba general.'),
(307, 1, '2026-04-23', 14, 'Mantenimiento preventivo realizado al equipo PC-C208-26: limpieza, revisión de conexiones y prueba general.'),
(308, 1, '2026-04-24', 15, 'Mantenimiento preventivo realizado al equipo PC-C208-27: limpieza, revisión de conexiones y prueba general.'),
(309, 1, '2026-04-25', 16, 'Mantenimiento preventivo realizado al equipo PC-C208-28: limpieza, revisión de conexiones y prueba general.'),
(310, 1, '2026-04-26', 1, 'Mantenimiento preventivo realizado al equipo PC-C208-29: limpieza, revisión de conexiones y prueba general.'),
(311, 1, '2026-04-27', 2, 'Mantenimiento preventivo realizado al equipo PC-C208-30: limpieza, revisión de conexiones y prueba general.'),
(312, 1, '2026-04-28', 3, 'Mantenimiento preventivo realizado al equipo PC-C208-31: limpieza, revisión de conexiones y prueba general.'),
(313, 1, '2026-04-29', 4, 'Mantenimiento preventivo realizado al equipo PC-C208-32: limpieza, revisión de conexiones y prueba general.'),
(314, 1, '2026-04-30', 5, 'Mantenimiento preventivo realizado al equipo PROY-C208: limpieza, revisión de conexiones y prueba general.'),
(315, 1, '2026-05-03', 7, 'Mantenimiento preventivo realizado al equipo PC-C209-01: limpieza, revisión de conexiones y prueba general.'),
(316, 1, '2026-05-04', 8, 'Mantenimiento preventivo realizado al equipo PC-C209-02: limpieza, revisión de conexiones y prueba general.'),
(317, 1, '2026-05-05', 9, 'Mantenimiento preventivo realizado al equipo PC-C209-03: limpieza, revisión de conexiones y prueba general.'),
(318, 1, '2026-05-06', 10, 'Mantenimiento preventivo realizado al equipo PC-C209-04: limpieza, revisión de conexiones y prueba general.'),
(319, 1, '2026-05-07', 11, 'Mantenimiento preventivo realizado al equipo PC-C209-05: limpieza, revisión de conexiones y prueba general.'),
(320, 1, '2026-05-08', 12, 'Mantenimiento preventivo realizado al equipo PC-C209-06: limpieza, revisión de conexiones y prueba general.'),
(321, 1, '2026-05-09', 13, 'Mantenimiento preventivo realizado al equipo PC-C209-07: limpieza, revisión de conexiones y prueba general.'),
(322, 1, '2026-05-10', 14, 'Mantenimiento preventivo realizado al equipo PC-C209-08: limpieza, revisión de conexiones y prueba general.'),
(323, 1, '2026-05-11', 15, 'Mantenimiento preventivo realizado al equipo PC-C209-09: limpieza, revisión de conexiones y prueba general.'),
(324, 1, '2026-05-12', 16, 'Mantenimiento preventivo realizado al equipo PC-C209-10: limpieza, revisión de conexiones y prueba general.'),
(325, 1, '2026-05-13', 1, 'Mantenimiento preventivo realizado al equipo PC-C209-11: limpieza, revisión de conexiones y prueba general.'),
(326, 1, '2026-05-14', 2, 'Mantenimiento preventivo realizado al equipo PC-C209-12: limpieza, revisión de conexiones y prueba general.'),
(327, 1, '2026-05-15', 3, 'Mantenimiento preventivo realizado al equipo PC-C209-13: limpieza, revisión de conexiones y prueba general.'),
(328, 1, '2026-05-16', 4, 'Mantenimiento preventivo realizado al equipo PC-C209-14: limpieza, revisión de conexiones y prueba general.'),
(329, 1, '2026-05-17', 5, 'Mantenimiento preventivo realizado al equipo PC-C209-15: limpieza, revisión de conexiones y prueba general.'),
(330, 1, '2026-05-18', 6, 'Mantenimiento preventivo realizado al equipo PC-C209-16: limpieza, revisión de conexiones y prueba general.'),
(331, 1, '2026-05-19', 7, 'Mantenimiento preventivo realizado al equipo PC-C209-17: limpieza, revisión de conexiones y prueba general.'),
(332, 1, '2026-05-20', 8, 'Mantenimiento preventivo realizado al equipo PC-C209-18: limpieza, revisión de conexiones y prueba general.'),
(333, 2, '2026-05-21', 9, 'Mantenimiento correctivo realizado al equipo PC-C209-19: revisión y corrección de falla reportada.'),
(334, 1, '2026-05-22', 10, 'Mantenimiento preventivo realizado al equipo PC-C209-20: limpieza, revisión de conexiones y prueba general.'),
(335, 1, '2026-05-23', 11, 'Mantenimiento preventivo realizado al equipo PC-C209-21: limpieza, revisión de conexiones y prueba general.'),
(336, 1, '2026-05-24', 12, 'Mantenimiento preventivo realizado al equipo PC-C209-22: limpieza, revisión de conexiones y prueba general.'),
(337, 1, '2026-05-25', 13, 'Mantenimiento preventivo realizado al equipo PC-C209-23: limpieza, revisión de conexiones y prueba general.'),
(338, 1, '2026-05-26', 14, 'Mantenimiento preventivo realizado al equipo PC-C209-24: limpieza, revisión de conexiones y prueba general.'),
(339, 1, '2026-05-27', 15, 'Mantenimiento preventivo realizado al equipo PC-C209-25: limpieza, revisión de conexiones y prueba general.'),
(340, 1, '2026-05-28', 16, 'Mantenimiento preventivo realizado al equipo PC-C209-26: limpieza, revisión de conexiones y prueba general.'),
(341, 1, '2026-05-29', 1, 'Mantenimiento preventivo realizado al equipo PC-C209-27: limpieza, revisión de conexiones y prueba general.'),
(342, 1, '2026-05-30', 2, 'Mantenimiento preventivo realizado al equipo PC-C209-28: limpieza, revisión de conexiones y prueba general.'),
(343, 1, '2026-05-31', 3, 'Mantenimiento preventivo realizado al equipo PC-C209-29: limpieza, revisión de conexiones y prueba general.'),
(344, 1, '2026-04-01', 4, 'Mantenimiento preventivo realizado al equipo PC-C209-30: limpieza, revisión de conexiones y prueba general.'),
(345, 1, '2026-04-02', 5, 'Mantenimiento preventivo realizado al equipo PC-C209-31: limpieza, revisión de conexiones y prueba general.'),
(346, 1, '2026-04-03', 6, 'Mantenimiento preventivo realizado al equipo PC-C209-32: limpieza, revisión de conexiones y prueba general.'),
(347, 1, '2026-04-04', 7, 'Mantenimiento preventivo realizado al equipo PROY-C209: limpieza, revisión de conexiones y prueba general.'),
(348, 1, '2026-04-07', 9, 'Mantenimiento preventivo realizado al equipo PC-O201-01: limpieza, revisión de conexiones y prueba general.'),
(349, 1, '2026-04-08', 10, 'Mantenimiento preventivo realizado al equipo PC-O201-02: limpieza, revisión de conexiones y prueba general.'),
(350, 1, '2026-04-09', 11, 'Mantenimiento preventivo realizado al equipo PC-O201-03: limpieza, revisión de conexiones y prueba general.'),
(351, 1, '2026-04-10', 12, 'Mantenimiento preventivo realizado al equipo PC-O201-04: limpieza, revisión de conexiones y prueba general.'),
(352, 1, '2026-04-11', 13, 'Mantenimiento preventivo realizado al equipo PC-O201-05: limpieza, revisión de conexiones y prueba general.'),
(353, 1, '2026-04-12', 14, 'Mantenimiento preventivo realizado al equipo PC-O201-06: limpieza, revisión de conexiones y prueba general.'),
(354, 1, '2026-04-13', 15, 'Mantenimiento preventivo realizado al equipo PC-O201-07: limpieza, revisión de conexiones y prueba general.'),
(355, 1, '2026-04-14', 16, 'Mantenimiento preventivo realizado al equipo PC-O201-08: limpieza, revisión de conexiones y prueba general.'),
(356, 1, '2026-04-15', 1, 'Mantenimiento preventivo realizado al equipo PC-O201-09: limpieza, revisión de conexiones y prueba general.'),
(357, 1, '2026-04-16', 2, 'Mantenimiento preventivo realizado al equipo PC-O201-10: limpieza, revisión de conexiones y prueba general.'),
(358, 1, '2026-04-17', 3, 'Mantenimiento preventivo realizado al equipo PC-O201-11: limpieza, revisión de conexiones y prueba general.'),
(359, 1, '2026-04-18', 4, 'Mantenimiento preventivo realizado al equipo PC-O201-12: limpieza, revisión de conexiones y prueba general.'),
(360, 1, '2026-04-19', 5, 'Mantenimiento preventivo realizado al equipo PC-O201-13: limpieza, revisión de conexiones y prueba general.'),
(361, 1, '2026-04-20', 6, 'Mantenimiento preventivo realizado al equipo PC-O201-14: limpieza, revisión de conexiones y prueba general.'),
(362, 1, '2026-04-21', 7, 'Mantenimiento preventivo realizado al equipo PC-O201-15: limpieza, revisión de conexiones y prueba general.'),
(363, 1, '2026-04-22', 8, 'Mantenimiento preventivo realizado al equipo PC-O201-16: limpieza, revisión de conexiones y prueba general.'),
(364, 1, '2026-04-23', 9, 'Mantenimiento preventivo realizado al equipo PC-O201-17: limpieza, revisión de conexiones y prueba general.'),
(365, 1, '2026-04-24', 10, 'Mantenimiento preventivo realizado al equipo PC-O201-18: limpieza, revisión de conexiones y prueba general.'),
(366, 1, '2026-04-25', 11, 'Mantenimiento preventivo realizado al equipo PC-O201-19: limpieza, revisión de conexiones y prueba general.'),
(367, 1, '2026-04-26', 12, 'Mantenimiento preventivo realizado al equipo PC-O201-20: limpieza, revisión de conexiones y prueba general.'),
(368, 1, '2026-04-27', 13, 'Mantenimiento preventivo realizado al equipo PC-O201-21: limpieza, revisión de conexiones y prueba general.'),
(369, 1, '2026-04-28', 14, 'Mantenimiento preventivo realizado al equipo PC-O201-22: limpieza, revisión de conexiones y prueba general.'),
(370, 2, '2026-04-29', 15, 'Mantenimiento correctivo realizado al equipo PC-O201-23: revisión y corrección de falla reportada.'),
(371, 1, '2026-04-30', 16, 'Mantenimiento preventivo realizado al equipo PC-O201-24: limpieza, revisión de conexiones y prueba general.'),
(372, 1, '2026-05-01', 1, 'Mantenimiento preventivo realizado al equipo PC-O201-25: limpieza, revisión de conexiones y prueba general.'),
(373, 1, '2026-05-02', 2, 'Mantenimiento preventivo realizado al equipo PC-O201-26: limpieza, revisión de conexiones y prueba general.'),
(374, 1, '2026-05-03', 3, 'Mantenimiento preventivo realizado al equipo PC-O201-27: limpieza, revisión de conexiones y prueba general.'),
(375, 1, '2026-05-04', 4, 'Mantenimiento preventivo realizado al equipo PC-O201-28: limpieza, revisión de conexiones y prueba general.'),
(376, 1, '2026-05-05', 5, 'Mantenimiento preventivo realizado al equipo PC-O201-29: limpieza, revisión de conexiones y prueba general.'),
(377, 1, '2026-05-06', 6, 'Mantenimiento preventivo realizado al equipo PC-O201-30: limpieza, revisión de conexiones y prueba general.'),
(378, 1, '2026-05-07', 7, 'Mantenimiento preventivo realizado al equipo PC-O201-31: limpieza, revisión de conexiones y prueba general.'),
(379, 1, '2026-05-08', 8, 'Mantenimiento preventivo realizado al equipo PC-O201-32: limpieza, revisión de conexiones y prueba general.'),
(380, 1, '2026-05-09', 9, 'Mantenimiento preventivo realizado al equipo PROY-O201: limpieza, revisión de conexiones y prueba general.');

GO


-- Verificación rápida
SELECT COUNT(*) AS TotalSalones FROM Mantenimiento.Salon;
SELECT COUNT(*) AS TotalDispositivos FROM Mantenimiento.Dispositivo;
SELECT COUNT(*) AS TotalMantenimientos FROM Mantenimiento.Mantenimiento;

/* Comentario ahi pa saber, para hacer una consulta al tener schemas debes poner (schema).(tabla) */
