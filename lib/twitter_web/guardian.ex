defmodule TwitterWeb.Guardian do
  use Guardian, otp_app: :twitter

  alias Twitter.Users
  alias Twitter.Users.User

  def subject_for_token(%User{id: id}, _claims), do: {:ok, id}
  def subject_for_token(_, _), do: {:error, :invalid_subject}

  def resource_from_claims(%{"sub" => id}), do: Users.get_user(id)
  def resource_from_claims(_), do: {:error, :invalid_token}
end
