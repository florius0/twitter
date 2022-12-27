defmodule TwitterWeb.Guardian.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :twitter,
    error_handler: TwitterWeb.Guardian.ErrorHandler,
    module: TwitterWeb.Guardian

  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
  plug Guardian.Plug.LoadResource, allow_blank: true
end
