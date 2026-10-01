# Reproductor iPod Classic Nativo para iPhone 4 (iOS 6)

Este proyecto transforma un **iPhone 4** (o dispositivo iOS legacy con iOS 6 / 7) en un **reproductor iPod Classic funcional** con su icónica rueda táctil (*Click Wheel*).

---

## 📱 Características principales

- **Diseño clásico iPod Classic**: Pantalla retro LCD con cabecera de batería/reproducción, menús organizados (Música, Artistas, Álbumes, Canciones, Reproduciendo, Ajustes) y carátula de álbum.
- **Click Wheel táctil sensitiva**:
  - Detección de giro circular (sentido horario y antihorario) usando matemáticas de ángulos (`atan2f`).
  - Sonido de "click" mecánico auditivo al girar la rueda y presionar botones.
  - Botones dedicados: **MENU**, **SIGUIENTE (⏩)**, **ANTERIOR (⏪)**, **PLAY/PAUSE (⏯)** y **BOTÓN CENTRAL (SELECT)**.
- **Integración con Biblioteca Musical de iOS**:
  - Accede directamente a la biblioteca de música de la app *Música* del iPhone 4 (`MPMediaQuery` / `MPMediaProperty`).
  - También soporta reproducción de canciones locales guardadas en el bundle/documentos.
- **Reproducción en segundo plano**:
  - Mantiene la música sonando al apagar la pantalla o cambiar de pantalla gracias a `AVAudioSessionCategoryPlayback`.

---

## 📂 Estructura del Proyecto

```
ipod-classic-ios6/
├── iPodClassiciOS6.xcodeproj/   # Proyecto de Xcode listo para compilar
│   └── project.pbxproj
├── iPodClassiciOS6/             # Código fuente nativo en Objective-C (iOS 6 SDK / armv7)
│   ├── main.m
│   ├── AppDelegate.h / .m
│   ├── ViewController.h / .m
│   ├── ClickWheelView.h / .m     # Control de gestos giratorios de la rueda
│   ├── iPodDisplayView.h / .m   # Renderizado de pantalla LCD del iPod
│   ├── MusicLibraryManager.h / .m # Gestor de audio y biblioteca musical
│   └── Info.plist
├── web_version/                 # Versión Web/PWA de prueba inmediata
│   ├── index.html
│   ├── style.css
│   └── app.js
└── GUIA_INSTALACION.md          # Pasos detallados para instalar en iPhone 4
```

---

## 🛠️ Requisitos e Instalación

Consulta la **[GUIA_INSTALACION.md](file:///c:/Proyectos/ipod-classic-ios6/GUIA_INSTALACION.md)** para ver la guía paso a paso sobre cómo:
1. Compilar el archivo `.ipa` nativo con Xcode o Xcode Command Line Tools.
2. Instalar el `.ipa` en tu iPhone 4 usando **Sideloadly**, **3uTools** o **AppSync** (si tiene Jailbreak).
3. Usar la versión Web interactiva como alternativa sin compilar.
