# Papeados

![Estado del Proyecto](https://img.shields.io/badge/Estado-En%20Desarrollo-yellow)
![Licencia](https://img.shields.io/badge/license-%20%20GNU%20GPLv3%20-green?style=plastic)
![Versión](https://img.shields.io/badge/Versión-0.1.0--alpha-orange)

> Un juego multijugador casual tipo "papa caliente" donde la última persona con la papa... ¡Es papeado!

---

## Descripción

**Papeados** es un videojuego multijugador en red de 2 a 6 jugadores inspirado en el clásico juego de "papa caliente". Los jugadores deben evitar quedarse con la papa bomba cuando el temporizador llegue a cero, moviéndose estratégicamente por el mapa y pasándola a otros jugadores mediante colisión.

Este proyecto es desarrollado como parte del curso de **Videojuegos en Red** con el objetivo de aprender y aplicar conceptos de:
- Programación de videojuegos multijugador
- Sincronización de estado en red
- Arquitectura cliente-servidor
- Trabajo colaborativo con control de versiones

---

## Características

### Implementadas
- [x] Movimiento de jugadores en 2D (Básico)
- [ ] Sistema de colisiones
- [ ] Temporizador regresivo
- [ ] Transferencia de papa entre jugadores
- [ ] Sistema de eliminación

### En Desarrollo
- [ ] Networking multijugador
- [ ] Sistema de lobby
- [ ] Interfaz de usuario completa
- [ ] Efectos de sonido y música
- [ ] Sistema de puntuación

### Planeadas
- [ ] Múltiples mapas
- [ ] Power-ups especiales
- [ ] Modos de juego alternativos
- [ ] Sistema de ranking
- [ ] Personalización de personajes

---

## Capturas de Pantalla

> _Próximamente - El proyecto está en fase de desarrollo inicial_

---

## Tecnologías

### Núcleo del Proyecto
- **Motor de Juego**: [Godot]
- **Lenguaje**: [GDScript]

### Herramientas de Desarrollo
- **Control de Versiones**: Git & GitHub
- **Gestión de Proyecto**: [Notion]
- **Comunicación**: Discord
- **Diseño**: Figma, Piskel

---

### Reglas del Juego

1. **Inicio de Partida**: 
   - Se requieren mínimo 2 jugadores
   - Un jugador es seleccionado aleatoriamente para recibir la papa bomba

2. **Durante el Juego**:
   - El jugador con la papa debe tocar a otro jugador para transferírsela
   - Los demás jugadores deben evitar ser tocados
   - El temporizador corre constantemente (15-20 segundos)

3. **Eliminación**:
   - Cuando el temporizador llega a cero, el jugador con la papa es eliminado
   - Se inicia una nueva ronda con los jugadores restantes

4. **Victoria**:
   - El último jugador en pie gana la partida
---

## Desarrollo

### Estructura del Proyecto
```
papeados/
├── Assets/              # Recursos del juego
│   ├── Scripts/        # Código fuente
│   ├── Sprites/        # Gráficos
│   ├── Sounds/         # Audio
│   └── Scenes/         # Escenas/niveles
├── Docs/               # Documentación
│   ├── propuesta.md    # Documento de propuesta
│   ├── manual.md       # Manual de usuario
│   └── technical.md    # Documentación técnica
├── Tests/              # Pruebas unitarias
└── README.md           # Este archivo
```

### Convenciones de Código

#### Commits
Seguimos el estándar de [Conventional Commits](https://www.conventionalcommits.org/):
```
feat: nueva característica
fix: corrección de bug
docs: cambios en documentación
style: formateo, punto y coma faltante, etc.
refactor: refactorización de código
test: añadir tests
chore: actualización de tareas de build, etc.
```

Ejemplos:
```bash
git commit -m "feat: implementar sistema de colisiones"
git commit -m "fix: corregir sincronización de temporizador"
git commit -m "docs: actualizar README con instrucciones de instalación"
```

#### Nombres de Ramas
```
main              # Rama principal (código estable)
develop           # Rama de desarrollo
feature/[nombre]  # Nuevas características
fix/[nombre]      # Corrección de bugs
docs/[nombre]     # Documentación
```

Ejemplo:
```bash
git checkout -b feature/networking-basico
git checkout -b fix/collision-bug
```

### Testing
```bash
# Instrucciones para ejecutar tests
# Completar según framework de testing elegido
```

---

## Roadmap

### Fase 1: Definición del Proyecto
**21 enero - 16 febrero 2026**
- [x] Definir concepto del juego
- [x] Documentar propuesta
- [x] Asignar roles al equipo
- [x] Crear repositorio y README
- [ ] Entrega documentación Fase 1

### Fase 2: Desarrollo del Prototipo
**17 febrero - ????**
- [ ] Implementar mecánicas básicas (movimiento, colisión)
- [ ] Implementar temporizador
- [ ] Sistema de networking básico
- [ ] Interfaz de usuario mínima
- [ ] Testing multijugador

### Fase 3: Refinamiento y Entrega Final
**???? - ????**
- [ ] Optimización de red
- [ ] Arte y audio finales
- [ ] Testing exhaustivo
- [ ] Documentación completa
- [ ] Presentación del proyecto

---

## Equipo

### --------
**Rol**: Programador de Red  
**Responsabilidades**: Networking, sincronización, lobby  
[![GitHub](https://img.shields.io/badge/GitHub-Profile-blue?logo=github)](https://github.com/)

### Axel Espinosa
**Rol**: Programador de Lógica de Juego  
**Responsabilidades**: Mecánicas, colisiones, estados del juego  
[![GitHub](https://img.shields.io/badge/GitHub-Profile-blue?logo=github)](https://github.com/InozaAki)

### Bryan Julián Mendez Ambriz
**Rol**: Diseñador UI/UX y QA  
**Responsabilidades**: Interfaces, arte, testing, coordinación  
[![GitHub](https://img.shields.io/badge/GitHub-Profile-blue?logo=github)](https://github.com/Bjma1507)

---

## Contribuciones

Este es un proyecto académico, pero si tienes sugerencias o encuentras bugs, puedes:

1. Abrir un **Issue** describiendo el problema o sugerencia
2. Hacer **Fork** del proyecto
3. Crear una **rama** para tu feature (`git checkout -b feature/mejora`)
4. **Commit** tus cambios (`git commit -m 'feat: agregar mejora'`)
5. **Push** a la rama (`git push origin feature/mejora`)
6. Abrir un **Pull Request**

### Código de Conducta
- Sé respetuoso con todos los colaboradores
- Proporciona feedback constructivo
- Reporta comportamientos inapropiados

---

## Contacto

- **Repositorio**: [https://github.com/InozaAki/Papeados](https://github.com/InozaAki/Papeados)
- **Issues**: [https://github.com/InozaAki/Papeados/issues](https://github.com/InozaAki/Papeados/issues)

---
**¡Evita ser papeado!**

</div>
