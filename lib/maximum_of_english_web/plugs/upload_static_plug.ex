defmodule MaximumOfEnglishWeb.UploadStaticPlug do
  @moduledoc """
  Serves uploaded files from the persistent upload directory.
  Resolves the upload path at runtime so it works with release config.
  """
  @behaviour Plug

  @impl true
  def init(_opts), do: []

  @impl true
  def call(%Plug.Conn{request_path: "/uploads/" <> rest} = conn, _opts) do
    upload_dir = MaximumOfEnglish.Uploads.upload_dir()
    file_path = Path.join(upload_dir, rest)
    safe_root = Path.expand(upload_dir)

    if String.starts_with?(Path.expand(file_path), safe_root) and File.regular?(file_path) do
      conn
      |> Plug.Conn.put_resp_header("content-type", MIME.from_path(file_path))
      |> Plug.Conn.send_file(200, file_path)
      |> Plug.Conn.halt()
    else
      conn
    end
  end

  def call(conn, _opts), do: conn
end
