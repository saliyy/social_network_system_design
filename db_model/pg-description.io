Table db_users.users {
  id integer [primary key]
  username varchar
  mail varchar
  password text
  created_at timestamp
  updated_at timestamp
}

Table db_posts.posts {
  id integer [primary key]
  user_id integer
  title text
  content text
  created_at timestamp
  updated_at timestamp
}

Table db_media.media {
    id integer [primary key]
    media_id integer
    media_type varchar # like comment, post, other...
    uri text
    type varchar
    created_at timestamp
      
    Indexes {
     (imageable_id, imageable_type) [pk]
  }
}

Table db_places.places {
    id serial [primary key]
    name string
    longitude decimal(9,6) [not null]
    latitude decimal(9,6) [not null]
}

Table db_comments.comments {
  id integer [primary key]
  post_id integer
  user_id integer
  parent_id integer
  reply_id integer
  text varchar
  created_at timestamp
  updated_at timestamp
}

Table db_ratings.ratings {
  post_id integer
  user_id integer
  value int8
  created_at timestamp

  Indexes {
    (post_id, user_id) [pk]
  }
}

Table db_subscriptions.subscriptions {
  follower_id integer
  followed_id integer
  created_at timestamp

  Indexes {
    (follower_id, followed_id) [pk]
  }
}

Ref: db_posts.posts.user_id > db_users.users.id
Ref: db_posts.posts.place_id > db_places.places.id

Ref: db_comments.comments.parent_id > db_comments.comments.id
Ref: db_comments.comments.post_id > db_posts.posts.id
Ref: db_comments.comments.user_id > db_users.users.id

Ref: db_ratings.ratings.post_id > db_posts.posts.id
Ref: db_ratings.ratings.user_id > db_users.users.id

Ref: db_subscriptions.subscriptions.follower_id > db_users.users.id
Ref: db_subscriptions.subscriptions.followed_id > db_users.users.id

Ref: db_posts.posts.place_id > db_places.places.id