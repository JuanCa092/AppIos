cosas para ejecutar
Una Mac (MacBook, iMac o Mac mini)	Xcode solo corre en macOS. Si no tiene Mac, puede alquilar una en la nube (MacinCloud, por ejemplo), pero es más lento e incómodo	–
Xcode (Mac App Store)	Compilar, simulador y firma de la app	Gratis
Apple ID	Firmar la app para probarla en su iPhone	Gratis
iPhone real + cable	Probar el 113 y las notificaciones	–
Clave de Gemini (Google AI Studio)	Que funcione el chat	Gratis con límites
La versión de Xcode que pueda instalar depende de la versión de macOS de su Mac. Que revise eso primero, porque Xcode pesa varios GB y tarda en descargarse.

Pasos

1. Crear el proyecto
Xcode → File → New → Project → iOS → App. Product Name: MindCare, Interface: Storyboard, Language: Swift. Luego en el proyecto, pestaña General, pone Minimum Deployments en iOS 15.0 o superior.

2. Pasar los archivos
Los escribes en VS Code y los mandan por GitHub, USB o zip. En Xcode los arrastran al proyecto marcando “Copy items if needed” y que el target MindCare esté seleccionado. Si usan carpetas (Controllers, Models, Services), que las creen como groups.

3. Quitar el storyboard

Borrar Main.storyboard (Move to Trash).
En Info.plist, dentro de Application Scene Manifest → Scene Configuration → Application Session Role → Item 0, borrar la fila Storyboard Name.
En Build Settings, buscar UIKit Main Storyboard File Base Name y dejarlo vacío.

4. Poner el arranque en SceneDelegate.swift
Reemplazar scene(_:willConnectTo:options:) por el código que te di al inicio:

swift
guard let windowScene = scene as? UIWindowScene else { return }
window = UIWindow(windowScene: windowScene)
window?.rootViewController = UINavigationController(rootViewController: LoginViewController())
window?.makeKeyAndVisible()

5. Poner la API key
En GeminiService.swift, reemplazar "TU_API_KEY". Que no suban la clave a GitHub; si el repo es público, mejor tenerla en un archivo aparte incluido en .gitignore.

6. Probar en el simulador
Elegir un iPhone en la barra superior y pulsar ▶ Run (⌘R). Sirve para ver el flujo, el chat y los ejercicios. El botón del 113 no marcará en el simulador.

7. Probar en un iPhone real

Conectar el iPhone y confiar en la Mac.
En el iPhone: Ajustes → Privacidad y seguridad → Modo de desarrollador → activar (reinicia).
En Xcode: proyecto → Signing & Capabilities → marcar Automatically manage signing y elegir su Apple ID en Team.
Seleccionar el iPhone como destino y pulsar Run.
La primera vez, en el iPhone: Ajustes → General → VPN y gestión de dispositivos → confiar en el desarrollador.

Con Apple ID gratuito, la app caduca a los 7 días y hay que volver a instalarla desde Xcode. Con el programa de pago dura más y se puede distribuir.

Errores comunes la primera vez
“Cannot find ‘XViewController’ in scope”: el archivo no tiene marcado el target. Se arregla en el panel derecho, Target Membership.
Pantalla negra al abrir: quedó la referencia al storyboard en el Info.plist o en Build Settings.
Error 404 o 400 en el chat: nombre del modelo desactualizado o clave mal copiada.
keyboardLayoutGuide no existe: el deployment target está por debajo de iOS 15.