IF DB_ID(N'InmobiliariaDB') IS NULL
BEGIN
    CREATE DATABASE InmobiliariaDB;
END
GO

USE InmobiliariaDB;
GO

-- 1. PERSONAS Y ROLES
CREATE TABLE Persona (
    id INT IDENTITY(1,1) PRIMARY KEY,
    apellido NVARCHAR(100) NOT NULL,
    nombre NVARCHAR(100) NOT NULL,
    direccion NVARCHAR(200) NULL,
    email NVARCHAR(120) NULL,
    telefono NVARCHAR(30) NULL
);
GO

CREATE TABLE Propietario (
    id INT IDENTITY(1,1) PRIMARY KEY,
    id_persona INT NOT NULL UNIQUE,
    ci NVARCHAR(25) NOT NULL,
    fecha_registro DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    observaciones NVARCHAR(255) NULL,
    estado NVARCHAR(20) NOT NULL DEFAULT 'Activo',
    CONSTRAINT FK_Propietario_Persona FOREIGN KEY (id_persona) REFERENCES Persona(id),
    CONSTRAINT CHK_Propietario_Estado CHECK (estado IN ('Activo', 'Anulado', 'Finalizado', 'Pendiente'))
);
GO

CREATE TABLE Agente_Venta (
    id INT IDENTITY(1,1) PRIMARY KEY,
    id_persona INT NOT NULL UNIQUE,
    fecha_contratacion DATE NOT NULL,
    CONSTRAINT FK_AgenteVenta_Persona FOREIGN KEY (id_persona) REFERENCES Persona(id)
);
GO

CREATE TABLE Cliente (
    id INT IDENTITY(1,1) PRIMARY KEY,
    id_persona INT NOT NULL UNIQUE,
    ci NVARCHAR(25) NOT NULL,
    CONSTRAINT FK_Cliente_Persona FOREIGN KEY (id_persona) REFERENCES Persona(id)
);
GO

CREATE TABLE Usuario (
    id INT IDENTITY(1,1) PRIMARY KEY,
    id_persona INT NULL,
    login NVARCHAR(60) NOT NULL UNIQUE,
    password NVARCHAR(255) NOT NULL,
    fecha_registro DATETIME NOT NULL DEFAULT GETDATE(),
    rol NVARCHAR(40) NOT NULL,
    CONSTRAINT FK_Usuario_Persona FOREIGN KEY (id_persona) REFERENCES Persona(id),
    CONSTRAINT CHK_Usuario_Rol CHECK (rol IN ('Administrador', 'Agente de Venta', 'Administrador de Sistemas'))
);
GO

-- 2. INMUEBLES, FOTOS E INTERESADOS
CREATE TABLE Inmueble (
    id INT IDENTITY(1,1) PRIMARY KEY,
    id_propietario INT NOT NULL,
    dimensiones NVARCHAR(100) NULL,
    tipo_inmueble NVARCHAR(60) NOT NULL,
    direccion NVARCHAR(200) NOT NULL,
    descripcion_inmueble NVARCHAR(MAX) NULL,
    CONSTRAINT FK_Inmueble_Propietario FOREIGN KEY (id_propietario) REFERENCES Propietario(id)
);
GO

CREATE TABLE Datos_Foto (
    id INT IDENTITY(1,1) PRIMARY KEY,
    id_inmueble INT NOT NULL,
    descripcion_fotografia NVARCHAR(255) NULL,
    CONSTRAINT FK_DatosFoto_Inmueble FOREIGN KEY (id_inmueble) REFERENCES Inmueble(id)
);
GO

CREATE TABLE Interesado (
    id INT IDENTITY(1,1) PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_inmueble INT NOT NULL,
    porcentaje_adelantado DECIMAL(5,2) NOT NULL DEFAULT 0,
    estado NVARCHAR(20) NOT NULL DEFAULT 'Pendiente',
    CONSTRAINT FK_Interesado_Cliente FOREIGN KEY (id_cliente) REFERENCES Cliente(id),
    CONSTRAINT FK_Interesado_Inmueble FOREIGN KEY (id_inmueble) REFERENCES Inmueble(id),
    CONSTRAINT CHK_Interesado_Estado CHECK (estado IN ('Activo', 'Anulado', 'Finalizado', 'Pendiente'))
);
GO

