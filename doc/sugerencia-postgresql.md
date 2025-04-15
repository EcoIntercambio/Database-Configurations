# Documentación de Diseño de Base de Datos - EcoIntercambio

Esta documentación describe el diseño de la base de datos utilizada en **EcoIntercambio**, una plataforma para la compra, venta e intercambio de productos entre usuarios. A continuación, se describen las tablas principales que conforman la base de datos, así como sus relaciones y campos clave.

![Preview DB](./EcoIntercambio%20Diagram.png)

---

## Tablas

### 1. `users`
La tabla `users` almacena la información básica de los usuarios de la plataforma, como su nombre, correo electrónico y región.

```sql
create table users (
  id bigint primary key generated always as identity,
  first_name text not null,
  last_name text not null,
  email text unique not null,
  password text not null,
  region text not null,
  last_login timestamptz,
  registered_at timestamptz default now()
);
```

- **id**: Identificador único del usuario.
- **first_name**: Nombre del usuario.
- **last_name**: Apellido del usuario.
- **email**: Correo electrónico único para cada usuario.
- **password**: Contraseña del usuario, almacenada de manera segura.
- **region**: Región o ubicación geográfica del usuario.
- **last_login**: Fecha y hora del último acceso del usuario.
- **registered_at**: Fecha de registro del usuario, por defecto la fecha actual.

---

### 2. `user_profiles`
La tabla `user_profiles` almacena información adicional sobre los usuarios, como su avatar, título académico, universidad, y descripción de su perfil.

```sql
create table user_profiles (
  user_id bigint primary key,
  avatar text,
  degree text,
  university text,
  profile_description text,
  language text,
  currency text,
  foreign key (user_id) references users (id)
);
```

- **user_id**: Referencia al `id` de la tabla `users`.
- **avatar**: URL de la imagen de perfil del usuario.
- **degree**: Título académico del usuario.
- **university**: Universidad de la cual el usuario se graduó.
- **profile_description**: Descripción del perfil del usuario.
- **language**: Idioma preferido del usuario.
- **currency**: Moneda preferida para transacciones.

---

### 3. `products`
La tabla `products` contiene la información sobre los productos publicados por los usuarios, incluyendo el nombre, descripción, ubicación y tipo de transacción.

```sql
create table products (
  id bigint primary key generated always as identity,
  user_id bigint not null,
  name text not null,
  description text not null,
  location text not null,
  type text check (type in ('trade', 'sale', 'both')) not null,
  created_at timestamptz default now(),
  status text check (status in ('published', 'unpublished')) not null,
  price numeric,
  foreign key (user_id) references users (id)
);
```

- **id**: Identificador único del producto.
- **user_id**: Referencia al `id` de la tabla `users` (quién publica el producto).
- **name**: Nombre del producto.
- **description**: Descripción detallada del producto.
- **location**: Ubicación del producto.
- **type**: Tipo de transacción: 'trade' (intercambio), 'sale' (venta), o 'both' (intercambio o venta).
- **created_at**: Fecha de creación del producto.
- **status**: Estado del producto: 'published' o 'unpublished'.
- **price**: Precio del producto (solo aplicable si el tipo es 'sale').

---

### 4. `product_images`
La tabla `product_images` almacena las imágenes asociadas a cada producto.

```sql
create table product_images (
  id bigint primary key generated always as identity,
  product_id bigint not null,
  image_url text not null,
  foreign key (product_id) references products (id)
);
```

- **id**: Identificador único de la imagen.
- **product_id**: Referencia al `id` de la tabla `products`.
- **image_url**: URL de la imagen del producto.

---

### 5. `product_tags`
La tabla `product_tags` permite etiquetar productos con palabras clave para facilitar la búsqueda y clasificación.

```sql
create table product_tags (
  id bigint primary key generated always as identity,
  product_id bigint not null,
  tag text not null,
  foreign key (product_id) references products (id)
);
```

