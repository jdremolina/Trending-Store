# Trending Store · Inventario

App web del inventario de **Trending Store** (Caucasia, Antioquia): lotes traídos de Estados Unidos, inventario con fotos, ventas de contado o con abonos, facturas, caja y reportes por mes y por año.

- Funciona en el navegador del celular y del computador, y se puede instalar como app.
- Todo se sincroniza en vivo entre tú y tus socios.
- Cada persona entra con su propio correo y contraseña.
- Si se va el internet, muestra la última copia guardada en el dispositivo.

La app está publicada con **GitHub Pages**. Los datos y las fotos se guardan en **Supabase**.

---

## Puesta en marcha (una sola vez)

### 1. Preparar la base de datos en Supabase
1. Entra a tu proyecto en [supabase.com](https://supabase.com/dashboard).
2. En el menú de la izquierda abre **SQL Editor** → **New query**.
3. Copia todo el contenido del archivo [`supabase.sql`](supabase.sql), pégalo y toca **Run**. Debe decir *Success*.

### 2. Cerrar el registro público (importante)
Así nadie puede crearse una cuenta por su cuenta y ver tus datos.
1. **Authentication** → **Sign In / Providers** (o **Providers → Email**).
2. Apaga **Allow new users to sign up** y guarda.

### 3. Crear los usuarios (tú y tus socios)
1. **Authentication** → **Users** → **Add user** → **Create new user**.
2. Escribe el correo y una contraseña, y marca **Auto Confirm User**.
3. Repite para cada socio y pásale su correo y contraseña.

### 4. Para que funcione "Olvidé mi contraseña"
1. **Authentication** → **URL Configuration**.
2. En **Site URL** pon: `https://jdremolina.github.io/Trending-Store/`
3. En **Redirect URLs** agrega esa misma dirección.

### 5. Activar GitHub Pages
1. En este repositorio: **Settings** → **Pages**.
2. En **Source** elige **Deploy from a branch**; **Branch:** `main`, carpeta `/ (root)` → **Save**.
3. En 1 o 2 minutos la app queda en: **https://jdremolina.github.io/Trending-Store/**

### 6. Traer tus datos
Entra a la app → en **Inventario** o **Ajustes** toca **Importar archivo .json** y sube el archivo de lotes de tu Excel o la copia de seguridad de la versión anterior.

---

## Instalarla en el celular
- **Android (Chrome):** menú ⋮ → *Agregar a la pantalla principal* / *Instalar app*.
- **iPhone (Safari):** botón Compartir → *Agregar a inicio*.

## Archivos
| Archivo | Para qué sirve |
|---|---|
| `index.html` | La app completa |
| `config.js` | Dirección de Supabase y clave **pública** (publishable) |
| `supabase.sql` | Tabla, seguridad, tiempo real y fotos en Supabase |
| `sw.js`, `manifest.webmanifest`, `icon-*.png` | Instalación en el celular y uso sin internet |

> **Seguridad:** la clave de `config.js` es pública por diseño; lo que protege tus datos son las reglas de `supabase.sql` (solo usuarios con sesión pueden leer o escribir) y tener el registro público apagado. Nunca subas aquí la clave secreta (`sb_secret_…` o `service_role`) ni archivos con datos de clientes.
