defmodule Twitter.Tweets.Policies do
  alias Twitter.Tweets.Tweet
  alias Twitter.Users.User

  def list(%User{} = user, _), do: {:ok, user}
  def list(_, _), do: {:ok, nil}

  def show(%User{} = user, _), do: {:ok, user}
  def show(_, _), do: {:ok, nil}

  def create(%User{} = user, _), do: {:ok, user}
  def create(_, _), do: {:error, :forbidden}

  def update(%User{id: id} = user, %Tweet{author_id: id}), do: {:ok, user}
  def update(_, _), do: {:error, :forbidden}

  def delete(%User{id: id} = user, %Tweet{author_id: id}), do: {:ok, user}
  def delete(_, _), do: {:error, :forbidden}

  def like(%User{} = user, _), do: {:ok, user}
  def like(_, _), do: {:error, :forbidden}

  def unlike(%User{} = user, _), do: {:ok, user}
  def unlike(_, _), do: {:error, :forbidden}

  def reply(%User{} = user, _), do: {:ok, user}
  def reply(_, _), do: {:error, :forbidden}
end
