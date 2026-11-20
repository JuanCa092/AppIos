# MindCare 💙

App iOS de bienestar emocional. Ofrece un acompañante con IA (Gemini), ejercicios de respiración, un registro diario del ánimo y acceso rápido a una línea de ayuda en caso de crisis.

> MindCare es un acompañante de bienestar y **no reemplaza la atención de un profesional de la salud mental**.

## Funcionalidades

- **Login simple**: el usuario ingresa su nombre y entra.
- **Registro de ánimo**: calificación de 1 a 5 estrellas con un emoji que cambia según la nota. Si la calificación es baja (1 o 2), la app ofrece un ejercicio o hablar con el chat.
- **Ejercicios de respiración** guiados con un círculo animado:
  - Contra la ansiedad: 4-7-8
  - Contra los nervios: respiración cuadrada 4-4-4-4
  - Para calmar la ira: exhalación larga 4-6
- **Chat con Gemini**: conversación con memoria del historial. Detecta palabras de riesgo y muestra un banner rojo hacia la ayuda urgente, independientemente de lo que responda la IA.
- **Ayuda urgente**: abre el marcador del teléfono con el **113** (línea de ayuda de Perú) ya marcado.
- **Diario**: bloc de notas (crear, editar, borrar) y mini tareas diarias que se reinician cada día, al estilo Duolingo.
- **Perfil y ajustes**: cambiar nombre, resumen del ánimo, recordatorio diario a las 8:00 pm, borrar historial o cerrar sesión.

## Flujo de pantallas

```
Login → Welcome → Home ─┬─ Ejercicios
                        ├─ Chat con Gemini
                        ├─ Ayuda urgente (113)
                        └─ Ver más ─┬─ Diario (notas y mini tareas)
                                    └─ Perfil y ajustes
```

## Estructura del proyecto

```
MindCare/
├── Controllers/
│   ├── LoginViewController.swift
│   ├── WelcomeViewController.swift
│   ├── HomeViewController.swift
│   ├── ExercisesViewController.swift
│   ├── ChatViewController.swift
│   ├── EmergencyViewController.swift
│   ├── DiaryViewController.swift
│   └── ProfileViewController.swift
├── Models/
│   ├── User.swift
│   ├── Emotion.swift
│   └── DiaryItems.swift        (Note y TaskItem)
└── Services/
    ├── GeminiService.swift     (API de Gemini)
    └── StorageService.swift    (persistencia con UserDefaults)
```

## Tecnologías

- Swift y **UIKit** (interfaz 100 % programática, sin storyboard)
- iOS 15.0 o superior
- API de Google Gemini
- `UserDefaults` para guardar datos localmente
- `UserNotifications` para el recordatorio diario

## Cómo compilar

**Requisitos:** una Mac con Xcode, un Apple ID y, para probar el 113 y las notificaciones, un iPhone real.

1. En Xcode: *File → New → Project → iOS → App* (nombre `MindCare`, Swift, Storyboard).
2. En *General*, fijar **Minimum Deployments** en iOS 15.0 o superior.
3. Arrastrar las carpetas `Controllers`, `Models` y `Services` al proyecto (marcar *Copy items if needed* y el target `MindCare`).
4. Quitar el storyboard: borrar `Main.storyboard`, eliminar la fila *Storyboard Name* del `Info.plist` y vaciar *UIKit Main Storyboard File Base Name* en *Build Settings*.
5. En `SceneDelegate.swift`, arrancar con `LoginViewController` dentro de un `UINavigationController`.
6. Pegar la API key en `Services/GeminiService.swift` (se obtiene gratis en Google AI Studio).
7. Elegir un simulador o iPhone y pulsar **Run** (⌘R).

## Notas importantes

- **API key**: no subirla a un repositorio público. Para publicar la app, lo recomendable es guardarla en un backend propio.
- **Modelo de Gemini**: si el chat da error 404, revisar que el nombre del modelo en `GeminiService.swift` siga vigente.
- **Línea de ayuda**: el 113 corresponde a Perú. Para otro país hay que cambiar la constante en `EmergencyViewController`.
- **Simulador**: no puede hacer llamadas, así que el 113 solo se prueba en un iPhone real.
- **Datos**: se guardan solo en el dispositivo; no hay cuentas ni servidor.

## Posibles mejoras

- Entrar directo al Home si ya hay un usuario guardado.
- Gráfico del historial de ánimo en el perfil.
- Pantalla de notas más completa con `UITextView`.
- Backend para proteger la API key.