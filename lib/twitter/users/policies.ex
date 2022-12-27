defmodule Twitter.Users.Policies do
  alias Twitter.Users.User

  def list(%User{} = user, _), do: {:ok, user}
  def list(_, _), do: {:ok, nil}

  def show(%User{} = user, _), do: {:ok, user}
  def show(_, _), do: {:ok, nil}

  def create(%User{} = user, _), do: {:ok, user}
  def create(_, _), do: {:ok, nil}

  def update(%User{id: id} = user, %User{id: id}), do: {:ok, user}
  def update(_, _), do: {:error, :forbidden}

  def delete(%User{id: id} = user, %User{id: id}), do: {:ok, user}
  def delete(_, _), do: {:error, :forbidden}

  def subscribe(%User{} = user, _), do: {:ok, user}
  def subscribe(_, _), do: {:error, :forbidden}

  def unsubscribe(%User{} = user, _), do: {:ok, user}
  def unsubscribe(_, _), do: {:error, :forbidden}

  def feed(%User{} = user, _), do: {:ok, user}
  def feed(_, _), do: {:error, :forbidden}

  def tweets(%User{} = user, _), do: {:ok, user}
  def tweets(_, _), do: {:ok, nil}

  def likes(%User{} = user, _), do: {:ok, user}
  def likes(_, _), do: {:error, :forbidden}
end
