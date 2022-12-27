defmodule TwitterWeb.SessionController do
  use TwitterWeb, :controller

  alias Twitter.Users

  alias TwitterWeb.Guardian

  @spec create(Plug.Conn.t(), map) :: Plug.Conn.t()
  def create(conn, %{"user" => %{"name" => username, "password" => password}}) do
    with {:ok, user} <- Users.login_user(username, password) do
      conn
      |> Guardian.Plug.sign_in(user)
      |> put_status(:created)
      |> then(&json(&1, %{token: Guardian.Plug.current_token(&1)}))
    end
  end

  def delete(conn, _params) do
    conn
    |> Guardian.Plug.sign_out()
    |> send_resp(204, "")
  end
end
