defmodule Twitter.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, except: [preload: 2], warn: false
  alias Twitter.Repo

  alias Twitter.Users.{User, Subscription}

  @doc false
  def preload(user, opts \\ []), do: Repo.preload(user, preloads(), opts)

  @doc false
  def preloads, do: [:tweets, :likes, :followees, :followers]

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  @spec list_users :: [User.t()]
  def list_users do
    User
    |> Repo.all()
    |> preload()
  end

  @doc """
  Gets a single user.

  ## Examples

      iex> get_user(uuid)
      {:ok, %User{}}

      iex> get_user(uuid)
      {:error, :not_found}

  """
  @spec(get_user(Ecto.UUID.t()) :: {:ok, User.t()}, {:error, :not_found})
  def get_user(id) do
    User
    |> Repo.get(id)
    |> case do
      nil ->
        {:error, :not_found}

      user ->
        {:ok, preload(user)}
    end
  end

  @doc """
  Gets a single user by name and password.

  ## Examples

      iex> get_user_by_name_and_password("foo", "bar")
      {:ok, %User{}}

      iex> get_user_by_name_and_password("foo", "bar")
      {:error, :not_found}

  """
  @spec login_user(String.t(), String.t()) :: {:ok, User.t()}, {:error, :not_found}
  def login_user(name, password) do
    User
    |> Repo.get_by(name: name)
    |> case do
      nil ->
        Bcrypt.no_user_verify()
        {:error, :not_found}

      user ->
        if Bcrypt.verify_pass(password, user.password_hash) do
          {:ok, preload(user)}
        else
          {:error, :not_found}
        end
    end
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_user(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, user} ->
        {:ok, preload(user)}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_user(User.t(), map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, user} ->
        {:ok, preload(user, force: true)}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user, stale_error_field: :id)
  end

  @doc """
  Subscribe to a user.

  Returns subscribed user or `:already_subscribed` error.

  ## Examples

      iex> subscribe(follower, followee)
      {:ok, %User{}}

      iex> subscribe(follower, followee)
      {:error, :already_subscribed}

      iex> subscribe(follower, follower)
      {:error, :cannot_subscribe_to_self}
  """
  @spec subscribe(User.t(), User.t()) :: {:ok, User.t()} | {:error, :already_subscribed} | {:error, :cannot_subscribe_to_self}
  def subscribe(%User{id: id}, %User{id: id}), do: {:error, :cannot_subscribe_to_self}

  def subscribe(%User{} = follower, %User{} = followee) do
    %{follower_id: follower.id, followee_id: followee.id}
    |> Subscription.changeset()
    |> Repo.insert()
    |> case do
      {:ok, _subscription} ->
        {:ok, preload(follower, force: true)}

      {:error, %Ecto.Changeset{errors: [follower_id: {"has already been taken", _}]}} ->
        {:error, :already_subscribed}

      {:error, %Ecto.Changeset{errors: [followee_id: {"has already been taken", _}]}} ->
        {:error, :already_subscribed}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Unsubscribe from a user.

  ## Examples

      iex> unsubscribe(follower, followee)
      {:ok, %User{}}

      iex> unsubscribe(follower, followee)
      {:error, :not_found}

  """
  @spec unsubscribe(User.t(), User.t()) :: {:ok, User.t()} | {:error, :not_found}
  def unsubscribe(%User{} = follower, %User{} = followee) do
    with s when not is_nil(s) <- Repo.get_by(Subscription, follower_id: follower.id, followee_id: followee.id),
         {:ok, _} <- Repo.delete(s) do
      {:ok, preload(follower, force: true)}
    else
      nil ->
        {:error, :not_found}

      {:error, changeset} ->
        {:error, changeset}
    end
  end
end
