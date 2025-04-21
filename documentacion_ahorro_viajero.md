# Documentación del Proyecto: Ahorro Viajero

## Índice
1. [Descripción General](#descripción-general)
2. [Arquitectura del Sistema](#arquitectura-del-sistema)
3. [Modelos de Datos](#modelos-de-datos)
4. [Funcionalidades Principales](#funcionalidades-principales)
5. [Flujos de Usuario](#flujos-de-usuario)
6. [Tecnologías Utilizadas](#tecnologías-utilizadas)
7. [Posibles Mejoras Futuras](#posibles-mejoras-futuras)

## Descripción General

**Ahorro Viajero** es una aplicación móvil desarrollada con Flutter que permite a los usuarios gestionar sus presupuestos y gastos durante viajes. La aplicación está especialmente diseñada para viajeros que necesitan controlar sus finanzas en diferentes monedas, facilitando el seguimiento de gastos independientemente de la divisa utilizada.

La aplicación permite crear presupuestos para viajes, registrar gastos asociados a cada presupuesto, categorizar los gastos, adjuntar imágenes de recibos, visualizar informes y estadísticas, y gestionar diferentes monedas con conversiones automáticas.

## Arquitectura del Sistema

La aplicación utiliza una arquitectura basada en Provider para la gestión del estado, con una clara separación entre:

- **Modelos**: Definen la estructura de datos (Budget, Expense, Currency)
- **Vistas (Screens)**: Interfaces de usuario para la interacción
- **Providers**: Gestores de estado que conectan la UI con los datos
- **Servicios**: Lógica de negocio y conexión con servicios externos
- **Base de datos**: Capa de persistencia local con SQLite

## Modelos de Datos

### Presupuesto (Budget)
Representa un presupuesto de viaje con las siguientes propiedades:
- **id**: Identificador único
- **title**: Título del presupuesto
- **totalAmount**: Monto total asignado
- **originCurrencyCode**: Código de la moneda de origen
- **destinationCurrencyCode**: Código de la moneda de destino
- **exchangeRate**: Tasa de cambio entre monedas
- **startDate**: Fecha de inicio del viaje
- **endDate**: Fecha de finalización del viaje (opcional)
- **notes**: Notas adicionales (opcional)

### Gasto (Expense)
Representa un gasto individual realizado durante el viaje:
- **id**: Identificador único
- **budgetId**: ID del presupuesto asociado
- **description**: Descripción del gasto
- **amount**: Monto del gasto
- **currencyCode**: Código de la moneda utilizada
- **isLocalCurrency**: Indica si el gasto está en moneda local
- **conversionRate**: Tasa de conversión aplicada
- **category**: Categoría del gasto (enum ExpenseCategory)
- **date**: Fecha del gasto
- **imagePath**: Ruta a la imagen del recibo (opcional)
- **notes**: Notas adicionales (opcional)

### Categorías de Gasto
Las categorías disponibles incluyen:
- Transporte
- Alojamiento
- Alimentación general
- Desayuno
- Comida
- Cena
- Snacks
- Entradas
- Vida nocturna
- Actividades
- Compras
- Salud
- Regalos
- Otros

## Funcionalidades Principales

### 1. Gestión de Presupuestos
- **Crear presupuesto**: Definir presupuesto total, moneda de origen y destino.
- **Editar presupuesto**: Modificar detalles de un presupuesto existente.
- **Eliminar presupuesto**: Borrar un presupuesto y todos sus gastos asociados.
- **Ver lista de presupuestos**: Visualizar todos los presupuestos creados.

### 2. Gestión de Gastos
- **Registrar gastos**: Añadir nuevos gastos a un presupuesto específico.
- **Categorizar gastos**: Clasificar gastos según categorías predefinidas.
- **Editar gastos**: Modificar detalles de gastos existentes.
- **Eliminar gastos**: Borrar gastos individuales.
- **Adjuntar imágenes**: Capturar o seleccionar imágenes de recibos.
- **Ver imágenes de recibos**: Visualizar las imágenes guardadas.
- **Añadir notas**: Incluir comentarios adicionales sobre cada gasto.

### 3. Conversión de Monedas
- **Configurar tipos de cambio**: Establecer la relación entre moneda de origen y destino.
- **Registro de gastos en ambas monedas**: Posibilidad de registrar gastos tanto en moneda local como en la de origen.
- **Conversión automática**: Cálculo automático del equivalente en la otra moneda.

### 4. Análisis y Estadísticas
- **Resumen de presupuesto**: Visualización del presupuesto total y gastado.
- **Gráfico de distribución por categorías**: Representación visual del gasto por categorías.
- **Seguimiento del gasto diario**: Vista del gasto distribuido por fechas.
- **Balance general**: Estado general del presupuesto y proyección de gasto.

### 5. Interfaz de Usuario
- **Diseño intuitivo**: Navegación clara y sencilla.
- **Tema Material Design**: Interfaz moderna con elementos visuales consistentes.
- **Soporte para español**: Localización completa en idioma español.
- **Modo retrato**: Optimizado para uso en orientación vertical.

## Flujos de Usuario

### Flujo de creación de presupuesto
1. El usuario accede a la pantalla de inicio.
2. Pulsa en el botón "Nuevo presupuesto".
3. Introduce el título, monto total, moneda de origen y destino.
4. Establece la tasa de cambio entre monedas.
5. Define las fechas del viaje.
6. Opcionalmente añade notas adicionales.
7. Guarda el presupuesto y regresa a la pantalla principal.

### Flujo de registro de gastos
1. El usuario selecciona un presupuesto existente.
2. Accede a la pantalla de detalle del presupuesto.
3. Pulsa en el botón "Añadir gasto".
4. Introduce la descripción, monto y selecciona la categoría.
5. Selecciona la moneda y la fecha.
6. Opcionalmente toma una foto del recibo.
7. Añade notas si lo desea.
8. Guarda el gasto y regresa a la pantalla de detalle.

### Flujo de análisis de gastos
1. El usuario selecciona un presupuesto existente.
2. En la pantalla de detalle visualiza el resumen general.
3. Puede ver el gráfico de distribución por categorías.
4. Puede filtrar los gastos por fecha o categoría.
5. Accede a los detalles de gastos individuales si necesita más información.

## Tecnologías Utilizadas

- **Flutter SDK**: Framework de desarrollo multiplataforma
- **Provider**: Gestión de estado
- **SQLite (sqflite)**: Base de datos local
- **Shared Preferences**: Almacenamiento de configuraciones
- **FL Chart**: Visualización de gráficos y estadísticas
- **Image Picker**: Captura y selección de imágenes
- **Flutter Localizations**: Soporte para internacionalización
- **Path Provider**: Gestión de rutas para almacenamiento de archivos

## Posibles Mejoras Futuras

1. **Sincronización en la nube**: Backup y sincronización entre dispositivos.
2. **API de conversión de monedas**: Conexión con servicios externos para actualización automática de tasas de cambio.
3. **Exportación de datos**: Posibilidad de exportar gastos en formato CSV o PDF.
4. **Reconocimiento OCR**: Extraer automáticamente información de recibos mediante escaneo.
5. **Modo offline mejorado**: Capacidades extendidas sin conexión a internet.
6. **Notificaciones**: Alertas para recordar registrar gastos o límites presupuestarios.
7. **Compartir presupuestos**: Funcionalidad para viajes grupales donde varios usuarios puedan colaborar.
8. **Widgets para pantalla de inicio**: Acceso rápido a funciones desde la pantalla principal del dispositivo.
9. **Integración con servicios de pago**: Conexión con plataformas como PayPal o tarjetas bancarias.
10. **Modo oscuro**: Implementación de tema alternativo para uso nocturno.