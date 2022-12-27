# Twitter-like Elixir Phoenix API application

## Installation

- [Install Elixir](https://elixir-lang.org/install.html)
- Install Postgres
- Clone this repository: `git clone https://gitub.com/florius0/twitter.git`
- Install dependencies with `mix deps.get`
- Configure postgres if needed in `config/dev.exs`, `config/test.exs` and `config/prod.exs`
- Run `mix ecto.setup` to create the database and run migrations
- Run `mix test` to run the tests
- Run `mix phx.server` to start the server

## Usage

### Entities

#### 1. User

```ts
{
  id: uuid,
  username: string,
  tweets: Tweet[] | null,
  likes: Tweet[] | null,
  followers: User[] | null,
  followees: User[] | null,
  created_at: Date,
  updated_at: Date
}
```

#### 2. Tweet

```ts
{
  id: uuid,
  text: string,
  author: User | null,
  reply_to: Tweet | null,
  replies: Tweet[] | null,
  likes: User[] | null,
  created_at: Date,
  updated_at: Date
}
```

### Endpoints

#### 1. Tweets

- `GET api/tweets` - get all tweets. Includes author, one-level replies, likes
- `GET api/tweets/:id` - get a tweet by id. Includes author, all replies (replies of replies etc), likes
- `POST api/tweets` - create a tweet with body `{tweet: { text: string}}`. Returns the created tweet
- `POST api/tweets/:id/reply` - create a reply to a tweet with body `{tweet: { text: string}}`. Returns the created tweet
- `DELETE api/tweets/:id` - delete a tweet. Returns the deleted tweet. Only the author can delete the tweet
- `PATCH | PUT api/tweets/:id` - update a tweet with body `{tweet: { text: string}}`. Returns the updated tweet. Only the author can update the tweet
- `POST api/tweets/:id/like` - like a tweet. Returns the liked tweet
- `DELETE api/tweets/:id/like` - unlike a tweet. Returns the unliked tweet.

#### 2. Users

- `GET api/users` - get all users. Includes tweets, likes, followers, followees
- `GET api/users/:id` - get a user by id. Includes tweets, likes, followers, followees
- `GET api/users/:id/tweets` - get all tweets of a user. Includes author, one-level replies, likes
- `GET api/users/:id/likes` - get all liked tweets of a user. Includes author, one-level replies, likes. Only the user can get his likes
- `GET api/users/:id/feed` - get all tweets the users he follows. Includes author, one-level replies, likes
- `POST api/users` - create a user with body `{user: { username: string, password: string, password_confirmation: string}}`. Returns the created user
- `PATCH | PUT api/users/:id` - update a user with body `{user: { username: string, password: string, password_confirmation: string}}`. Returns the updated user. Only the user can update his account
- `DELETE api/users/:id` - delete a user. Returns the deleted user. Only the user can delete his account
- `POST api/users/:id/follow` - follow a user. Returns the followed user
- `DELETE api/users/:id/follow` - unfollow a user. Returns the unfollowed user

### Authentication

- `POST api/session` - login with body `{user: { username: string, password: string}}`. Returns the logged in user
- `DELETE api/session` - logout

Note that all endpoints except `POST api/users` and `POST | DELETE api/session` require authentication.