- **id**: Identificador único de la etiqueta.
- **product_id**: Referencia al `id` de la tabla `products`.
- **tag**: Etiqueta asociada al producto.

---

### 6. `chats`
La tabla `chats` gestiona las conversaciones entre dos usuarios sobre productos.

```sql
create table chats (
  id bigint primary key generated always as identity,
  user1_id bigint not null,
  user2_id bigint not null,
  foreign key (user1_id) references users (id),
  foreign key (user2_id) references users (id)
);
```

- **id**: Identificador único de la conversación.
- **user1_id** y **user2_id**: Referencias a los usuarios que participan en la conversación.

---

### 7. `chat_messages`
La tabla `chat_messages` almacena los mensajes enviados dentro de las conversaciones.

```sql
create table chat_messages (
  id bigint primary key generated always as identity,
  chat_id bigint not null,
  sender_id bigint not null,
  message text not null,
  sent_at timestamptz default now(),
  foreign key (chat_id) references chats (id),
  foreign key (sender_id) references users (id)
);
```

- **id**: Identificador único del mensaje.
- **chat_id**: Referencia al `id` de la tabla `chats`.
- **sender_id**: Referencia al `id` del usuario que envía el mensaje.
- **message**: Contenido del mensaje.
- **sent_at**: Fecha y hora en la que se envió el mensaje.

---

### 8. `notifications`
La tabla `notifications` almacena las notificaciones enviadas a los usuarios.

```sql
create table notifications (
  id bigint primary key generated always as identity,
  user_id bigint not null,
  message text not null,
  created_at timestamptz default now(),
  foreign key (user_id) references users (id)
);
```

- **id**: Identificador único de la notificación.
- **user_id**: Referencia al `id` de la tabla `users`.
- **message**: Contenido de la notificación.
- **created_at**: Fecha y hora de creación de la notificación.

---

### 9. `contacts`
La tabla `contacts` gestiona las relaciones de contacto entre usuarios.

```sql
create table contacts (
  user_id bigint not null,
  contact_id bigint not null,
  primary key (user_id, contact_id),
  foreign key (user_id) references users (id),
  foreign key (contact_id) references users (id)
);
```

- **user_id** y **contact_id**: Referencias a los usuarios en una relación de contacto.

---

### 10. `favorite_products`
La tabla `favorite_products` almacena los productos que los usuarios han marcado como favoritos.

```sql
create table favorite_products (
  user_id bigint not null,
  product_id bigint not null,
  primary key (user_id, product_id),
  foreign key (user_id) references users (id),
  foreign key (product_id) references products (id)
);
```

- **user_id**: Referencia al `id` de la tabla `users`.
- **product_id**: Referencia al `id` de la tabla `products`.

---

## Relaciones

- **Usuarios** pueden tener múltiples productos (relación uno a muchos entre `users` y `products`).
- **Productos** pueden tener múltiples imágenes y etiquetas (relaciones uno a muchos entre `products` y `product_images`, `products` y `product_tags`).
- **Usuarios** pueden tener múltiples contactos y conversaciones (relación muchos a muchos en `contacts` y relación uno a muchos entre `users` y `chats`).
- **Usuarios** pueden tener productos favoritos (relación muchos a muchos entre `users` y `products` en la tabla `favorite_products`).

---

## Notas

- **Integridad referencial**: Se asegura que todas las referencias entre tablas sean válidas mediante claves foráneas.
- **Tipo de datos**: Se utilizan tipos de datos adecuados para cada campo, como `text` para cadenas de texto y `timestamptz` para fechas y horas.
- **Optimización**: Se deben considerar índices adicionales en columnas que se consultan con frecuencia, como `email` en la tabla `users` o `product_id` en `favorite_products`.

---

Este es el diseño propuesto para la base de datos de **EcoIntercambio**, diseñado para soportar la funcionalidad y escalabilidad de la aplicación mientras mantiene la integridad de los datos.