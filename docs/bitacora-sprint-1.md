# Bitácora Sprint 1

### **Carga de variables**

Debido a que es una mala práctica añadir el archivo `.env` al repositorio remoto, entonces se crea el archivo `docs/.env.example`, lo cual ayudará a los miembros del grupo (o personas externas) a tener una ídea del formato que debe tener el archivo `.env` para este proyecto.

Simplemente se devería ejecutar en la raiz del proyecto:

```bash
cp docs/.env.example .env
```
Ahora, en el nuevo archivo `.env`, modificar las variables con los valores correctos para su uso.

Para cargar los valores de entorno, se debe ejecutar el script `cargar_env.sh`, ubicado en el directorio `src`:

```bash
source src/cargar_env.sh
```

Y para verificar que las variables se cargaron éxitosamente, se debe ejecutar el script `mostrar_env.sh`, ubicado en el directorio `src` (dar permisos de ejecución previamente):

```bash
./src/mostrar_env.sh
```
