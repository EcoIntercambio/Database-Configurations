-- Migrations will appear here as you chat with AI

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

create table product_images (
  id bigint primary key generated always as identity,
  product_id bigint not null,
  image_url text not null,
  foreign key (product_id) references products (id)
);

create table product_tags (
  id bigint primary key generated always as identity,
  product_id bigint not null,
  tag text not null,
  foreign key (product_id) references products (id)
);

create table chats (
  id bigint primary key generated always as identity,
  user1_id bigint not null,
  user2_id bigint not null,
  foreign key (user1_id) references users (id),
  foreign key (user2_id) references users (id)
);

create table chat_messages (
  id bigint primary key generated always as identity,
  chat_id bigint not null,
  sender_id bigint not null,
  message text not null,
  sent_at timestamptz default now(),
  foreign key (chat_id) references chats (id),
  foreign key (sender_id) references users (id)
);

create table notifications (
  id bigint primary key generated always as identity,
  user_id bigint not null,
  message text not null,
  created_at timestamptz default now(),
  foreign key (user_id) references users (id)
);

create table contacts (
  user_id bigint not null,
  contact_id bigint not null,
  primary key (user_id, contact_id),
  foreign key (user_id) references users (id),
  foreign key (contact_id) references users (id)
);

create table favorite_products (
  user_id bigint not null,
  product_id bigint not null,
  primary key (user_id, product_id),
  foreign key (user_id) references users (id),
  foreign key (product_id) references products (id)
);