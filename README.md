**Crossy Pinkie Road**

Crossy Pinkie Road es un juego de habilidad y arcade desarrollado en Godot Engine 4.6. Inspirado en la mecánica clásica de Crossy Road, este proyecto traslada la experiencia a un mundo colorido y dinámico donde acompañamos a Pinkie Pie en su aventura de recolección de manzanas.

Desarrollado por Carlos Nava Rodríguez (@NavaRods) estudiante de Ingeniería en Computación dentro de la Universidad de Guadalajara (UDG) del Centro Universitario de Ciencias Exactas e Ingenierías (CUCEI), para la materia de Programacion de Graficos 3D usando el Motor de Desarrollo de Videojuegos Godot Engine 4.6, materia impartida por Jose Luis David Bonilla Carranza.

Imagenes del Juego

<img width="1269" height="710" alt="image" src="https://github.com/user-attachments/assets/e136e944-6e65-4be2-b25b-b22d39f199ee" />

<img width="1271" height="718" alt="image" src="https://github.com/user-attachments/assets/d428d6e4-6f45-4ab2-8dd3-756afbf0710d" />

<img width="1275" height="714" alt="image" src="https://github.com/user-attachments/assets/c8d994e1-9a74-4eff-981e-fe67da0c4720" />

<img width="1274" height="715" alt="image" src="https://github.com/user-attachments/assets/a46eb1d3-9d95-4705-ab6e-5d4b32472bae" />

<img width="1278" height="709" alt="image" src="https://github.com/user-attachments/assets/3a233426-1900-4909-aecf-5c5ebd786e64" />

<img width="1271" height="710" alt="image" src="https://github.com/user-attachments/assets/4a283fe5-36b8-4ffd-a2c4-a1f41538f94b" />

<img width="1066" height="612" alt="image" src="https://github.com/user-attachments/assets/34eb7230-5aa0-4b3c-b853-7a9475cbb2eb" />

<img width="1905" height="981" alt="image" src="https://github.com/user-attachments/assets/aa15ebe9-0452-4ac0-9a6c-9a26948d2af7" />


Controles y Dinámica
El objetivo es llegar lo más lejos posible evitando obstáculos, vehículos y caídas al agua.

Movimiento: Utiliza las Flechas de Dirección o las teclas WASD.

Dinámica: El personaje se desplaza sobre una rejilla técnica. Cada salto adelante suma metros a tu puntuación.

Coleccionables: Recolecta manzanas para aumentar tu contador personal. Estos datos se guardan de forma permanente en tu perfil.

>[!NOTE]
>Ciclos Horarios: El sistema de iluminación y el ciclo de día/noche están sincronizados en tiempo real con el horario de la Ciudad de México mediante la integración de TimeAPI.

>[!NOTE]
>Uso de Manzanas: Actualmente, las manzanas funcionan como un contador de progreso guardado en la base de datos. En futuras actualizaciones, se planea implementar una tienda para desbloquear nuevos personajes utilizando estas manzanas como moneda de cambio.

**Base de Datos Local (SQLite)**

El juego gestiona la persistencia de datos mediante SQLite, lo que permite una administración robusta de la información:

Perfiles de Usuario: Registro de múltiples nombres de usuario con sus propias estadísticas.

- Persistencia: Guarda el récord de distancia (High Score) y el total acumulado de manzanas.

- Sincronización: Al iniciar sesión o cambiar de usuario, el juego recupera automáticamente los datos desde el archivo .db.

**Integración de API**

El juego utiliza una conexión HTTP para determinar la iluminación del entorno:

API: TimeAPI.io

Efecto: Dependiendo de la hora actual en CDMX, el juego transiciona visualmente entre mañana, mediodía, tarde y noche, afectando las luces ambientales (DirectionalLight3D) y activando las luces del personaje y vehículos durante la noche.

**Créditos y Recursos**

Creación Original y Propiedad Intelectual

Mecánica de Juego: Inspirada en el concepto original de Crossy Road (Hipster Whale).

Personaje: Pinkie Pie es un personaje propiedad de Hasbro (My Little Pony). Este es un proyecto de carácter académico y fan-art.

**Modelado 3D y Arte**

Personaje Pinkie Pie: Modelado y configurado desde cero en Blender bajo el estilo Voxel Art por Carlos Nava Rodríguez (@NavaRoads).

Coleccionables (Manzana): Creadas en Blender por Carlos Nava Rodríguez (@NavaRoads).

Arte creado por Carlos Nava Rodríguez (@NavaRoads).


Entorno y NPCs (Vehículos/Assets): Se utilizaron kits de alta calidad de Kenney.nl:

- Car Kit: https://kenney.nl/assets/car-kit

- Pirate Kit: https://kenney.nl/assets/pirate-kit

- Graveyard Kit: https://kenney.nl/assets/graveyard-kit

- Survival Kit: https://kenney.nl/assets/survival-kit

Audio y Efectos de Sonido
Los sonidos han sido seleccionados y editados desde las siguientes plataformas:

- OpenGameArt.org: https://opengameart.org/

- Sound Ideas: https://soundideas.sourceaudio.com/albums

- Pixabay Sound Effects: https://pixabay.com/es/sound-effects/
