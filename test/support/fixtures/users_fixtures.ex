defmodule Twitter.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Twitter.Users` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        name: "some name",
        password_hash: "some password"
      })
      |> Twitter.Users.create_user()

    user
  end
end