-- 3. OPERACIONES, COMISIONES Y CONTRATOS
CREATE TABLE Comision (
    id INT IDENTITY(1,1) PRIMARY KEY,
    porcentaje_comision DECIMAL(5,2) NOT NULL
);
GO

CREATE TABLE Operacion (
    id INT IDENTITY(1,1) PRIMARY KEY,
    id_comision INT NULL,
    tipo_operacion NVARCHAR(60) NOT NULL,
    fecha_operacion DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Operacion_Comision FOREIGN KEY (id_comision) REFERENCES Comision(id)
);
GO

CREATE TABLE Contrato (
    id INT IDENTITY(1,1) PRIMARY KEY,
    id_inmueble INT NOT NULL,
    id_cliente INT NOT NULL,
    id_agente INT NOT NULL,
    id_operacion INT NULL,
    estado NVARCHAR(20) NOT NULL DEFAULT 'Pendiente',
    precio_final DECIMAL(12,2) NOT NULL,
    fecha_inicial DATE NOT NULL,
    fecha_final DATE NULL,
    CONSTRAINT FK_Contrato_Inmueble FOREIGN KEY (id_inmueble) REFERENCES Inmueble(id),
    CONSTRAINT FK_Contrato_Cliente FOREIGN KEY (id_cliente) REFERENCES Cliente(id),
    CONSTRAINT FK_Contrato_Agente FOREIGN KEY (id_agente) REFERENCES Agente_Venta(id),
    CONSTRAINT FK_Contrato_Operacion FOREIGN KEY (id_operacion) REFERENCES Operacion(id),
    CONSTRAINT CHK_Contrato_Estado CHECK (estado IN ('Activo', 'Anulado', 'Finalizado', 'Pendiente'))
);
GO

CREATE TABLE Alquiler (
    id INT IDENTITY(1,1) PRIMARY KEY,
    id_contrato INT NOT NULL UNIQUE,
    fecha_inicial DATE NOT NULL,
    fecha_final DATE NOT NULL,
    estado NVARCHAR(20) NOT NULL DEFAULT 'Activo',
    CONSTRAINT FK_Alquiler_Contrato FOREIGN KEY (id_contrato) REFERENCES Contrato(id),
    CONSTRAINT CHK_Alquiler_Estado CHECK (estado IN ('Activo', 'Anulado', 'Finalizado', 'Pendiente'))
);
GO

CREATE TABLE Anticretico (
    id INT IDENTITY(1,1) PRIMARY KEY,
    id_contrato INT NOT NULL UNIQUE,
    fecha_inicial DATE NOT NULL,
    fecha_final DATE NOT NULL,
    estado NVARCHAR(20) NOT NULL DEFAULT 'Activo',
    CONSTRAINT FK_Anticretico_Contrato FOREIGN KEY (id_contrato) REFERENCES Contrato(id),
    CONSTRAINT CHK_Anticretico_Estado CHECK (estado IN ('Activo', 'Anulado', 'Finalizado', 'Pendiente'))
);
GO

CREATE TABLE Venta (
    id INT IDENTITY(1,1) PRIMARY KEY,
    id_contrato INT NOT NULL UNIQUE,
    fecha DATE NOT NULL,
    estado NVARCHAR(20) NOT NULL DEFAULT 'Activo',
    CONSTRAINT FK_Venta_Contrato FOREIGN KEY (id_contrato) REFERENCES Contrato(id),
    CONSTRAINT CHK_Venta_Estado CHECK (estado IN ('Activo', 'Anulado', 'Finalizado', 'Pendiente'))
);
GO

CREATE TABLE Compra (
    id INT IDENTITY(1,1) PRIMARY KEY,
    id_contrato INT NOT NULL UNIQUE,
    fecha_compra DATE NOT NULL,
    modalidad_compra NVARCHAR(60) NULL,
    numero_minuta NVARCHAR(60) NULL,
    observaciones NVARCHAR(255) NULL,
    CONSTRAINT FK_Compra_Contrato FOREIGN KEY (id_contrato) REFERENCES Contrato(id)
);
GO

