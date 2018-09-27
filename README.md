# iTunesSearchBasic

### Proyecto de Prueba basado en el iTunes Search API

Se ha hecho en `Swift 4.2` y en `Xcode 10`. La funcionalidad solicitada fue:

* Mostrar resultados con paginación (20 ítems por página).
* Seleccionar un ítem de la búsqueda y mostrar el álbum al que pertenece incluyendo:
   * Arte de 100x100.
   * Nombre del álbum.
   * Nombre de la banda.
   * Lista de canciones.
* Para el álbum, ser capaz de consumir y visualizar el preview de las canciones.
* Almacenar localmente las búsquedas realizadas y ofrecer repetirlas en caso de no tener conexión a internet.
* Manejar errores 500, “término no encontrado”, INET_CONN_ERROR.
* Usar animaciones y transiciones entre vistas.
* Usar Auto Layout.

### Avance

Se avanzó con toda la funcionalidad solicitada excepto la persistencia de los últimos 5 resultados de búsqueda.

### A tomar en cuenta

Se seleccionó usar una arquitectura MVP lo suficientemente sencilla que nos permita hacer los Unit Test solicitados y de acorde
a la complejidad de la App.

Se optó por usar Storyboards en vez de xibs por ser vistas sencillas.

La persistencia local se dejó al final.  Para tal efecto, una solución sería añadir un modelo básico de CoreData para persistir los 
últimos 5 términos de busqueda y la primera página de resultados.  Se tendría que cambiar el SearchMusicViewController para 
presentar una tabla con los últimos 5 resultados y en base a la selección, pintar la tableview y ajustar la lógica del searchBar.

Se hizo una animación sencilla para la transición de las vistas
