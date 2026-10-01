# Guía de Instalación del Reproductor iPod Classic en iPhone 4 (iOS 6)

¡Hola! Has seleccionado la **aplicación nativa en Objective-C** para tu iPhone 4 con iOS 6. A continuación dispones de las instrucciones paso a paso para compilar e instalar la app nativa en tu dispositivo, así como la alternativa web rápida.

---

## 🛠️ Método 1: Compilar e Instalar el Archivo Nativo `.ipa`

### Requisitos:
1. **Tu iPhone 4** conectado por cable USB al PC o Mac.
2. Un programa para transferir/firmar la app (por ejemplo, **Sideloadly**, **3uTools** o **AltStore/Cydia Impactor**).
3. (Opcional si tienes Jailbreak): El tweak **AppSync Unified** de Cydia instalado en el iPhone 4 para permitir instalar cualquier `.ipa` sin firmar.

### Pasos para compilar en Xcode (si tienes Mac):
1. Abre la carpeta `ipod-classic-ios6` en tu Mac.
2. Haz doble clic en `iPodClassiciOS6.xcodeproj` para abrir el proyecto en **Xcode**.
3. Selecciona el objetivo **iOS Device** o tu iPhone 4 conectado por USB.
4. En la configuración del proyecto:
   - **Deployment Target**: Selecciona `6.0` o `6.1`.
   - **Architecture**: Asegúrate de incluir `armv7` (la arquitectura de 32 bits del chip Apple A4 del iPhone 4).
5. Ve al menú superior **Product > Archive** (o **Product > Build**).
6. Exporta el paquete binario como **`.ipa`** (o busca el archivo `.app` generado en Build/Products y mételo en una carpeta `Payload` para comprimirla como `.zip` y renombrarla a `.ipa`).

### Pasos para instalar el `.ipa` en el iPhone 4 con Sideloadly (Windows/Mac):
1. Descarga e instala **Sideloadly** ([sideloadly.io](https://sideloadly.io/)) en tu ordenador.
2. Conecta tu iPhone 4 por cable USB al ordenador y abre Sideloadly.
3. Arrastra el archivo `iPodClassiciOS6.ipa` a la ventana de Sideloadly.
4. Introduce tu Apple ID (correo) para firmar la aplicación de forma gratuita.
5. Haz clic en **Start**. ¡En unos segundos la app del iPod Classic aparecerá en la pantalla de inicio de tu iPhone 4!

### Pasos si tu iPhone 4 tiene Jailbreak (el método más fácil):
1. Abre **Cydia** en tu iPhone 4.
2. Añade la fuente de Karen/Akemi: `https://cydia.akemi.ai/` e instala **AppSync Unified**.
3. Abre **3uTools** (en Windows) con tu iPhone 4 conectado por USB.
4. Ve a la pestaña **Apps > Install IPA** y selecciona el archivo `.ipa`. AppSync permitirá que se instale al instante sin caducidad.

---

## 🌐 Método 2: Usar la Versión Web en Safari de iOS 6 (Sin necesidad de compilar)

Si quieres probar la interfaz de forma inmediata o usarla mientras compilas la versión nativa:

1. Abre la consola / terminal en tu ordenador en la carpeta `ipod-classic-ios6/web_version`.
2. Ejecuta el servidor local:
   ```bash
   python -m http.server 8000
   ```
3. Conecta tu iPhone 4 a la misma red WiFi que tu ordenador.
4. Abre **Safari** en tu iPhone 4 y navega a la dirección IP de tu PC:
   `http://192.168.X.X:8000` (reemplaza por la IP local de tu ordenador).
5. En Safari del iPhone 4, pulsa el botón del medio de la barra inferior (el icono de compartir/flecha) y selecciona **"Añadir a pantalla de inicio"** (*Add to Home Screen*).
6. Se creará un icono llamado **iPod** en tu pantalla de inicio que abrirá la aplicación a **pantalla completa** idéntica al iPod original.

---

## 🎵 ¿Cómo funciona la música en el reproductor?

- **En la App Nativa**: Accede a las canciones que hayas sincronizado con iTunes en tu iPhone 4 mediante la API `MPMediaQuery`. También permite reproducir música en segundo plano cuando bloqueas la pantalla.
- **En la App Web**: Puedes subir/seleccionar archivos MP3 o usar la lista de demostración preconfigurada.
- **Rueda Click Wheel**:
  - Gira el dedo en círculo sobre la rueda para navegar hacia arriba o abajo en los menús.
  - Al girar o presionar los botones, escucharás el característico sonido mecánico del iPod original.
