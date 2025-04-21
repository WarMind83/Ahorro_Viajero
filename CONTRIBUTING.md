# Guía de Contribución para Ahorro Viajero

¡Gracias por tu interés en contribuir a Ahorro Viajero! Este documento proporciona una guía sobre cómo puedes ayudar a mejorar la aplicación.

## Cómo contribuir

Hay varias formas en las que puedes contribuir al proyecto:

### 1. Reportar problemas

Si encuentras un error o un problema con la aplicación, por favor abre un issue en el repositorio de GitHub con la siguiente información:

- Una descripción clara y concisa del problema
- Pasos para reproducir el error
- Comportamiento esperado vs. comportamiento observado
- Capturas de pantalla si es posible
- Información sobre tu dispositivo y versión de la aplicación

### 2. Sugerir mejoras

Si tienes ideas para nuevas características o mejoras, abre un issue con la etiqueta "enhancement" y describe:

- Qué te gustaría ver implementado
- Por qué sería útil esta característica
- Cómo imaginas que funcionaría

### 3. Contribuir con código

Si quieres contribuir directamente con código:

1. Haz un fork del repositorio
2. Crea una rama para tu feature o fix: `git checkout -b nombre-de-la-caracteristica`
3. Realiza tus cambios y asegúrate de seguir el estilo de código
4. Escribe pruebas para tus cambios si es aplicable
5. Haz commit de tus cambios: `git commit -m 'Descripción de los cambios'`
6. Haz push a tu rama: `git push origin nombre-de-la-caracteristica`
7. Envía un pull request

## Estilo de código

- Sigue las convenciones de nomenclatura establecidas en el proyecto
- Utiliza el formato de código estándar de Dart
- Comenta tu código cuando sea necesario para explicar la lógica compleja
- Escribe tests para la nueva funcionalidad si es posible

## Directrices para Pull Requests

- Describe claramente qué cambios introduce tu PR
- Vincula cualquier issue relacionado
- Incluye capturas de pantalla o GIFs para cambios de UI si es aplicable
- Asegúrate de que todos los tests pasan antes de enviar el PR
- Mantén los PR enfocados - un PR por característica o fix

## Estructura del Proyecto

Para contribuir efectivamente, es útil entender la estructura del proyecto:

- `/lib/models`: Definiciones de datos estructurados
- `/lib/screens`: Pantallas de la aplicación
- `/lib/widgets`: Componentes reutilizables de UI
- `/lib/services`: Servicios para operaciones externas o complejas
- `/lib/db`: Código relacionado con la base de datos
- `/lib/providers`: Proveedores de estado con Provider
- `/lib/utils`: Utilidades y helpers

## Licencia

Al contribuir a este repositorio, aceptas que tus contribuciones serán licenciadas bajo la misma licencia que el proyecto (MIT).

---

Gracias por contribuir a hacer Ahorro Viajero mejor para todos los usuarios.