-- 4. PAGOS Y REPORTES
CREATE TABLE Pago_Alquiler (
    id INT IDENTITY(1,1) PRIMARY KEY,
    id_alquiler INT NOT NULL,
    forma_pago NVARCHAR(30) NOT NULL,
    monto_pago DECIMAL(12,2) NOT NULL,
    porcentaje_interes DECIMAL(5,2) NOT NULL DEFAULT 0,
    estado NVARCHAR(20) NOT NULL DEFAULT 'Pendiente',
    CONSTRAINT FK_PagoAlquiler_Alquiler FOREIGN KEY (id_alquiler) REFERENCES Alquiler(id),
    CONSTRAINT CHK_PagoAlquiler_Forma CHECK (forma_pago IN ('En cuotas', 'Al contado')),
    CONSTRAINT CHK_PagoAlquiler_Estado CHECK (estado IN ('Activo', 'Anulado', 'Finalizado', 'Pendiente'))
);
GO

CREATE TABLE Pago_Anticretico (
    id INT IDENTITY(1,1) PRIMARY KEY,
    id_anticretico INT NOT NULL,
    forma_pago NVARCHAR(30) NOT NULL,
    monto_total DECIMAL(12,2) NOT NULL,
    estado NVARCHAR(20) NOT NULL DEFAULT 'Pendiente',
    CONSTRAINT FK_PagoAnticretico_Anticretico FOREIGN KEY (id_anticretico) REFERENCES Anticretico(id),
    CONSTRAINT CHK_PagoAnticretico_Forma CHECK (forma_pago IN ('En cuotas', 'Al contado')),
    CONSTRAINT CHK_PagoAnticretico_Estado CHECK (estado IN ('Activo', 'Anulado', 'Finalizado', 'Pendiente'))
);
GO

CREATE TABLE Pago_Venta (
    id INT IDENTITY(1,1) PRIMARY KEY,
    id_venta INT NOT NULL,
    tipo_pago NVARCHAR(30) NOT NULL,
    cant_efectivo DECIMAL(12,2) NOT NULL DEFAULT 0,
    cant_transferencia DECIMAL(12,2) NOT NULL DEFAULT 0,
    estado NVARCHAR(20) NOT NULL DEFAULT 'Pendiente',
    CONSTRAINT FK_PagoVenta_Venta FOREIGN KEY (id_venta) REFERENCES Venta(id),
    CONSTRAINT CHK_PagoVenta_Tipo CHECK (tipo_pago IN ('En cuotas', 'Al contado')),
    CONSTRAINT CHK_PagoVenta_Estado CHECK (estado IN ('Activo', 'Anulado', 'Finalizado', 'Pendiente'))
);
GO

CREATE TABLE Pago_Compra (
    id INT IDENTITY(1,1) PRIMARY KEY,
    id_compra INT NOT NULL,
    tipo_pago NVARCHAR(30) NOT NULL,
    cant_efectivo DECIMAL(12,2) NOT NULL DEFAULT 0,
    cant_transferencia DECIMAL(12,2) NOT NULL DEFAULT 0,
    porcentaje DECIMAL(5,2) NOT NULL DEFAULT 0,
    estado NVARCHAR(20) NOT NULL DEFAULT 'Pendiente',
    CONSTRAINT FK_PagoCompra_Compra FOREIGN KEY (id_compra) REFERENCES Compra(id),
    CONSTRAINT CHK_PagoCompra_Tipo CHECK (tipo_pago IN ('En cuotas', 'Al contado')),
    CONSTRAINT CHK_PagoCompra_Estado CHECK (estado IN ('Activo', 'Anulado', 'Finalizado', 'Pendiente'))
);
GO

CREATE TABLE Reportes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    id_usuario INT NULL,
    id_inmueble INT NULL,
    id_contrato INT NULL,
    fecha_inicial DATE NOT NULL,
    fecha_final DATE NOT NULL,
    CONSTRAINT FK_Reportes_Usuario FOREIGN KEY (id_usuario) REFERENCES Usuario(id),
    CONSTRAINT FK_Reportes_Inmueble FOREIGN KEY (id_inmueble) REFERENCES Inmueble(id),
    CONSTRAINT FK_Reportes_Contrato FOREIGN KEY (id_contrato) REFERENCES Contrato(id)
);
GO
